const express = require('express');
const router = express.Router();
const financialController = require('../controllers/financialController');
const { authenticateToken } = require('../middleware/auth');
const { validateCalculator } = require('../middleware/validation');

router.post('/', authenticateToken, validateCalculator, financialController.calculate);
router.post('/compare', authenticateToken, financialController.compare);
router.post('/visvas', authenticateToken, financialController.visvasSubvention);

module.exports = router;
