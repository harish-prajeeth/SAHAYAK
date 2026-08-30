const Database = require('better-sqlite3');
const path = require('path');

const dbPath = path.join(__dirname, '../../surakshit.db');
const db = new Database(dbPath);

// Enable WAL mode for better performance
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// Create tables
db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aadhaar_hash TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    income REAL,
    caste_category TEXT DEFAULT 'SC',
    education TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS schemes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    min_cost REAL,
    max_cost REAL,
    max_loan REAL,
    interest_rate REAL,
    max_tenure_months INTEGER,
    moratorium_months INTEGER,
    channel_types TEXT,
    is_active INTEGER DEFAULT 1
  );

  CREATE TABLE IF NOT EXISTS partners (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    email TEXT,
    latitude REAL,
    longitude REAL,
    fund_utilization REAL,
    npa_rate REAL,
    is_eligible INTEGER DEFAULT 1,
    supported_schemes TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users(id),
    scheme_id INTEGER REFERENCES schemes(id),
    partner_id INTEGER REFERENCES partners(id),
    project_type TEXT,
    project_cost REAL,
    loan_amount REAL,
    status TEXT DEFAULT 'draft',
    rejection_reason TEXT,
    rejection_category TEXT,
    remediation_steps TEXT,
    current_stage TEXT,
    stage_updated_at TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS application_status_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    application_id INTEGER REFERENCES applications(id),
    stage TEXT,
    status TEXT,
    notes TEXT,
    created_at TEXT DEFAULT (datetime('now'))
  );
`);

console.log('SQLite database initialized successfully');

module.exports = db;
