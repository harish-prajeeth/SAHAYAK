const authService = require('../services/authService');

exports.register = async (req, res) => {
    try {
        const { user, token } = await authService.register(req.body);
        res.json({ success: true, token, user });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(error.message.includes('already exists') ? 400 : error.message.includes('Income') ? 400 : 500)
            .json({ success: false, error: error.message });
    }
};

exports.login = async (req, res) => {
    try {
        const { aadhaar_hash } = req.body;
        const { user, token } = await authService.login(aadhaar_hash);
        res.json({ success: true, token, user });
    } catch (error) {
        console.error('Login error:', error);
        res.status(error.message === 'User not found' ? 401 : 500)
            .json({ success: false, error: error.message });
    }
};

exports.getUser = async (req, res) => {
    try {
        const user = await authService.getUser(req.userId);
        res.json({ success: true, user });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
