const db = require('../config/database');

/**
 * Rule-Based Recommendation Engine
 */
function ruleBasedRecommendation(input) {
    const { projectType, projectCost, businessType, preferredChannel } = input;
    
    // EDUCATION SCHEMES
    if (projectType === 'Education') {
        return {
            scheme: 'Educational Loan Scheme',
            code: 'ELS',
            matchScore: 95,
            rationale: 'This is an education loan. ELS offers up to ₹40 lakh at 6.5% interest with 12-year repayment.'
        };
    }
    
    // BUSINESS / SKILL DEVELOPMENT / AGRICULTURE
    if (['Business', 'Skill Development', 'Agriculture'].includes(projectType)) {
        const isExisting = businessType === 'Existing';
        const businessNote = isExisting ? 
            'PM-SURAJ is only for new startups. Surakshit supports existing businesses.' : '';
        
        if (projectCost <= 140000) {
            if (preferredChannel === 'Bank') {
                return {
                    scheme: 'Micro Finance Scheme',
                    code: 'MFS',
                    matchScore: 90,
                    rationale: `Your project cost (₹${projectCost}) is within Micro Finance limit.`,
                    note: businessNote
                };
            } else if (preferredChannel === 'NBFC-MFI') {
                return {
                    scheme: 'Aajeevika Microfinance Yojana',
                    code: 'AMY',
                    matchScore: 85,
                    rationale: `NBFC-MFI channel selected. AMY offers 15% interest.`,
                    note: businessNote
                };
            } else {
                return {
                    scheme: 'Micro Finance Scheme',
                    code: 'MFS',
                    matchScore: 80,
                    alternatives: [
                        { scheme: 'Aajeevika Microfinance Yojana', code: 'AMY', rate: '15%' }
                    ],
                    rationale: 'Multiple options available for your project size.',
                    note: businessNote
                };
            }
        } else if (projectCost > 140000 && projectCost <= 5000000) {
            return {
                scheme: 'Term Loan',
                code: 'TL',
                matchScore: 95,
                rationale: `Your project cost (₹${projectCost}) qualifies for Term Loan up to ₹45 lakh at 8% interest.`,
                note: businessNote
            };
        } else if (projectCost > 5000000) {
            return {
                error: true,
                message: 'Project cost exceeds maximum limit of ₹50 lakh. Please consult your nearest SCA for assistance.'
            };
        }
    }
    
    return {
        error: true,
        message: 'No scheme matches your criteria. Please consult nearest SCA for guidance.'
    };
}

/**
 * ML-Based Approval Probability Simulation
 */
function simulateMLApproval(input) {
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

/**
 * Main Recommendation Function
 */
async function getRecommendation(userInput) {
    const ruleResult = ruleBasedRecommendation(userInput);
    
    if (ruleResult.error) {
        return { error: ruleResult.message };
    }
    
    const scheme = db.prepare('SELECT * FROM schemes WHERE code = ?').get(ruleResult.code);
    const mlScore = simulateMLApproval(userInput);
    
    return {
        primary: {
            scheme: ruleResult.scheme,
            code: ruleResult.code,
            matchScore: ruleResult.matchScore,
            approvalProbability: mlScore,
            details: scheme || null,
            rationale: ruleResult.rationale,
            note: ruleResult.note || null
        },
        alternatives: ruleResult.alternatives || [],
        userInput: userInput
    };
}

module.exports = { getRecommendation };
