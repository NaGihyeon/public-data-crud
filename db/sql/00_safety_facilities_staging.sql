-- 안전시설 공공데이터 원본 적재용 테이블
-- 최초 1회 실행 후 DBeaver에서 원본 CSV를 각 테이블에 Import Data 한다.
-- 험프 원본은 Shapefile이므로 shp2pgsql-gui에서 staging.a067_a_raw로 직접 가져온다.

CREATE SCHEMA IF NOT EXISTS staging;

-- 서울시 자치구 횡단보도 정보 (CSV: 13개 컬럼, CP949)
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

-- 서울특별시 신호등표준데이터 (CSV: 13개 컬럼, CP949)
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
