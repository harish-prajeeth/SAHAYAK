const applicationService = require('../services/applicationService');

exports.create = async (req, res) => {
    try {
        const applicationId = await applicationService.createApplication(req.userId, req.body);
        res.json({ success: true, applicationId });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.list = async (req, res) => {
    try {
        const applications = await applicationService.getUserApplications(req.userId);
        res.json({ success: true, applications });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.get = async (req, res) => {
    try {
        const applications = await applicationService.getUserApplications(req.userId);
        const app = applications.find(a => a.id === parseInt(req.params.id));
        if (!app) return res.status(404).json({ success: false, error: 'Application not found' });
        res.json({ success: true, application: app });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.submit = async (req, res) => {
    try {
        const result = await applicationService.submitApplication(parseInt(req.params.id), req.userId);
        res.json({ success: true, message: 'Application submitted successfully', ...result });
    } catch (error) {
        res.status(error.message === 'Unauthorized' ? 403 : 500).json({ success: false, error: error.message });
    }
};

exports.status = async (req, res) => {
    try {
        const result = await applicationService.getApplicationStatus(parseInt(req.params.id), req.userId);
        res.json({ success: true, ...result });
    } catch (error) {
        res.status(error.message === 'Application not found' ? 404 : 500).json({ success: false, error: error.message });
    }
};

exports.rejectionExplainer = async (req, res) => {
    try {
        const result = await applicationService.getRejectionExplainer(parseInt(req.params.id), req.userId);
        res.json({ success: true, ...result });
    } catch (error) {
        res.status(error.message === 'Application not found' ? 404 : 500).json({ success: false, error: error.message });
    }
};
