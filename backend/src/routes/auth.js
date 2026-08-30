const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { validateRegistration } = require('../middleware/validation');
const { authenticateToken } = require('../middleware/auth');

router.post('/register', validateRegistration, authController.register);
router.post('/login', authController.login);
router.get('/me', authenticateToken, authController.getUser);

module.exports = router;
