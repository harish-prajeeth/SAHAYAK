const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { getRecommendation } = require('../services/recommendationEngine');
const { authenticateToken } = require('../middleware/auth');

// Get all schemes
router.get('/', async (req, res) => {
    try {
        const schemes = db.prepare('SELECT * FROM schemes WHERE is_active = 1').all();
        res.json({ success: true, schemes });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get scheme recommendation
router.post('/recommend', authenticateToken, async (req, res) => {
    try {
        const userInput = req.body;
        const recommendation = await getRecommendation(userInput);
        res.json({ success: true, recommendation });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get scheme by code
router.get('/:code', async (req, res) => {
    try {
        const scheme = db.prepare('SELECT * FROM schemes WHERE code = ?').get(req.params.code);
        if (!scheme) {
            return res.status(404).json({ success: false, error: 'Scheme not found' });
        }
        res.json({ success: true, scheme });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
