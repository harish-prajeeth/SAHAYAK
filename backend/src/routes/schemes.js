const express = require('express');
const router = express.Router();
const schemeController = require('../controllers/schemeController');
const { authenticateToken } = require('../middleware/auth');
const { validateRecommendation } = require('../middleware/validation');

router.get('/', schemeController.list);
router.post('/recommend', authenticateToken, validateRecommendation, schemeController.recommend);
router.post('/compare', authenticateToken, schemeController.compare);
router.get('/:code', schemeController.get);

module.exports = router;
