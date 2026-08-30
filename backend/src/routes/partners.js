const express = require('express');
const router = express.Router();
const { findNearestPartners, checkPartnerEligibility, getPartnerById } = require('../services/partnerRouter');
const { authenticateToken } = require('../middleware/auth');

// Get all partners
router.get('/', authenticateToken, (req, res) => {
    try {
        const db = require('../config/database');
        const partners = db.prepare('SELECT * FROM partners ORDER BY name').all();
        res.json({ success: true, partners });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Find nearest partners
router.get('/nearby', authenticateToken, (req, res) => {
    try {
        const { lat, lng, scheme, limit } = req.query;
        
        if (!lat || !lng || !scheme) {
            return res.status(400).json({
                success: false,
                error: 'Missing required parameters: lat, lng, scheme'
            });
        }
        
        const partners = findNearestPartners(
            parseFloat(lat),
            parseFloat(lng),
            scheme,
            parseInt(limit) || 5
        );
        
        res.json({ success: true, partners });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Check partner eligibility
router.get('/:id/eligibility', authenticateToken, (req, res) => {
    try {
        const partner = checkPartnerEligibility(parseInt(req.params.id));
        if (!partner) {
            return res.status(404).json({ success: false, error: 'Partner not found' });
        }
        res.json({ success: true, partner });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get partner details
router.get('/:id', authenticateToken, (req, res) => {
    try {
        const partner = getPartnerById(parseInt(req.params.id));
        if (!partner) {
            return res.status(404).json({ success: false, error: 'Partner not found' });
        }
        res.json({ success: true, partner });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
