const { Pool } = require('pg');
require('dotenv').config({ override: true });

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    max: parseInt(process.env.DATABASE_POOL_MAX) || 10,
    min: parseInt(process.env.DATABASE_POOL_MIN) || 2,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
});

pool.connect((err, client, release) => {
    if (err) { console.error('Database connection failed:', err.stack); return; }
    console.log('PostgreSQL connected successfully');
    release();
});

module.exports = pool;
