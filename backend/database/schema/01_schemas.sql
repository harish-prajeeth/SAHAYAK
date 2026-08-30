-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    aadhaar_hash VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    income DECIMAL(12,2),
    caste_category VARCHAR(20) DEFAULT 'SC',
    education VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- SCHEMES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS schemes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    min_cost DECIMAL(12,2),
    max_cost DECIMAL(12,2),
    max_loan DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    max_tenure_months INTEGER,
    moratorium_months INTEGER,
    channel_types TEXT[],
    is_active BOOLEAN DEFAULT true
);

-- ============================================
-- PARTNERS TABLE (with PostGIS)
-- ============================================
CREATE TABLE IF NOT EXISTS partners (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    type VARCHAR(50) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    location GEOMETRY(POINT, 4326),
    fund_utilization DECIMAL(5,2),
    npa_rate DECIMAL(5,2),
    is_eligible BOOLEAN DEFAULT true,
    supported_schemes TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_partners_location ON partners USING GIST (location);

-- ============================================
-- APPLICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS applications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    scheme_id INTEGER REFERENCES schemes(id),
    partner_id INTEGER REFERENCES partners(id),
    project_type VARCHAR(50),
    project_cost DECIMAL(12,2),
    loan_amount DECIMAL(12,2),
    status VARCHAR(30) DEFAULT 'draft',
    rejection_reason TEXT,
    rejection_category VARCHAR(30),
    remediation_steps TEXT,
    current_stage VARCHAR(50),
    stage_updated_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- APPLICATION STATUS HISTORY
-- ============================================
CREATE TABLE IF NOT EXISTS application_status_history (
    id SERIAL PRIMARY KEY,
    application_id INTEGER REFERENCES applications(id),
    stage VARCHAR(50),
    status VARCHAR(30),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
