-- 안전시설 공공데이터: staging -> public
-- 전제: 00_staging, 01_schema 실행 및 CSV/Shapefile의 staging 원본 적재 완료
-- 주의: 최초 빈 최종 테이블에 적재할 때만 실행. 기존 데이터가 있으면 중단한다.
-- 대상 스냅샷: 횡단보도 2026-03-20 / 험프 파일명 20250417 / 신호등 2025-09-11

BEGIN;

-- 0. 원본 적재 여부 및 재실행 방지
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM staging.crosswalk_raw) <> 40282 THEN
        RAISE EXCEPTION 'crosswalk_raw: 예상 40282건과 다릅니다. CSV 적재 상태를 확인하세요.';
    END IF;
    IF (SELECT COUNT(*) FROM staging.a067_a_raw) <> 18384 THEN
        RAISE EXCEPTION 'a067_a_raw: 예상 18384건과 다릅니다. 최신 Shapefile 적재 상태를 확인하세요.';
    END IF;
    IF (SELECT COUNT(*) FROM staging.pedestrian_signal_raw) <> 65001 THEN
        RAISE EXCEPTION 'pedestrian_signal_raw: 예상 65001건과 다릅니다. CSV 적재 상태를 확인하세요.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM staging.a067_a_raw WHERE geom IS NULL OR ST_SRID(geom) <> 5186
    ) THEN
        RAISE EXCEPTION 'a067_a_raw: Geometry 누락 또는 좌표계 불일치가 있습니다.';
    END IF;
    IF EXISTS (SELECT 1 FROM public.crosswalk LIMIT 1)
        OR EXISTS (SELECT 1 FROM public.speed_hump LIMIT 1)
        OR EXISTS (SELECT 1 FROM public.pedestrian_signal LIMIT 1) THEN
        RAISE EXCEPTION '최종 테이블에 데이터가 이미 있습니다. 기존 DB에서 재실행하지 마세요.';
    END IF;
END $$;

-- 1. 횡단보도: Y -> true, N -> false, 그 외(-/빈칸 등) -> NULL
-- 원본 경도/위도 EPSG:4326 -> DB EPSG:5186
WITH src AS (
    SELECT
        NULLIF(BTRIM("횡단보도관리번호"), '') AS management_no,
        NULLIF(BTRIM("시군구명"), '') AS district_name,
        NULLIF(BTRIM("소재지지번주소"), '') AS lot_address,
        NULLIF(BTRIM("횡단보도종류"), '') AS crosswalk_type,
        UPPER(BTRIM("고원식횡단보도유무")) AS raised_raw,
        UPPER(BTRIM("보행등유무")) AS signal_raw,
        UPPER(BTRIM("음향신호기설치여부")) AS acoustic_raw,
        NULLIF(BTRIM("경도"), '')::DOUBLE PRECISION AS lon,
        NULLIF(BTRIM("위도"), '')::DOUBLE PRECISION AS lat
    FROM staging.crosswalk_raw
)
INSERT INTO public.crosswalk (
    management_no, district_name, lot_address, crosswalk_type,
    raised_yn, pedestrian_signal_yn, acoustic_signal_yn, geom
)
SELECT
    management_no, district_name, lot_address, crosswalk_type,
    CASE raised_raw WHEN 'Y' THEN TRUE WHEN 'N' THEN FALSE ELSE NULL END,
    CASE signal_raw WHEN 'Y' THEN TRUE WHEN 'N' THEN FALSE ELSE NULL END,
    CASE acoustic_raw WHEN 'Y' THEN TRUE WHEN 'N' THEN FALSE ELSE NULL END,
    CASE WHEN lon IS NOT NULL AND lat IS NOT NULL
        THEN ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat), 4326), 5186)
        ELSE NULL
    END
FROM src;

