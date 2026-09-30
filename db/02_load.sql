-- ============================================================
-- 02_load.sql
-- 파일 기반 공공데이터 최초 적재: staging -> public
--
-- 전제
-- 1) 00_staging.sql 실행
-- 2) CSV 원본 Import 완료
-- 3) staging.a067_a_raw Shapefile 적재 완료
-- 4) staging.district_boundary_raw Shapefile 적재 완료
-- 5) 01_schema.sql 실행 완료
--
-- 주의
-- - 최초 빈 public 테이블에 적재할 때만 실행한다.
-- - traffic_incident / accident_area는 API 동기화 대상이므로 여기서 적재하지 않는다.
-- ============================================================

BEGIN;


-- ============================================================
-- 0. 원본 및 재실행 여부 확인
-- ============================================================

DO $$
BEGIN
    IF to_regclass('staging.district_boundary_raw') IS NULL THEN
        RAISE EXCEPTION 'staging.district_boundary_raw 테이블이 없습니다. Shapefile 적재를 먼저 진행하세요.';
    END IF;

    IF to_regclass('staging.a067_a_raw') IS NULL THEN
        RAISE EXCEPTION 'staging.a067_a_raw 테이블이 없습니다. Shapefile 적재를 먼저 진행하세요.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM staging.district_boundary_raw LIMIT 1) THEN
        RAISE EXCEPTION 'district_boundary_raw 데이터가 없습니다.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM staging.traffic_cctv_raw LIMIT 1) THEN
        RAISE EXCEPTION 'traffic_cctv_raw 데이터가 없습니다.';
    END IF;

    IF (SELECT COUNT(*) FROM staging.crosswalk_raw) <> 40282 THEN
        RAISE EXCEPTION 'crosswalk_raw: 예상 40282건과 다릅니다.';
    END IF;

    IF (SELECT COUNT(*) FROM staging.a067_a_raw) <> 18384 THEN
        RAISE EXCEPTION 'a067_a_raw: 예상 18384건과 다릅니다.';
    END IF;

    IF (SELECT COUNT(*) FROM staging.pedestrian_signal_raw) <> 65001 THEN
        RAISE EXCEPTION 'pedestrian_signal_raw: 예상 65001건과 다릅니다.';
    END IF;

    IF (SELECT COUNT(*) FROM staging.school_raw) <> 12011 THEN
        RAISE EXCEPTION 'school_raw: 현재 원본 기준 예상 12011건과 다릅니다.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM staging.school_raw
        WHERE BTRIM("시도교육청명") = '서울특별시교육청'
          AND BTRIM("학교급구분") = '초등학교'
          AND BTRIM("운영상태") = '운영'
    ) <> 606 THEN
        RAISE EXCEPTION 'school_raw: 서울 운영 초등학교 예상 606건과 다릅니다.';
    END IF;

    IF (SELECT COUNT(*) FROM staging.school_zone_raw) <> 1600 THEN
        RAISE EXCEPTION 'school_zone_raw: 현재 통합본 기준 예상 1600건과 다릅니다.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM staging.school_zone_raw
        WHERE BTRIM("시설종류") = '초등학교'
    ) <> 604 THEN
        RAISE EXCEPTION 'school_zone_raw: 초등학교 보호구역 예상 604건과 다릅니다.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM staging.a067_a_raw
        WHERE geom IS NULL OR ST_SRID(geom) <> 5186
    ) THEN
        RAISE EXCEPTION 'a067_a_raw: Geometry 누락 또는 좌표계 불일치가 있습니다.';
    END IF;

    IF EXISTS (SELECT 1 FROM public.district_boundary LIMIT 1)
        OR EXISTS (SELECT 1 FROM public.traffic_cctv LIMIT 1)
        OR EXISTS (SELECT 1 FROM public.crosswalk LIMIT 1)
        OR EXISTS (SELECT 1 FROM public.speed_hump LIMIT 1)
        OR EXISTS (SELECT 1 FROM public.pedestrian_signal LIMIT 1)
        OR EXISTS (SELECT 1 FROM public.school LIMIT 1)
        OR EXISTS (SELECT 1 FROM public.school_zone LIMIT 1) THEN
        RAISE EXCEPTION '초기 적재 대상 public 테이블에 데이터가 이미 있습니다. 기존 DB에서 재실행하지 마세요.';
    END IF;
END $$;


-- ============================================================
-- 1. 자치구 경계
-- ============================================================

INSERT INTO public.district_boundary (
    district_code,
    district_name,
    geom
)
SELECT
    signgu_cd,
    signgu_nm,
    geom
FROM staging.district_boundary_raw;


-- ============================================================
-- 2. 교통 CCTV
-- 서울교통정보센터 CCTV 중 서울 자치구 경계 내부만 적재
-- EPSG:4326 -> EPSG:5186
-- ============================================================

