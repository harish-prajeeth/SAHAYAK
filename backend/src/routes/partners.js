const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { findNearestPartners, checkPartnerEligibility, getPartnerById } = require('../services/partnerRouter');
const { authenticateToken } = require('../middleware/auth');

// Get all partners
router.get('/', authenticateToken, async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM partners ORDER BY name');
        res.json({ success: true, partners: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Find nearest partners (PostGIS)
router.get('/nearby', authenticateToken, async (req, res) => {
    try {
        const { lat, lng, scheme, limit } = req.query;
        if (!lat || !lng || !scheme) {
            return res.status(400).json({ success: false, error: 'Missing required parameters: lat, lng, scheme' });
        }
        const partners = await findNearestPartners(parseFloat(lat), parseFloat(lng), scheme, parseInt(limit) || 5);
        res.json({ success: true, partners });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Check partner eligibility
router.get('/:id/eligibility', authenticateToken, async (req, res) => {
    try {
        const partner = await checkPartnerEligibility(parseInt(req.params.id));
        if (!partner) return res.status(404).json({ success: false, error: 'Partner not found' });
        res.json({ success: true, partner });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get partner details
router.get('/:id', authenticateToken, async (req, res) => {
    try {
        const partner = await getPartnerById(parseInt(req.params.id));
        if (!partner) return res.status(404).json({ success: false, error: 'Partner not found' });
        res.json({ success: true, partner });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
