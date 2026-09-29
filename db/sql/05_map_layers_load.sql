-- 지도 레이어 공공데이터: staging -> public
-- 전제:
-- 1. 03_map_layers_staging.sql 실행
-- 2. 04_map_layers_schema.sql 실행
-- 3. 자치구 경계 Shapefile을 staging.district_boundary_raw로 적재
-- 4. CCTV 원본을 staging.traffic_cctv_raw로 적재
--
-- 주의: 최초 빈 최종 테이블에 적재할 때만 실행한다.

BEGIN;


-- 0. 원본 및 재실행 여부 확인

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM staging.district_boundary_raw
        LIMIT 1
    ) THEN
        RAISE EXCEPTION
            'district_boundary_raw 데이터가 없습니다.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM staging.traffic_cctv_raw
        LIMIT 1
    ) THEN
        RAISE EXCEPTION
            'traffic_cctv_raw 데이터가 없습니다.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.district_boundary
        LIMIT 1
    ) THEN
        RAISE EXCEPTION
            'district_boundary에 데이터가 이미 있습니다.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.traffic_cctv
        LIMIT 1
    ) THEN
        RAISE EXCEPTION
            'traffic_cctv에 데이터가 이미 있습니다.';
    END IF;
END $$;


-- 1. 자치구 경계 적재

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


-- 2. 서울교통정보센터 CCTV 중
--    서울 자치구 경계 내부에 존재하는 CCTV만 적재
--    원본 경위도 EPSG:4326 -> DB EPSG:5186

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
        ST_SetSRID(
            ST_MakePoint(
                r.xcoord,
                r.ycoord
            ),
            4326
        ),
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
              ST_SetSRID(
                  ST_MakePoint(
                      r.xcoord,
                      r.ycoord
                  ),
                  4326
              ),
              5186
          )
      )
  );


COMMIT;


-- 결과 확인

SELECT
    'district_boundary' AS layer,
    COUNT(*) AS total
FROM public.district_boundary

UNION ALL

SELECT
    'traffic_cctv',
    COUNT(*)
FROM public.traffic_cctv

UNION ALL

SELECT
    'traffic_incident',
    COUNT(*)
FROM public.traffic_incident;