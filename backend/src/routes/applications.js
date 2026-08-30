const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// Create new application
router.post('/', authenticateToken, (req, res) => {
    try {
        const { schemeId, partnerId, projectType, projectCost, loanAmount } = req.body;
        const userId = req.userId;
        
        const result = db.prepare(
            `INSERT INTO applications (user_id, scheme_id, partner_id, project_type, project_cost, loan_amount, status) 
             VALUES (?, ?, ?, ?, ?, ?, 'draft')`
        ).run(userId, schemeId, partnerId, projectType, projectCost, loanAmount);
        
        const appId = result.lastInsertRowid;
        
        db.prepare(
            `INSERT INTO application_status_history (application_id, stage, status, notes) 
             VALUES (?, 'DRAFT', 'created', 'Application drafted')`
        ).run(appId);
        
        res.json({ success: true, applicationId: appId });
    } catch (error) {
        console.error('Create application error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get all applications for user
router.get('/', authenticateToken, (req, res) => {
    try {
        const applications = db.prepare(`
            SELECT a.*, s.name as scheme_name, s.code as scheme_code,
                   p.name as partner_name
            FROM applications a
            LEFT JOIN schemes s ON a.scheme_id = s.id
            LEFT JOIN partners p ON a.partner_id = p.id
            WHERE a.user_id = ?
            ORDER BY a.created_at DESC
        `).all(req.userId);
        
        res.json({ success: true, applications });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get application by ID
router.get('/:id', authenticateToken, (req, res) => {
    try {
        const application = db.prepare(`
            SELECT a.*, s.name as scheme_name, s.code as scheme_code,
                   p.name as partner_name
            FROM applications a
            LEFT JOIN schemes s ON a.scheme_id = s.id
            LEFT JOIN partners p ON a.partner_id = p.id
            WHERE a.id = ?
        `).get(req.params.id);
        
        if (!application) {
            return res.status(404).json({ success: false, error: 'Application not found' });
        }
        
        const history = db.prepare(
            'SELECT * FROM application_status_history WHERE application_id = ? ORDER BY created_at'
        ).all(req.params.id);
        
        res.json({ success: true, application, history });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Submit application
router.post('/:id/submit', authenticateToken, (req, res) => {
    try {
        const application = db.prepare(
            'SELECT * FROM applications WHERE id = ? AND user_id = ?'
        ).get(req.params.id, req.userId);
        
        if (!application) {
            return res.status(404).json({ success: false, error: 'Application not found' });
        }
        
        db.prepare(
            `UPDATE applications SET status = 'submitted', current_stage = 'SCA_DISTRICT', 
             stage_updated_at = datetime('now'), updated_at = datetime('now') WHERE id = ?`
        ).run(req.params.id);
        
        db.prepare(
            `INSERT INTO application_status_history (application_id, stage, status, notes) 
             VALUES (?, 'SCA_DISTRICT', 'submitted', 'Application submitted to SCA District Office')`
        ).run(req.params.id);
        
        res.json({ success: true, message: 'Application submitted successfully' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get application status — Full 9-step disbursement chain (per spec Section 3.7)
router.get('/:id/status', authenticateToken, (req, res) => {
    try {
        const application = db.prepare(`
            SELECT a.*, s.name as scheme_name, p.name as partner_name
            FROM applications a
            LEFT JOIN schemes s ON a.scheme_id = s.id
            LEFT JOIN partners p ON a.partner_id = p.id
            WHERE a.id = ?
        `).get(req.params.id);
        
        if (!application) {
            return res.status(404).json({ success: false, error: 'Application not found' });
        }
        
        const history = db.prepare(
            'SELECT * FROM application_status_history WHERE application_id = ? ORDER BY created_at'
        ).all(req.params.id);
        
        // Build full disbursement chain (9 steps per spec)
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
        
        // Mark completed stages based on history
        let currentStageIndex = -1;
        history.forEach(entry => {
            const stageIndex = stages.findIndex(s => s.key === entry.stage);
            if (stageIndex !== -1) {
                stages[stageIndex].status = 'completed';
                if (stageIndex > currentStageIndex) currentStageIndex = stageIndex;
            }
        });
        
        // Mark current stage
        const currentStage = application.current_stage || 'SCA_DISTRICT';
        const currentStageObj = stages.find(s => s.key === currentStage);
        if (currentStageObj) currentStageObj.status = 'current';
        
        // Rejection info if applicable
        let rejectionInfo = null;
        if (application.status === 'rejected') {
            rejectionInfo = {
                reason: application.rejection_reason,
                category: application.rejection_category,
                remediation: application.remediation_steps
            };
        }
        
        res.json({
            success: true,
            application: {
                id: application.id,
                schemeName: application.scheme_name,
                partnerName: application.partner_name,
                status: application.status,
                projectCost: application.project_cost,
                loanAmount: application.loan_amount,
                currentStage: application.current_stage,
                createdAt: application.created_at,
                updatedAt: application.updated_at
            },
            disbursementChain: {
                stages: stages,
                currentStage: currentStageObj || stages[0],
                completedStages: stages.filter(s => s.status === 'completed').length,
                totalStages: stages.length
            },
            rejectionInfo,
            statusHistory: history
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
