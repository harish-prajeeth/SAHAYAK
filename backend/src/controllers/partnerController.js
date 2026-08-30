const partnerService = require('../services/partnerService');

exports.list = async (req, res) => {
    try {
        const partners = await partnerService.getAllPartners();
        res.json({ success: true, partners });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.nearby = async (req, res) => {
    try {
        const { lat, lng, scheme, limit } = req.query;
        const partners = await partnerService.findNearestPartners(parseFloat(lat), parseFloat(lng), scheme, parseInt(limit) || 5);
        res.json({ success: true, partners });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.get = async (req, res) => {
    try {
        const partner = await partnerService.getPartnerById(parseInt(req.params.id));
        if (!partner) return res.status(404).json({ success: false, error: 'Partner not found' });
        res.json({ success: true, partner });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.eligibility = async (req, res) => {
    try {
        const partner = await partnerService.checkPartnerEligibility(parseInt(req.params.id));
        if (!partner) return res.status(404).json({ success: false, error: 'Partner not found' });
        res.json({ success: true, partner });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
