const pool = require('../config/database');
const { STAGES, STAGE_LABELS } = require('../utils/constants');
const { getRejectionTemplate } = require('../utils/rejectionTemplates');

class ApplicationService {
    async createApplication(userId, data) {
        const { schemeId, partnerId, projectType, projectCost, loanAmount } = data;
        const result = await pool.query(
            `INSERT INTO applications (user_id, scheme_id, partner_id, project_type, project_cost, loan_amount, status)
             VALUES ($1, $2, $3, $4, $5, $6, 'draft') RETURNING id`,
            [userId, schemeId, partnerId, projectType, projectCost, loanAmount]
        );
        const appId = result.rows[0].id;
        await pool.query(`INSERT INTO application_status_history (application_id, stage, status, notes) VALUES ($1, 'DRAFT', 'created', 'Application drafted')`, [appId]);
        return appId;
    }

    async submitApplication(applicationId, userId) {
        const verify = await pool.query('SELECT user_id FROM applications WHERE id = $1', [applicationId]);
        if (verify.rows.length === 0 || verify.rows[0].user_id !== userId) throw new Error('Unauthorized');

        await pool.query(`UPDATE applications SET status = 'submitted', current_stage = 'SCA_DISTRICT', stage_updated_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE id = $1`, [applicationId]);
        await pool.query(`INSERT INTO application_status_history (application_id, stage, status, notes) VALUES ($1, 'SCA_DISTRICT', 'submitted', 'Application submitted to SCA District Office')`, [applicationId]);
        return { applicationId, currentStage: 'SCA_DISTRICT' };
    }

    async getApplicationStatus(applicationId, userId) {
        const appResult = await pool.query(
            `SELECT a.*, s.name as scheme_name, s.code as scheme_code, p.name as partner_name
             FROM applications a LEFT JOIN schemes s ON a.scheme_id = s.id LEFT JOIN partners p ON a.partner_id = p.id
             WHERE a.id = $1 AND a.user_id = $2`, [applicationId, userId]
        );
        if (appResult.rows.length === 0) throw new Error('Application not found');
        const application = appResult.rows[0];

        const historyResult = await pool.query('SELECT * FROM application_status_history WHERE application_id = $1 ORDER BY created_at ASC', [applicationId]);

        const stages = STAGES.map(s => ({ ...s, status: 'pending' }));
        historyResult.rows.forEach(entry => {
            const idx = stages.findIndex(s => s.key === entry.stage);
            if (idx !== -1) stages[idx].status = 'completed';
        });

        const currentStage = application.current_stage || 'SCA_DISTRICT';
        const currentStageObj = stages.find(s => s.key === currentStage) || stages[0];
        currentStageObj.status = 'current';

        let rejectionInfo = null;
        if (application.status === 'rejected') {
            rejectionInfo = { reason: application.rejection_reason, category: application.rejection_category, remediation: application.remediation_steps };
        }

        return {
            application: { id: application.id, schemeName: application.scheme_name, partnerName: application.partner_name, status: application.status, projectCost: application.project_cost, loanAmount: application.loan_amount, currentStage: application.current_stage, createdAt: application.created_at, updatedAt: application.updated_at },
            disbursementChain: { stages, currentStage: currentStageObj, completedStages: stages.filter(s => s.status === 'completed').length, totalStages: stages.length },
            rejectionInfo, statusHistory: historyResult.rows
        };
    }

    async getRejectionExplainer(applicationId, userId) {
        const result = await pool.query(
            `SELECT a.*, s.name as scheme_name, s.code as scheme_code, p.name as partner_name, p.type as partner_type
             FROM applications a LEFT JOIN schemes s ON a.scheme_id = s.id LEFT JOIN partners p ON a.partner_id = p.id
             WHERE a.id = $1`, [applicationId]
        );
        if (result.rows.length === 0) throw new Error('Application not found');
        const app = result.rows[0];

        if (app.status !== 'rejected') {
            return { rejected: false, message: 'This application has not been rejected.' };
        }

        const categoryLabels = {
            document: { label: 'Document Issue', icon: '📄', severity: 'medium' },
            eligibility: { label: 'Eligibility Issue', icon: '⚠️', severity: 'high' },
            project: { label: 'Project/Proposal Issue', icon: '📋', severity: 'medium' },
            partner: { label: 'Partner Issue', icon: '🏦', severity: 'low' }
        };
        const cat = categoryLabels[app.rejection_category] || categoryLabels.project;

        const template = getRejectionTemplate(app.rejection_category);

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
        } else if (app.rejection_category === 'partner') {
            actionItems.push('Select a different channel partner');
            actionItems.push('Use the Partner Locator to find eligible partners nearby');
        }

        return {
            rejected: true, applicationId: app.id, schemeName: app.scheme_name, partnerName: app.partner_name,
            rejection: {
                reason: app.rejection_reason, category: app.rejection_category, categoryInfo: cat,
                detailedExplanation: template?.reason || app.rejection_reason,
                impact: template?.impact || 'Application cannot proceed',
                remediationSteps: app.remediation_steps, actionItems,
                resubmissionDeadline: '30 days from rejection date',
                helpline: '1800-XXX-XXXX (NSFDC Toll Free)',
                alternativeSchemes: template?.alternativeSchemes || (app.rejection_category === 'eligibility' ? [
                    { name: 'Term Loan', code: 'TL', reason: 'Higher income threshold' },
                    { name: 'Stand-Up India Loan', code: 'SUI', reason: 'For SC/ST and women entrepreneurs' }
                ] : [])
            }
        };
    }

    async getUserApplications(userId) {
        const result = await pool.query(
            `SELECT a.*, s.name as scheme_name, s.code as scheme_code, p.name as partner_name
             FROM applications a LEFT JOIN schemes s ON a.scheme_id = s.id LEFT JOIN partners p ON a.partner_id = p.id
             WHERE a.user_id = $1 ORDER BY a.created_at DESC`, [userId]
        );
        return result.rows;
    }
}

module.exports = new ApplicationService();
