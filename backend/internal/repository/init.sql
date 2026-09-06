-- ============================================================================
-- DrugShield — PostgreSQL 16 + PostGIS + TimescaleDB Database Initialization
-- SIH26231: Digital Companion for Field Drug Testing
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- Core Seizure Records Table (Synchronized from Hyperledger Fabric Events)
-- ============================================================================
CREATE TABLE IF NOT EXISTS drug_seizures (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seizure_id        VARCHAR(64) UNIQUE NOT NULL,
    case_number       VARCHAR(64) NOT NULL,
    officer_badge     VARCHAR(32) NOT NULL,
    seizure_time      TIMESTAMPTZ NOT NULL,
    detected_substance VARCHAR(64) NOT NULL,
    confidence_score  NUMERIC(5, 4) NOT NULL CHECK (confidence_score BETWEEN 0 AND 1),
    reagent_used      VARCHAR(64) NOT NULL,
    geom              GEOMETRY(Point, 4326) NOT NULL,
    evidence_seal_id  VARCHAR(64),
    blockchain_tx_id  VARCHAR(128) NOT NULL,
    ipfs_cid          VARCHAR(128) NOT NULL,
    image_sha256      VARCHAR(64) NOT NULL,
    fsl_status        VARCHAR(32) DEFAULT 'PENDING'
                      CHECK (fsl_status IN ('PENDING', 'IN_TRANSIT', 'CONFIRMED', 'REJECTED', 'INCONCLUSIVE')),
    fsl_lab_id        VARCHAR(64),
    fsl_scientist_badge VARCHAR(32),
    fsl_endorsement_time TIMESTAMPTZ,
    ambient_lux       NUMERIC(7, 2),
    device_model      VARCHAR(64),
    created_at        TIMESTAMPTZ DEFAULT NOW(),
    updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial R-tree index for geographic bounding-box queries
CREATE INDEX IF NOT EXISTS idx_seizures_geom ON drug_seizures USING GIST(geom);

-- B-tree indices for common query patterns
CREATE INDEX IF NOT EXISTS idx_seizures_substance ON drug_seizures(detected_substance);
CREATE INDEX IF NOT EXISTS idx_seizures_officer ON drug_seizures(officer_badge);
CREATE INDEX IF NOT EXISTS idx_seizures_fsl_status ON drug_seizures(fsl_status);
CREATE INDEX IF NOT EXISTS idx_seizures_case ON drug_seizures(case_number);

-- Convert to TimescaleDB hypertable for fast temporal aggregation
SELECT create_hypertable('drug_seizures', 'seizure_time', if_not_exists => TRUE);

-- ============================================================================
-- Officer Registry (Enrolled devices and public keys)
-- ============================================================================
CREATE TABLE IF NOT EXISTS officers (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    badge_number      VARCHAR(32) UNIQUE NOT NULL,
    full_name         VARCHAR(128) NOT NULL,
    rank              VARCHAR(32) NOT NULL,
    organization      VARCHAR(64) NOT NULL,   -- NCB, State Police, BSF, Customs
    station_code      VARCHAR(32),
    public_key_thumbprint VARCHAR(64) UNIQUE NOT NULL,
    device_model      VARCHAR(64),
    enrolled_at       TIMESTAMPTZ DEFAULT NOW(),
    is_active         BOOLEAN DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_officers_org ON officers(organization);

-- ============================================================================
-- Analytics Views
-- ============================================================================

-- Real-time substance distribution summary
CREATE OR REPLACE VIEW v_substance_distribution AS
SELECT
    detected_substance,
    COUNT(*) AS total_seizures,
    ROUND(AVG(confidence_score)::numeric, 4) AS avg_confidence,
    COUNT(*) FILTER (WHERE fsl_status = 'CONFIRMED') AS lab_confirmed,
    COUNT(*) FILTER (WHERE fsl_status = 'REJECTED') AS lab_rejected
FROM drug_seizures
GROUP BY detected_substance
ORDER BY total_seizures DESC;

-- Monthly seizure trend
CREATE OR REPLACE VIEW v_monthly_trend AS
SELECT
    time_bucket('1 month', seizure_time) AS month,
    detected_substance,
    COUNT(*) AS seizure_count
FROM drug_seizures
GROUP BY month, detected_substance
ORDER BY month DESC;
