const express = require('express');
const router = express.Router();
const { calculateAmortization, compareSchemes } = require('../services/financialCalculator');
const { authenticateToken } = require('../middleware/auth');

router.post('/', authenticateToken, (req, res) => {
    try {
        const { principal, interestRate, tenureMonths, moratoriumMonths } = req.body;
        if (!principal || !interestRate || !tenureMonths) {
            return res.status(400).json({ success: false, error: 'Missing required: principal, interestRate, tenureMonths' });
        }
        const result = calculateAmortization(principal, interestRate, tenureMonths, moratoriumMonths || 0);
        res.json({ success: true, calculation: result });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

router.post('/compare', authenticateToken, (req, res) => {
    try {
        const { scenarios } = req.body;
        if (!scenarios || !Array.isArray(scenarios)) {
            return res.status(400).json({ success: false, error: 'Missing scenarios array' });
        }
        const results = compareSchemes(scenarios);
        res.json({ success: true, comparisons: results });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