INSERT INTO public.traffic_cctv (
    cctv_id,
    cctv_name,
    center_name,
    xcoord,
    ycoord,
    movie_yn,
    geom,
    synced_at
)
SELECT
    r.cctvid,
    r.cctvname,
    r.centername,
    r.xcoord,
    r.ycoord,
    NULL,
    ST_Transform(
        ST_SetSRID(ST_MakePoint(r.xcoord, r.ycoord), 4326),
        5186
    ),
    CURRENT_TIMESTAMP
FROM staging.traffic_cctv_raw AS r
WHERE r.centername = '서울교통정보센터'
  AND r.cctvid IS NOT NULL
  AND r.xcoord IS NOT NULL
  AND r.ycoord IS NOT NULL
  AND EXISTS (
      SELECT 1
      FROM public.district_boundary AS d
      WHERE ST_Intersects(
          d.geom,
          ST_Transform(
              ST_SetSRID(ST_MakePoint(r.xcoord, r.ycoord), 4326),
              5186
          )
      )
  );


-- ============================================================
-- 3. 횡단보도
-- Y -> true / N -> false / 그 외 -> NULL
-- EPSG:4326 -> EPSG:5186
-- ============================================================

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
    management_no,
    district_name,
    lot_address,
    crosswalk_type,
    raised_yn,
    pedestrian_signal_yn,
    acoustic_signal_yn,
    geom
)
SELECT
    management_no,
    district_name,
    lot_address,
    crosswalk_type,
    CASE raised_raw WHEN 'Y' THEN TRUE WHEN 'N' THEN FALSE ELSE NULL END,
    CASE signal_raw WHEN 'Y' THEN TRUE WHEN 'N' THEN FALSE ELSE NULL END,
    CASE acoustic_raw WHEN 'Y' THEN TRUE WHEN 'N' THEN FALSE ELSE NULL END,
    CASE
        WHEN lon IS NOT NULL AND lat IS NOT NULL
        THEN ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat), 4326), 5186)
        ELSE NULL
    END
FROM src;


-- ============================================================
-- 4. 과속방지턱
-- 비유효 Geometry 보정 후 MultiPolygon만 추출
-- 면이 남지 않는 행은 속성을 보존하고 geom만 NULL
-- ============================================================

WITH fixed AS (
    SELECT
        BTRIM(mgrnu) AS management_no,
        NULLIF(BTRIM(a067_knd_c), '') AS hump_type,
        TO_DATE(NULLIF(BTRIM(esb_ymd), ''), 'YYYYMMDD') AS installation_date,
        NULLIF(BTRIM(gu_cde), '') AS district_code,
        NULLIF(BTRIM(stat_cde), '') AS status,
        ST_Multi(
            ST_CollectionExtract(
                CASE
                    WHEN ST_IsValid(geom) THEN geom
                    ELSE ST_MakeValid(geom)
                END,
                3
            )
        ) AS fixed_geom
    FROM staging.a067_a_raw
)
INSERT INTO public.speed_hump (
    management_no,
    hump_type,
    installation_date,
    district_code,
    status,
    geom
)
SELECT
    management_no,
    hump_type,
    installation_date,
    district_code,
    status,
    CASE WHEN ST_IsEmpty(fixed_geom) THEN NULL ELSE fixed_geom END
FROM fixed;


-- ============================================================
-- 5. 보행신호등
-- 보행등만 선택, 순번 이외 원본 컬럼이 완전히 같은 행 중복 제거
-- ============================================================

