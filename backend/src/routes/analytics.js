const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// Dashboard analytics — aggregated stats for monitoring
router.get('/dashboard', authenticateToken, async (req, res) => {
    try {
        // Total counts
        const [usersResult, schemesResult, partnersResult, appsResult] = await Promise.all([
            pool.query('SELECT COUNT(*) as total FROM users'),
            pool.query('SELECT COUNT(*) as total FROM schemes WHERE is_active = true'),
            pool.query('SELECT COUNT(*) as total FROM partners'),
            pool.query('SELECT COUNT(*) as total FROM applications'),
        ]);

        // Application status breakdown
        const statusBreakdown = await pool.query(`
            SELECT status, COUNT(*) as count 
            FROM applications 
            GROUP BY status
        `);

        // Applications by scheme
        const byScheme = await pool.query(`
            SELECT s.name, s.code, COUNT(a.id) as count
            FROM applications a
            JOIN schemes s ON a.scheme_id = s.id
            GROUP BY s.name, s.code
            ORDER BY count DESC
        `);

        // Applications by project type
        const byProjectType = await pool.query(`
            SELECT project_type, COUNT(*) as count, 
                   ROUND(AVG(project_cost)::numeric, 0) as avg_cost,
                   ROUND(AVG(loan_amount)::numeric, 0) as avg_loan
            FROM applications
            GROUP BY project_type
        `);

        // Partner type distribution
        const partnerTypes = await pool.query(`
            SELECT type, COUNT(*) as count, 
                   ROUND(AVG(fund_utilization)::numeric, 1) as avg_fund_util,
                   ROUND(AVG(npa_rate)::numeric, 1) as avg_npa,
                   SUM(CASE WHEN is_eligible THEN 1 ELSE 0 END) as eligible_count
            FROM partners
            GROUP BY type
        `);

        // Rejection analysis
        const rejections = await pool.query(`
            SELECT rejection_category, COUNT(*) as count,
                   ARRAY_AGG(DISTINCT rejection_reason) as reasons
            FROM applications
            WHERE status = 'rejected' AND rejection_category IS NOT NULL
            GROUP BY rejection_category
        `);

        // Monthly application trend (last 6 months)
        const trend = await pool.query(`
            SELECT TO_CHAR(created_at, 'YYYY-MM') as month,
                   COUNT(*) as count,
                   SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
                   SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected
            FROM applications
            WHERE created_at >= NOW() - INTERVAL '6 months'
            GROUP BY TO_CHAR(created_at, 'YYYY-MM')
            ORDER BY month
        `);

        // Top performing partners (by fund utilization, eligible only)
        const topPartners = await pool.query(`
            SELECT name, type, fund_utilization, npa_rate
            FROM partners
            WHERE is_eligible = true
            ORDER BY fund_utilization DESC
            LIMIT 5
        `);

        // Disbursement pipeline summary
        const pipeline = await pool.query(`
            SELECT current_stage, COUNT(*) as count
            FROM applications
            WHERE status IN ('submitted', 'under_review', 'approved')
            GROUP BY current_stage
            ORDER BY 
                CASE current_stage
                    WHEN 'SCA_DISTRICT' THEN 1
                    WHEN 'SCA_HEAD' THEN 2
                    WHEN 'NSFDC_DESK' THEN 3
                    WHEN 'PCC' THEN 4
                    WHEN 'CMD' THEN 5
                    WHEN 'LOI' THEN 6
                    WHEN 'NSFDC_DISBURSEMENT' THEN 7
                    WHEN 'PARTNER_DISBURSEMENT' THEN 8
                    WHEN 'COMPLETED' THEN 9
                    ELSE 0
                END
        `);

        const statusMap = {};
        statusBreakdown.rows.forEach(r => { statusMap[r.status] = parseInt(r.count); });

        res.json({
            success: true,
            analytics: {
                overview: {
                    totalUsers: parseInt(usersResult.rows[0].total),
                    totalSchemes: parseInt(schemesResult.rows[0].total),
                    totalPartners: parseInt(partnersResult.rows[0].total),
                    totalApplications: parseInt(appsResult.rows[0].total),
                    approvalRate: statusMap.approved 
                        ? Math.round((statusMap.approved / (statusMap.approved + (statusMap.rejected || 0))) * 100)
                        : 0,
                    disbursementRate: statusMap.disbursed
                        ? Math.round((statusMap.disbursed / parseInt(appsResult.rows[0].total)) * 100)
                        : 0,
                },
                statusBreakdown: statusMap,
                byScheme: byScheme.rows,
                byProjectType: byProjectType.rows,
                partnerTypes: partnerTypes.rows,
                rejectionAnalysis: rejections.rows,
                monthlyTrend: trend.rows,
                topPartners: topPartners.rows,
                disbursementPipeline: pipeline.rows,
            }
        });
    } catch (error) {
        console.error('Analytics error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
