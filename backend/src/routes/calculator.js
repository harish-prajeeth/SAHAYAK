const express = require('express');
const router = express.Router();
const financialController = require('../controllers/financialController');
const { authenticateToken } = require('../middleware/auth');
const { validateCalculator } = require('../middleware/validation');

// Quarterly EQI Calculator
router.post('/', authenticateToken, validateCalculator, financialController.calculate);

// Scheme Comparison
router.post('/compare', authenticateToken, financialController.compare);

// VISVAS Subvention Calculator
router.post('/visvas', authenticateToken, financialController.visvasSubvention);

// Interest Rate Info (NSFDC spread data)
router.get('/interest-rate-info', financialController.interestRateInfo);

module.exports = router;
