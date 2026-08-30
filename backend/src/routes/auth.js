const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

// User Registration
router.post('/register', async (req, res) => {
    const { aadhaar_hash, name, email, phone, income, education } = req.body;
    try {
        const existing = await pool.query(
            'SELECT id FROM users WHERE aadhaar_hash = $1 OR email = $2', [aadhaar_hash, email]
        );
        if (existing.rows.length > 0) {
            return res.status(400).json({ success: false, error: 'User already exists' });
        }
        const result = await pool.query(
            `INSERT INTO users (aadhaar_hash, name, email, phone, income, education) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id, name, email`,
            [aadhaar_hash, name, email, phone, income, education]
        );
        const user = result.rows[0];
        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '24h' });
        res.json({ success: true, token, user });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// User Login (Aadhaar based)
router.post('/login', async (req, res) => {
    const { aadhaar_hash } = req.body;
    try {
        const result = await pool.query('SELECT * FROM users WHERE aadhaar_hash = $1', [aadhaar_hash]);
        if (result.rows.length === 0) {
            return res.status(401).json({ success: false, error: 'User not found' });
        }
        const user = result.rows[0];
        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '24h' });
        res.json({ success: true, token, user: { id: user.id, name: user.name, email: user.email, phone: user.phone, income: user.income, caste_category: user.caste_category, education: user.education } });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
