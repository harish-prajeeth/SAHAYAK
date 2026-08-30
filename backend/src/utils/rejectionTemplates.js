/**
 * Rejection Templates — detailed rejection explanations with remediation
 * Used by ApplicationService to provide structured rejection responses
 */

const templates = {
    document: {
        income_certificate_expired: {
            reason: 'Income Certificate is expired (issued more than 6 months ago)',
            remediation: 'Get fresh Income Certificate from Tehsildar',
            nextSteps: 'Visit local Tehsildar office with required documents',
            impact: 'Cannot verify income-based eligibility'
        },
        caste_certificate_invalid: {
            reason: 'Caste Certificate is invalid or expired',
            remediation: 'Get valid SC caste certificate from competent authority',
            nextSteps: 'Apply through e-District portal or visit District Magistrate office',
            impact: 'Cannot verify caste category eligibility'
        },
        no_identity_proof: {
            reason: 'Valid identity proof not provided',
            remediation: 'Submit Aadhaar, Voter ID, or Passport copy',
            nextSteps: 'Upload clear copy of identity proof',
            impact: 'Application cannot proceed beyond initial review'
        },
        aadhaar_mismatch: {
            reason: 'Aadhaar verification failed — name mismatch between Aadhaar and application',
            remediation: 'Update Aadhaar details to match application. Visit nearest SCA with original Aadhaar card.',
            nextSteps: 'Bring address proof and re-verification at SCA office',
            impact: 'Blocks processing at SCA District level'
        },
        incomplete_kyc: {
            reason: 'Incomplete KYC documents — PAN card, address proof, or caste certificate missing',
            remediation: 'Gather all required KYC documents: PAN, address proof, caste certificate',
            nextSteps: 'Upload all documents before resubmission',
            impact: 'Application cannot proceed'
        }
    },
    eligibility: {
        income_exceeds_limit: {
            reason: 'Annual family income exceeds ₹5,00,000 limit',
            remediation: 'Income must be below ₹5,00,000 to be eligible',
            nextSteps: 'Check if other schemes are available for your income bracket',
            impact: 'Disqualifies from this scheme but may qualify for others',
            alternativeSchemes: [
                { name: 'Term Loan', code: 'TL', reason: 'Higher income threshold' },
                { name: 'Stand-Up India Loan', code: 'SUI', reason: 'For SC/ST and women entrepreneurs' }
            ]
        },
        not_sc_category: {
            reason: 'Applicant does not belong to Scheduled Caste category',
            remediation: 'Valid SC caste certificate required',
            nextSteps: 'Contact Social Welfare Department for assistance',
            impact: 'Cannot access SC-specific schemes'
        },
        partner_not_eligible: {
            reason: 'Selected channel partner has performance issues (high NPA rate or low fund utilization)',
            remediation: 'Select a different eligible partner with better financial health',
            nextSteps: 'Use Partner Locator to find eligible partners nearby',
            impact: 'Need to choose another channel partner'
        },
        cost_exceeds_scheme: {
            reason: 'Project cost does not fall within the eligible range for the selected scheme',
            remediation: 'Adjust project scope or apply under a different scheme',
            nextSteps: 'Use Find My Scheme tool for proper matching',
            impact: 'Application rejected due to scheme mismatch'
        }
    },
    project: {
        incomplete_business_plan: {
            reason: 'Business plan lacks financial projections, market analysis, or operational plan',
            remediation: 'Revise business plan with detailed financial projections (3-year P&L, cash flow)',
            nextSteps: 'Include market analysis and competitor study. Resubmit within 30 days.',
            impact: 'Cannot assess viability of the project'
        },
        unviable_project: {
            reason: 'Project does not demonstrate sufficient revenue potential to service loan repayment',
            remediation: 'Restructure project to improve revenue projections',
            nextSteps: 'Consult business advisor or SCA for guidance',
            impact: 'High risk of default'
        },
        duplicate_application: {
            reason: 'Similar application for same project type and location already exists',
            remediation: 'Check existing applications or contact SCA for guidance',
            nextSteps: 'If first application was withdrawn, provide evidence',
            impact: 'Application rejected to prevent fraud'
        }
    },
    partner: {
        capacity_exceeded: {
            reason: 'Selected partner has reached lending capacity limit for the current quarter',
            remediation: 'Wait for next quarter or choose another partner',
            nextSteps: 'Check partner availability through Partner Locator',
            impact: 'Temporary delay — can reapply next quarter'
        },
        geographic_restriction: {
            reason: 'Partner does not operate in your area or nearest branch is too far',
            remediation: 'Select a partner with coverage in your district',
            nextSteps: 'Use geolocation feature in Partner Locator',
            impact: 'Cannot process application from your location'
        }
    }
};

/**
 * Get a rejection template by category and optional code
 */
function getRejectionTemplate(category, code) {
    if (code && templates[category]?.[code]) {
        return templates[category][code];
    }
    // Return first template for category as fallback
    const categoryTemplates = templates[category];
    if (categoryTemplates) {
        const firstKey = Object.keys(categoryTemplates)[0];
        return categoryTemplates[firstKey];
    }
    return null;
}

/**
 * Get all rejection categories with their codes
 */
function getRejectionCategories() {
    return Object.keys(templates).map(category => ({
        category,
        codes: Object.keys(templates[category])
    }));
}

module.exports = { templates, getRejectionTemplate, getRejectionCategories };
