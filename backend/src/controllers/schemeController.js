const schemeService = require('../services/schemeService');

exports.list = async (req, res) => {
    try {
        const schemes = await schemeService.getAllSchemes();
        res.json({ success: true, schemes });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.get = async (req, res) => {
    try {
        const scheme = await schemeService.getSchemeByCode(req.params.code);
        if (!scheme) return res.status(404).json({ success: false, error: 'Scheme not found' });
        res.json({ success: true, scheme });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.recommend = async (req, res) => {
    try {
        const recommendation = await schemeService.getRecommendation(req.body);
        res.json({ success: true, recommendation });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.compare = async (req, res) => {
    try {
        const { codes } = req.body;
        if (!codes || !Array.isArray(codes)) {
            return res.status(400).json({ success: false, error: 'Codes array is required' });
        }
        const schemes = await schemeService.getSchemesForComparison(codes);
        res.json({ success: true, schemes });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
