const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// Create new application
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { schemeId, partnerId, projectType, projectCost, loanAmount } = req.body;
        const result = await pool.query(
            `INSERT INTO applications (user_id, scheme_id, partner_id, project_type, project_cost, loan_amount, status) VALUES ($1, $2, $3, $4, $5, $6, 'draft') RETURNING id`,
            [req.userId, schemeId, partnerId, projectType, projectCost, loanAmount]
        );
        const appId = result.rows[0].id;
        await pool.query(`INSERT INTO application_status_history (application_id, stage, status, notes) VALUES ($1, 'DRAFT', 'created', 'Application drafted')`, [appId]);
        res.json({ success: true, applicationId: appId });
    } catch (error) {
        console.error('Create application error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get all applications for user
router.get('/', authenticateToken, async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT a.*, s.name as scheme_name, s.code as scheme_code, p.name as partner_name
            FROM applications a
            LEFT JOIN schemes s ON a.scheme_id = s.id
            LEFT JOIN partners p ON a.partner_id = p.id
            WHERE a.user_id = $1 ORDER BY a.created_at DESC
        `, [req.userId]);
        res.json({ success: true, applications: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get application by ID
router.get('/:id', authenticateToken, async (req, res) => {
    try {
        const appResult = await pool.query(`
            SELECT a.*, s.name as scheme_name, s.code as scheme_code, p.name as partner_name
            FROM applications a
            LEFT JOIN schemes s ON a.scheme_id = s.id
            LEFT JOIN partners p ON a.partner_id = p.id
            WHERE a.id = $1
        `, [req.params.id]);
        if (appResult.rows.length === 0) return res.status(404).json({ success: false, error: 'Application not found' });
        const history = await pool.query('SELECT * FROM application_status_history WHERE application_id = $1 ORDER BY created_at', [req.params.id]);
        res.json({ success: true, application: appResult.rows[0], history: history.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Submit application
router.post('/:id/submit', authenticateToken, async (req, res) => {
    try {
        const verify = await pool.query('SELECT user_id FROM applications WHERE id = $1', [req.params.id]);
        if (verify.rows.length === 0 || verify.rows[0].user_id !== req.userId) {
            return res.status(404).json({ success: false, error: 'Application not found' });
        }
        await pool.query(`UPDATE applications SET status = 'submitted', current_stage = 'SCA_DISTRICT', stage_updated_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE id = $1`, [req.params.id]);
        await pool.query(`INSERT INTO application_status_history (application_id, stage, status, notes) VALUES ($1, 'SCA_DISTRICT', 'submitted', 'Application submitted to SCA District Office')`, [req.params.id]);
        res.json({ success: true, message: 'Application submitted successfully' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get application status — Full 9-step disbursement chain
router.get('/:id/status', authenticateToken, async (req, res) => {
    try {
        const appResult = await pool.query(`
            SELECT a.*, s.name as scheme_name, p.name as partner_name
            FROM applications a
            LEFT JOIN schemes s ON a.scheme_id = s.id
            LEFT JOIN partners p ON a.partner_id = p.id
            WHERE a.id = $1
        `, [req.params.id]);
        if (appResult.rows.length === 0) return res.status(404).json({ success: false, error: 'Application not found' });
        const application = appResult.rows[0];
        const history = await pool.query('SELECT * FROM application_status_history WHERE application_id = $1 ORDER BY created_at', [req.params.id]);
        
        const stages = [
            { key: 'SCA_DISTRICT', label: 'SCA District Office', status: 'pending' },
            { key: 'SCA_HEAD', label: 'SCA Head Office', status: 'pending' },
            { key: 'NSFDC_DESK', label: 'NSFDC Project & Banking Desk', status: 'pending' },
            { key: 'PCC', label: 'Project Clearance Committee (PCC)', status: 'pending' },
            { key: 'CMD', label: 'Chairman-cum-Managing Director', status: 'pending' },
            { key: 'LOI', label: 'Letter of Intent (LOI) Issuance', status: 'pending' },
            { key: 'NSFDC_DISBURSEMENT', label: 'NSFDC Disbursement', status: 'pending' },
            { key: 'PARTNER_DISBURSEMENT', label: 'Channel Partner Disbursement', status: 'pending' },
            { key: 'COMPLETED', label: 'Loan Fully Disbursed', status: 'pending' }
        ];
        
        let currentStageIndex = -1;
        history.rows.forEach(entry => {
            const idx = stages.findIndex(s => s.key === entry.stage);
            if (idx !== -1) { stages[idx].status = 'completed'; if (idx > currentStageIndex) currentStageIndex = idx; }
        });
        const currentStageObj = stages.find(s => s.key === (application.current_stage || 'SCA_DISTRICT'));
        if (currentStageObj) currentStageObj.status = 'current';
        
        let rejectionInfo = null;
        if (application.status === 'rejected') {
            rejectionInfo = { reason: application.rejection_reason, category: application.rejection_category, remediation: application.remediation_steps };
        }
        
        res.json({
            success: true,
            application: { id: application.id, schemeName: application.scheme_name, partnerName: application.partner_name, status: application.status, projectCost: application.project_cost, loanAmount: application.loan_amount, currentStage: application.current_stage, createdAt: application.created_at, updatedAt: application.updated_at },
            disbursementChain: { stages, currentStage: currentStageObj || stages[0], completedStages: stages.filter(s => s.status === 'completed').length, totalStages: stages.length },
            rejectionInfo, statusHistory: history.rows
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