-- 2. 험프: 비유효 Geometry 보정 후 MultiPolygon만 추출
-- 보정 후 면(Polygon)이 남지 않는 5건은 속성정보를 보존하고 geom만 NULL
WITH fixed AS (
    SELECT
        BTRIM(mgrnu) AS management_no,
        NULLIF(BTRIM(a067_knd_c), '') AS hump_type,
        TO_DATE(NULLIF(BTRIM(esb_ymd), ''), 'YYYYMMDD') AS installation_date,
        NULLIF(BTRIM(gu_cde), '') AS district_code,
        NULLIF(BTRIM(stat_cde), '') AS status,
        ST_Multi(
            ST_CollectionExtract(
                CASE WHEN ST_IsValid(geom) THEN geom ELSE ST_MakeValid(geom) END,
                3
            )
        ) AS fixed_geom
    FROM staging.a067_a_raw
)
INSERT INTO public.speed_hump (
    management_no, hump_type, installation_date, district_code, status, geom
)
SELECT
    management_no, hump_type, installation_date, district_code, status,
    CASE WHEN ST_IsEmpty(fixed_geom) THEN NULL ELSE fixed_geom END
FROM fixed;

-- 3. 보행신호등: 보행등만 선택, 순번 이외 모든 원본 컬럼이 같은 행을 중복 제거
-- 관리번호만 같은 행은 중복 제거하지 않음 (UNIQUE 제약 없음)
WITH dedup AS (
    SELECT
        MIN(BTRIM(s."순번")::BIGINT) AS source_sequence,
        TO_JSONB(s) - '순번' AS data
    FROM staging.pedestrian_signal_raw AS s
    WHERE BTRIM(s."신호등종류") = '보행등'
    GROUP BY TO_JSONB(s) - '순번'
)
INSERT INTO public.pedestrian_signal (
    source_sequence, district_name, address, management_no, signal_type,
    pedestrian_button_yn, acoustic_signal_yn, remaining_time_display_yn, geom
)
SELECT
    source_sequence,
    NULLIF(BTRIM(data->>'시군구명'), ''),
    NULLIF(BTRIM(data->>'주소'), ''),
    NULLIF(BTRIM(data->>'관리번호'), ''),
    BTRIM(data->>'신호등종류'),
    CASE BTRIM(data->>'보행자작동신호기유무')
        WHEN '유' THEN TRUE WHEN '무' THEN FALSE ELSE NULL END,
    CASE BTRIM(data->>'음향신호기유무')
        WHEN '유' THEN TRUE WHEN '무' THEN FALSE ELSE NULL END,
    CASE BTRIM(data->>'잔여시간표시장치유무')
        WHEN '유' THEN TRUE WHEN '무' THEN FALSE ELSE NULL END,
    ST_SetSRID(
        ST_MakePoint(
            (data->>'X좌표')::DOUBLE PRECISION,
            (data->>'Y좌표')::DOUBLE PRECISION
        ),
        5186
    )
FROM dedup;

-- 4. 결과 검증: 현재 사용한 원본 스냅샷 기준
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM public.crosswalk) <> 40282
        OR (SELECT COUNT(*) FROM public.crosswalk WHERE geom IS NULL) <> 1 THEN
        RAISE EXCEPTION '횡단보도 적재 검증 실패';
    END IF;
    IF (SELECT COUNT(*) FROM public.speed_hump) <> 18384
        OR (SELECT COUNT(*) FROM public.speed_hump WHERE geom IS NULL) <> 5
        OR (SELECT COUNT(*) FROM public.speed_hump WHERE geom IS NOT NULL AND NOT ST_IsValid(geom)) <> 0 THEN
        RAISE EXCEPTION '과속방지턱 적재 검증 실패';
    END IF;
    IF (SELECT COUNT(*) FROM public.pedestrian_signal) <> 24261
        OR (SELECT COUNT(*) FROM public.pedestrian_signal WHERE geom IS NULL) <> 0 THEN
        RAISE EXCEPTION '보행신호등 적재 검증 실패';
    END IF;
END $$;

COMMIT;

-- 검증 결과 직접 확인 (적재 성공 후 별도로 실행 가능)
SELECT 'crosswalk' AS facility, COUNT(*) AS total,
       COUNT(*) FILTER (WHERE geom IS NULL) AS geom_null
FROM public.crosswalk
UNION ALL
SELECT 'speed_hump', COUNT(*), COUNT(*) FILTER (WHERE geom IS NULL)
FROM public.speed_hump
UNION ALL
SELECT 'pedestrian_signal', COUNT(*), COUNT(*) FILTER (WHERE geom IS NULL)
FROM public.pedestrian_signal;
