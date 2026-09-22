const { Pool } = require('pg');
require('dotenv').config({ override: true });

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    max: parseInt(process.env.DATABASE_POOL_MAX) || 10,
    // min: 0 — never pin idle connections open. Pinned clients go stale when the
    // DB restarts (e.g. Docker Desktop down), and pg-pool keeps serving them,
    // causing permanent ECONNREFUSED/timeout failures until manual restart.
    min: 0,
    idleTimeoutMillis: 15000,
    connectionTimeoutMillis: 5000,
    keepAlive: true,
    keepAliveInitialDelayMillis: 5000,
    statement_timeout: 10000,
    query_timeout: 10000,
});

// Never let a stray DB error crash the whole API process
pool.on('error', (err) => {
    console.error('Unexpected PostgreSQL pool error (pool keeps running):', err.message);
});

pool.connect((err, client, release) => {
    if (err) {
        console.error('Database connection failed:', err.message);
        return;
    }
    console.log('PostgreSQL connected successfully');
    release();
});

module.exports = pool;
