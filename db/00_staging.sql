-- ============================================================
-- 00_staging.sql
-- 공공데이터 원본 적재용 staging 정의
--
-- 실행 순서
-- 1) 이 파일 실행
-- 2) CSV 원본은 DBeaver Import Data로 적재
-- 3) Shapefile 원본은 shp2pgsql-gui로 지정 staging 테이블에 적재
-- 4) 01_schema.sql 실행
-- 5) 02_load.sql 실행
-- ============================================================

CREATE SCHEMA IF NOT EXISTS staging;


-- ============================================================
-- 1. 안전시설 원본
-- ============================================================

-- 서울시 자치구 횡단보도 정보
-- CSV: 13개 컬럼 / CP949
CREATE TABLE IF NOT EXISTS staging.crosswalk_raw (
    "연번" TEXT,
    "시도명" TEXT,
    "시군구명" TEXT,
    "소재지지번주소" TEXT,
    "횡단보도관리번호" TEXT,
    "횡단보도종류" TEXT,
    "경도" TEXT,
    "위도" TEXT,
    "고원식횡단보도유무" TEXT,
    "보행등유무" TEXT,
    "음향신호기설치여부" TEXT,
    "보행자작동신호기유무" TEXT,
    "데이터기준일자" TEXT
);

-- 서울특별시 신호등표준데이터
-- CSV: 13개 컬럼 / CP949
CREATE TABLE IF NOT EXISTS staging.pedestrian_signal_raw (
    "순번" TEXT,
    "시군구명" TEXT,
    "도로종류" TEXT,
    "주소" TEXT,
    "X좌표" TEXT,
    "Y좌표" TEXT,
    "부착방식" TEXT,
    "관리번호" TEXT,
    "신호등종류" TEXT,
    "광원종류" TEXT,
    "보행자작동신호기유무" TEXT,
    "음향신호기유무" TEXT,
    "잔여시간표시장치유무" TEXT
);

-- 과속방지턱 원본
-- Shapefile이므로 shp2pgsql-gui에서 staging.a067_a_raw로 직접 적재한다.
-- 현재 적재 로직에서 사용하는 주요 컬럼:
--   mgrnu, a067_knd_c, esb_ymd, gu_cde, stat_cde, geom


-- ============================================================
-- 2. 지도 레이어 원본
-- ============================================================

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
-- Shapefile이므로 shp2pgsql-gui에서 staging.district_boundary_raw로 직접 적재한다.
-- 예상 주요 컬럼:
--   gid          SERIAL PRIMARY KEY
--   signgu_cd    VARCHAR(5)
--   signgu_nm    VARCHAR(30)
--   xcnts_valu   NUMERIC
--   ydnts_valu   NUMERIC
--   relm_ar      NUMERIC
--   geom         geometry(MultiPolygon, 5186)


-- ============================================================
-- 3. 학교 원본
-- ============================================================

-- 한국교육시설안전원 초중등학교 위치 원본
-- 현재 사용 파일 기준: 2026-03-20 / 전체 12,011건
CREATE TABLE IF NOT EXISTS staging.school_raw (
    "학교ID" TEXT,
    "학교명" TEXT,
    "학교급구분" TEXT,
    "설립일자" TEXT,
    "설립형태" TEXT,
    "본교분교구분" TEXT,
    "운영상태" TEXT,
    "소재지지번주소" TEXT,
    "소재지도로명주소" TEXT,
    "시도교육청코드" TEXT,
    "시도교육청명" TEXT,
    "교육지원청코드" TEXT,
    "교육지원청명" TEXT,
    "생성일자" TEXT,
    "변경일자" TEXT,
    "위도" TEXT,
    "경도" TEXT,
    "데이터기준일자" TEXT
);


-- ============================================================
-- 4. 어린이보호구역 원본
-- ============================================================

-- 서울 25개 자치구 어린이보호구역 통합 CSV
-- 현재 통합본 기준: 전체 1,600건 / 시설종류=초등학교 604건
CREATE TABLE IF NOT EXISTS staging.school_zone_raw (
    "시설종류" TEXT,
    "대상시설명" TEXT,
    "소재지도로명주소" TEXT,
    "소재지지번주소" TEXT,
    "위도" TEXT,
    "경도" TEXT,
    "관리기관명" TEXT,
    "관할경찰서명" TEXT,
    "CCTV설치여부" TEXT,
    "CCTV설치대수" TEXT,
    "어린이보호구역지정여부" TEXT,
    "어린이보호구역지정여부수정일자" TEXT,
    "보호구역도로폭" TEXT,
    "데이터기준일자" TEXT
);


-- ============================================================
-- 5. 사고다발지역 API 원본(개발/검증용)
-- ============================================================

-- 최종 서비스에서는 Java API/Quartz 동기화로 public.accident_area를 갱신한다.
-- 아래 raw 테이블은 API 응답 검증 또는 수동 테스트가 필요할 때 사용할 수 있다.
CREATE TABLE IF NOT EXISTS staging.accident_area_raw (
    accident_type VARCHAR(30) NOT NULL,
    base_year SMALLINT NOT NULL,
    search_year_cd VARCHAR(20) NOT NULL,
    afos_fid TEXT,
    afos_id TEXT,
    bjd_cd TEXT,
    spot_cd TEXT,
    sido_sgg_nm TEXT,
    spot_nm TEXT,
    occrrnc_cnt TEXT,
    caslt_cnt TEXT,
    dth_dnv_cnt TEXT,
    se_dnv_cnt TEXT,
    sl_dnv_cnt TEXT,
    wnd_dnv_cnt TEXT,
    lo_crd TEXT,
    la_crd TEXT,
    geom_json TEXT
);
