const pool = require('../config/database');
const { cacheGet, cacheSet } = require('../config/redis');

class SchemeService {
    async getAllSchemes() {
        const cached = await cacheGet('schemes:all');
        if (cached) return cached;

        const result = await pool.query('SELECT * FROM schemes WHERE is_active = true ORDER BY min_cost ASC');
        await cacheSet('schemes:all', result.rows, 3600);
        return result.rows;
    }

    async getSchemeByCode(code) {
        const result = await pool.query('SELECT * FROM schemes WHERE code = $1', [code]);
        return result.rows[0] || null;
    }

    async getSchemesForComparison(codes) {
        const result = await pool.query('SELECT * FROM schemes WHERE code = ANY($1)', [codes]);
        return result.rows;
    }

    ruleBasedRecommendation(input) {
        const { projectType, projectCost, businessType, preferredChannel } = input;

        if (projectType === 'Education') {
            return {
                scheme: 'Educational Loan Scheme', code: 'ELS', matchScore: 95,
                rationale: 'This is an education loan. ELS offers up to ₹40 lakh at 6.5% interest with 12-year repayment.'
            };
        }

        if (['Business', 'Skill Development', 'Agriculture'].includes(projectType)) {
            const isExisting = businessType === 'Existing';
            const businessNote = isExisting ? 'PM-SURAJ is only for new startups. Surakshit supports existing businesses.' : '';

            if (projectCost <= 140000) {
                if (preferredChannel === 'Bank') {
                    return { scheme: 'Micro Finance Scheme', code: 'MFS', matchScore: 90, rationale: `Your project cost (₹${projectCost}) is within Micro Finance limit.`, note: businessNote };
                } else if (preferredChannel === 'NBFC-MFI') {
                    return { scheme: 'Aajeevika Microfinance Yojana', code: 'AMY', matchScore: 85, rationale: `NBFC-MFI channel selected. AMY offers 15% interest.`, note: businessNote };
                } else {
                    return { scheme: 'Micro Finance Scheme', code: 'MFS', matchScore: 80, alternatives: [{ scheme: 'Aajeevika Microfinance Yojana', code: 'AMY', rate: '15%' }], rationale: 'Multiple options available for your project size.', note: businessNote };
                }
            } else if (projectCost > 140000 && projectCost <= 5000000) {
                return { scheme: 'Term Loan', code: 'TL', matchScore: 95, rationale: `Your project cost (₹${projectCost}) qualifies for Term Loan up to ₹45 lakh at 8% interest.`, note: businessNote };
            } else if (projectCost > 5000000) {
                return { error: true, message: 'Project cost exceeds maximum limit of ₹50 lakh. Please consult your nearest SCA for assistance.' };
            }
        }

        return { error: true, message: 'No scheme matches your criteria. Please consult nearest SCA for guidance.' };
    }

    calculateApprovalProbability(input) {
        let score = 70;
        if (input.income < 200000) score += 20;
        else if (input.income < 300000) score += 15;
        else if (input.income < 400000) score += 10;
        else if (input.income < 500000) score += 5;
        if (input.education === 'Post-Graduate') score += 15;
        else if (input.education === 'Graduate') score += 10;
        else if (input.education === 'Secondary') score += 5;
        if (input.projectCost < 200000) score += 10;
        else if (input.projectCost < 500000) score += 5;
        if (input.businessType === 'Existing') score -= 5;
        if (input.preferredChannel === 'Bank') score += 5;
        return Math.min(Math.max(score, 30), 98);
    }

    async getRecommendation(userInput) {
        const ruleResult = this.ruleBasedRecommendation(userInput);
        if (ruleResult.error) return { error: ruleResult.message };

        const schemeResult = await pool.query('SELECT * FROM schemes WHERE code = $1', [ruleResult.code]);
        const mlScore = this.calculateApprovalProbability(userInput);

        return {
            primary: {
                scheme: ruleResult.scheme, code: ruleResult.code, matchScore: ruleResult.matchScore,
                approvalProbability: mlScore, details: schemeResult.rows[0] || null,
                rationale: ruleResult.rationale, note: ruleResult.note || null
            },
            alternatives: ruleResult.alternatives || [], userInput
        };
    }
}

module.exports = new SchemeService();
