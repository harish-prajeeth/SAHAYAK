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

// Rejection Explainer — detailed reasons, categories, and remediation
router.get('/:id/rejection-explainer', authenticateToken, async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT a.*, s.name as scheme_name, s.code as scheme_code, s.description as scheme_desc,
                   p.name as partner_name, p.type as partner_type
            FROM applications a
            LEFT JOIN schemes s ON a.scheme_id = s.id
            LEFT JOIN partners p ON a.partner_id = p.id
            WHERE a.id = $1
        `, [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ success: false, error: 'Application not found' });
        const app = result.rows[0];

        if (app.status !== 'rejected') {
            return res.json({ success: true, rejected: false, message: 'This application has not been rejected.' });
        }

        // Build detailed rejection explanation
        const categoryLabels = {
            document: { label: 'Document Issue', icon: '📄', severity: 'medium', color: '#f59e0b' },
            eligibility: { label: 'Eligibility Issue', icon: '⚠️', severity: 'high', color: '#ef4444' },
            project: { label: 'Project/Proposal Issue', icon: '📋', severity: 'medium', color: '#f97316' },
            partner: { label: 'Partner Issue', icon: '🏦', severity: 'low', color: '#3b82f6' },
        };

        const cat = categoryLabels[app.rejection_category] || categoryLabels.project;

        // Common rejection reasons mapped to explanations
        const commonRejections = {
            document: [
                { reason: 'Aadhaar verification failed', explanation: 'Your Aadhaar details do not match the information in the application. This could be due to a name mismatch, address discrepancy, or expired Aadhaar.', impact: 'Blocks processing at SCA District level' },
                { reason: 'Missing income certificate', explanation: 'An income certificate from the competent authority is required to verify your family income for scheme eligibility.', impact: 'Cannot verify income-based eligibility' },
                { reason: 'Incomplete KYC documents', explanation: 'PAN card, address proof, or caste certificate are missing or expired.', impact: 'Application cannot proceed beyond initial review' },
            ],
            eligibility: [
                { reason: 'Income exceeds threshold', explanation: `Your annual family income exceeds the maximum limit for the ${app.scheme_name || 'selected'} scheme. Different schemes have different income caps.`, impact: 'Disqualifies from this scheme but may qualify for others' },
                { reason: 'Partner not eligible', explanation: 'The selected channel partner has performance issues (high NPA rate or low fund utilization) that prevent them from processing new loans.', impact: 'Need to select a different eligible partner' },
                { reason: 'Project cost out of range', explanation: `Your project cost of ₹${app.project_cost} does not fall within the eligible range for ${app.scheme_name || 'this scheme'}.`, impact: 'Need to adjust project scope or apply under a different scheme' },
            ],
            project: [
                { reason: 'Incomplete business plan', explanation: 'The project proposal lacks essential components: financial projections, market analysis, or operational plan.', impact: 'Cannot assess viability of the project' },
                { reason: 'Unviable project', explanation: 'The project does not demonstrate sufficient revenue potential to service the loan repayment.', impact: 'High risk of default — project needs restructuring' },
                { reason: 'Duplicate application', explanation: 'A similar application for the same project type and location already exists in the system.', impact: 'Application rejected to prevent fraud' },
            ],
            partner: [
                { reason: 'Partner capacity exceeded', explanation: 'The selected partner has reached their lending capacity limit for the current quarter.', impact: 'Wait for next quarter or choose another partner' },
                { reason: 'Geographic restriction', explanation: 'The partner does not operate in your area or the nearest branch is too far.', impact: 'Select a partner with coverage in your district' },
            ],
        };

        const categoryReasons = commonRejections[app.rejection_category] || commonRejections.project;
        const matchedReason = categoryReasons.find(r => app.rejection_reason?.includes(r.reason)) || categoryReasons[0];

        // Generate action items
        const actionItems = [];
        if (app.rejection_category === 'document') {
            actionItems.push('Gather all required documents (Aadhaar, PAN, income certificate, caste certificate)');
            actionItems.push('Verify name and address match across all documents');
            actionItems.push('Visit nearest SCA office for document re-verification');
        } else if (app.rejection_category === 'eligibility') {
            actionItems.push('Check your eligibility under alternative schemes');
            actionItems.push('Use the "Find My Scheme" tool to discover matching schemes');
            actionItems.push('Consult with the SCA helpline for guidance');
        } else if (app.rejection_category === 'project') {
            actionItems.push('Revise your business plan with detailed financial projections');
            actionItems.push('Include 3-year P&L forecast and cash flow statement');
            actionItems.push('Add market analysis and competitor study');
            actionItems.push('Resubmit within 30 days of rejection');
        }

        res.json({
            success: true,
            rejected: true,
            applicationId: app.id,
            schemeName: app.scheme_name,
            partnerName: app.partner_name,
            rejection: {
                reason: app.rejection_reason,
                category: app.rejection_category,
                categoryInfo: cat,
                detailedExplanation: matchedReason?.explanation || app.rejection_reason,
                impact: matchedReason?.impact || 'Application cannot proceed',
                remediationSteps: app.remediation_steps,
                actionItems,
                resubmissionDeadline: '30 days from rejection date',
                helpline: '1800-XXX-XXXX (NSFDC Toll Free)',
                alternativeSchemes: app.rejection_category === 'eligibility' ? [
                    { name: 'Term Loan', code: 'TL', reason: 'Higher income threshold' },
                    { name: 'Stand-Up India Loan', code: 'SUI', reason: 'For SC/ST and women entrepreneurs' },
                ] : []
            }
        });
    } catch (error) {
        console.error('Rejection explainer error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
