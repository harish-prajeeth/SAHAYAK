const express = require('express');
const router = express.Router();
const partnerController = require('../controllers/partnerController');
const { authenticateToken } = require('../middleware/auth');
const { validatePartnerSearch } = require('../middleware/validation');

router.get('/', authenticateToken, partnerController.list);
router.get('/nearby', authenticateToken, validatePartnerSearch, partnerController.nearby);
router.get('/:id/eligibility', authenticateToken, partnerController.eligibility);
router.get('/:id', authenticateToken, partnerController.get);

module.exports = router;
