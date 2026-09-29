-- 지도 레이어 공공데이터 원본 적재용 테이블
-- CCTV 원본은 아래 staging 테이블 생성 후 Import Data로 적재한다.
-- 자치구 경계 원본은 Shapefile이므로
-- shp2pgsql-gui에서 staging.district_boundary_raw로 직접 가져온다.

CREATE SCHEMA IF NOT EXISTS staging;


-- UTIC 교통 CCTV 원본

CREATE TABLE IF NOT EXISTS staging.traffic_cctv_raw (
    rn INTEGER,
    cctvid VARCHAR(50),
    cctvname VARCHAR(200),
    centername VARCHAR(200),
    xcoord DOUBLE PRECISION,
    ycoord DOUBLE PRECISION
);


-- 자치구 경계 원본
-- Shapefile 직접 적재 후 생성되는 테이블 구조:
--
-- staging.district_boundary_raw
--   gid          SERIAL PRIMARY KEY
--   signgu_cd    VARCHAR(5)
--   signgu_nm    VARCHAR(30)
--   xcnts_valu   NUMERIC
--   ydnts_valu   NUMERIC
--   relm_ar      NUMERIC
--   geom         geometry(MultiPolygon, 5186)