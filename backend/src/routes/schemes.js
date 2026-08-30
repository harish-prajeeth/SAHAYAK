const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { getRecommendation } = require('../services/recommendationEngine');
const { authenticateToken } = require('../middleware/auth');

// Get all schemes
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM schemes WHERE is_active = true');
        res.json({ success: true, schemes: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get scheme recommendation
router.post('/recommend', authenticateToken, async (req, res) => {
    try {
        const recommendation = await getRecommendation(req.body);
        res.json({ success: true, recommendation });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get scheme by code
router.get('/:code', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM schemes WHERE code = $1', [req.params.code]);
        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, error: 'Scheme not found' });
        }
        res.json({ success: true, scheme: result.rows[0] });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
