CREATE EXTENSION IF NOT EXISTS postgis;


-- public.district_boundary definition

-- DROP TABLE public.district_boundary;

CREATE TABLE public.district_boundary (
    district_code VARCHAR(5) NOT NULL,
    district_name VARCHAR(50) NOT NULL,
    geom public.geometry(MultiPolygon, 5186) NOT NULL,
    CONSTRAINT district_boundary_pkey PRIMARY KEY (district_code)
);

CREATE INDEX idx_district_boundary_geom
    ON public.district_boundary
    USING GIST (geom);


-- public.traffic_incident definition

-- DROP TABLE public.traffic_incident;

CREATE TABLE public.traffic_incident (
    acc_id VARCHAR(20) NOT NULL,
    occurred_at TIMESTAMP NOT NULL,
    expected_clear_at TIMESTAMP NULL,
    acc_type VARCHAR(10) NULL,
    acc_detail_type VARCHAR(20) NULL,
    link_id VARCHAR(20) NULL,
    acc_info TEXT NULL,
    geom public.geometry(Point, 5186) NOT NULL,
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT traffic_incident_pkey PRIMARY KEY (acc_id)
);

CREATE INDEX idx_traffic_incident_geom
    ON public.traffic_incident
    USING GIST (geom);


-- public.traffic_cctv definition

-- DROP TABLE public.traffic_cctv;

CREATE TABLE public.traffic_cctv (
    cctv_id VARCHAR(50) NOT NULL,
    cctv_name VARCHAR(200) NULL,
    center_name VARCHAR(200) NULL,
    xcoord DOUBLE PRECISION NOT NULL,
    ycoord DOUBLE PRECISION NOT NULL,
    movie_yn BOOLEAN NULL,
    geom public.geometry(Point, 5186) NOT NULL,
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT traffic_cctv_pkey PRIMARY KEY (cctv_id)
);

CREATE INDEX idx_traffic_cctv_geom
    ON public.traffic_cctv
    USING GIST (geom);