WITH dedup AS (
    SELECT
        MIN(BTRIM(s."순번")::BIGINT) AS source_sequence,
        TO_JSONB(s) - '순번' AS data
    FROM staging.pedestrian_signal_raw AS s
    WHERE BTRIM(s."신호등종류") = '보행등'
    GROUP BY TO_JSONB(s) - '순번'
)
INSERT INTO public.pedestrian_signal (
    source_sequence,
    district_name,
    address,
    management_no,
    signal_type,
    pedestrian_button_yn,
    acoustic_signal_yn,
    remaining_time_display_yn,
    geom
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


-- ============================================================
-- 6. 서울 운영 초등학교
-- 원본 EPSG:4326 -> EPSG:5186
-- 자치구 경계 공간조인 + 학교 중심점 300m 분석영역 생성
-- ============================================================

WITH school_src AS (
    SELECT
        BTRIM("학교ID") AS school_id,
        BTRIM("학교명") AS school_name,
        BTRIM("운영상태") AS operation_status,
        NULLIF(BTRIM("소재지도로명주소"), '') AS road_address,
        NULLIF(BTRIM("교육지원청코드"), '') AS education_office_code,
        NULLIF(BTRIM("교육지원청명"), '') AS education_office_name,
        ST_Transform(
            ST_SetSRID(
                ST_MakePoint(
                    BTRIM("경도")::DOUBLE PRECISION,
                    BTRIM("위도")::DOUBLE PRECISION
                ),
                4326
            ),
            5186
        ) AS geom
    FROM staging.school_raw
    WHERE BTRIM("시도교육청명") = '서울특별시교육청'
      AND BTRIM("학교급구분") = '초등학교'
      AND BTRIM("운영상태") = '운영'
)
INSERT INTO public.school (
    school_id,
    school_name,
    operation_status,
    road_address,
    district_code,
    district_name,
    education_office_code,
    education_office_name,
    geom,
    analysis_geom
)
SELECT
    s.school_id,
    s.school_name,
    s.operation_status,
    s.road_address,
    d.district_code,
    d.district_name,
    s.education_office_code,
    s.education_office_name,
    s.geom,
    ST_Buffer(s.geom, 300)
FROM school_src AS s
LEFT JOIN LATERAL (
    SELECT
        db.district_code,
        db.district_name
    FROM public.district_boundary AS db
    WHERE ST_Intersects(db.geom, s.geom)
    ORDER BY db.district_code
    LIMIT 1
) AS d ON TRUE;


-- ============================================================
-- 7. 어린이보호구역
-- 전체 1,600건 적재
-- 초등학교만 school_id 연결
-- 1차: 학교명 정규화 정확 일치
-- 2차: 이름 불일치 시 10m 이내 최근접 학교
-- 최종 검증 기준: 초등학교 604건 중 602건 매칭 / 2건 NULL
-- ============================================================

WITH school_norm AS (
    SELECT
        school_id,
        geom,
        CASE
            WHEN n ~ '초등학교$' THEN n
            WHEN n ~ '초교$' THEN regexp_replace(n, '초교$', '초등학교')
            WHEN n ~ '초등$' THEN regexp_replace(n, '초등$', '초등학교')
            WHEN n ~ '초$' THEN regexp_replace(n, '초$', '초등학교')
            ELSE n || '초등학교'
        END AS norm_name
    FROM (
        SELECT
            school_id,
            geom,
            regexp_replace(
                regexp_replace(
                    regexp_replace(school_name, '^서울\s*', ''),
                    '\s*\([^)]*\).*$', ''
                ),
                '\s+', '', 'g'
            ) AS n
        FROM public.school
    ) s
),
zone_src AS (
    SELECT
        r.*,
        ST_Transform(
            ST_SetSRID(
                ST_MakePoint(
                    BTRIM("경도")::DOUBLE PRECISION,
                    BTRIM("위도")::DOUBLE PRECISION
                ),
                4326
            ),
            5186
        ) AS zone_geom,
        CASE
            WHEN n ~ '초등학교$' THEN n
            WHEN n ~ '초교$' THEN regexp_replace(n, '초교$', '초등학교')
            WHEN n ~ '초등$' THEN regexp_replace(n, '초등$', '초등학교')
            WHEN n ~ '초$' THEN regexp_replace(n, '초$', '초등학교')
            ELSE n || '초등학교'
        END AS norm_name
    FROM (
        SELECT
            *,
            regexp_replace(
                regexp_replace(
                    regexp_replace(BTRIM("대상시설명"), '^서울\s*', ''),
                    '\s*\([^)]*\).*$', ''
                ),
                '\s+', '', 'g'
            ) AS n
        FROM staging.school_zone_raw
    ) r
),
matched AS (
    SELECT
        z.*,
        CASE
            WHEN BTRIM(z."시설종류") <> '초등학교' THEN NULL
            WHEN exact.school_id IS NOT NULL THEN exact.school_id
            ELSE near_school.school_id
        END AS matched_school_id
    FROM zone_src z
    LEFT JOIN school_norm exact
        ON BTRIM(z."시설종류") = '초등학교'
       AND z.norm_name = exact.norm_name
    LEFT JOIN LATERAL (
        SELECT s.school_id
        FROM public.school s
        WHERE BTRIM(z."시설종류") = '초등학교'
          AND exact.school_id IS NULL
          AND ST_DWithin(s.geom, z.zone_geom, 10)
        ORDER BY s.geom <-> z.zone_geom
        LIMIT 1
    ) near_school ON TRUE
)
INSERT INTO public.school_zone (
    school_id,
    facility_type,
    facility_name,
    road_address,
    lot_address,
    management_agency,
    police_station,
    cctv_installed_yn,
    cctv_count,
    road_width,
    data_reference_date,
    geom
)
SELECT
    matched_school_id,
    NULLIF(BTRIM("시설종류"), ''),
    NULLIF(BTRIM("대상시설명"), ''),
    NULLIF(BTRIM("소재지도로명주소"), ''),
    NULLIF(BTRIM("소재지지번주소"), ''),
    NULLIF(BTRIM("관리기관명"), ''),
    NULLIF(BTRIM("관할경찰서명"), ''),
    CASE BTRIM("CCTV설치여부")
        WHEN 'Y' THEN TRUE
        WHEN 'N' THEN FALSE
        ELSE NULL
    END,
    NULLIF(BTRIM("CCTV설치대수"), '')::INTEGER,
    NULLIF(BTRIM("보호구역도로폭"), ''),
    NULLIF(BTRIM("데이터기준일자"), '')::DATE,
    zone_geom
FROM matched;


-- ============================================================
-- 8. 결과 검증
-- 현재 사용 중인 원본 스냅샷 기준
-- ============================================================

DO $$
BEGIN
    IF (SELECT COUNT(*) FROM public.district_boundary) <> 25 THEN
        RAISE EXCEPTION '자치구 경계 적재 검증 실패: 25개 자치구가 아닙니다.';
    END IF;

    IF (SELECT COUNT(*) FROM public.crosswalk) <> 40282
        OR (SELECT COUNT(*) FROM public.crosswalk WHERE geom IS NULL) <> 1 THEN
        RAISE EXCEPTION '횡단보도 적재 검증 실패';
    END IF;

    IF (SELECT COUNT(*) FROM public.speed_hump) <> 18384
        OR (SELECT COUNT(*) FROM public.speed_hump WHERE geom IS NULL) <> 5
        OR (
            SELECT COUNT(*)
            FROM public.speed_hump
            WHERE geom IS NOT NULL AND NOT ST_IsValid(geom)
        ) <> 0 THEN
        RAISE EXCEPTION '과속방지턱 적재 검증 실패';
    END IF;

    IF (SELECT COUNT(*) FROM public.pedestrian_signal) <> 24261
        OR (SELECT COUNT(*) FROM public.pedestrian_signal WHERE geom IS NULL) <> 0 THEN
        RAISE EXCEPTION '보행신호등 적재 검증 실패';
    END IF;

    IF (SELECT COUNT(*) FROM public.school) <> 606
        OR (SELECT COUNT(*) FROM public.school WHERE district_code IS NULL) <> 0
        OR (SELECT COUNT(*) FROM public.school WHERE geom IS NULL) <> 0
        OR (SELECT COUNT(*) FROM public.school WHERE analysis_geom IS NULL) <> 0
        OR (SELECT COUNT(*) FROM public.school WHERE ST_SRID(geom) <> 5186) <> 0
        OR (SELECT COUNT(*) FROM public.school WHERE ST_SRID(analysis_geom) <> 5186) <> 0 THEN
        RAISE EXCEPTION '학교 적재 검증 실패';
    END IF;

    IF (SELECT COUNT(*) FROM public.school_zone) <> 1600
        OR (
            SELECT COUNT(*)
            FROM public.school_zone
            WHERE facility_type = '초등학교'
        ) <> 604
        OR (
            SELECT COUNT(*)
            FROM public.school_zone
            WHERE facility_type = '초등학교'
              AND school_id IS NOT NULL
        ) <> 602
        OR (
            SELECT COUNT(*)
            FROM public.school_zone
            WHERE facility_type = '초등학교'
              AND school_id IS NULL
        ) <> 2
        OR (SELECT COUNT(*) FROM public.school_zone WHERE geom IS NULL) <> 0 THEN
        RAISE EXCEPTION '어린이보호구역 적재 검증 실패';
    END IF;
END $$;

COMMIT;


-- ============================================================
-- 9. 최종 확인용 조회
-- ============================================================

SELECT 'district_boundary' AS target, COUNT(*) AS total FROM public.district_boundary
UNION ALL
SELECT 'traffic_cctv', COUNT(*) FROM public.traffic_cctv
UNION ALL
SELECT 'traffic_incident', COUNT(*) FROM public.traffic_incident
UNION ALL
SELECT 'crosswalk', COUNT(*) FROM public.crosswalk
UNION ALL
SELECT 'speed_hump', COUNT(*) FROM public.speed_hump
UNION ALL
SELECT 'pedestrian_signal', COUNT(*) FROM public.pedestrian_signal
UNION ALL
SELECT 'school', COUNT(*) FROM public.school
UNION ALL
SELECT 'school_zone', COUNT(*) FROM public.school_zone
UNION ALL
SELECT 'accident_area', COUNT(*) FROM public.accident_area;

-- 초등학교 보호구역 미매칭 2건 확인
SELECT
    facility_name,
    road_address,
    school_id
FROM public.school_zone
WHERE facility_type = '초등학교'
  AND school_id IS NULL
ORDER BY facility_name;
