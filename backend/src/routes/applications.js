const express = require('express');
const router = express.Router();
const applicationController = require('../controllers/applicationController');
const { authenticateToken } = require('../middleware/auth');
const { validateApplication } = require('../middleware/validation');

router.post('/', authenticateToken, validateApplication, applicationController.create);
router.get('/', authenticateToken, applicationController.list);
router.get('/:id', authenticateToken, applicationController.get);
router.post('/:id/submit', authenticateToken, applicationController.submit);
router.get('/:id/status', authenticateToken, applicationController.status);
router.get('/:id/rejection-explainer', authenticateToken, applicationController.rejectionExplainer);

module.exports = router;
