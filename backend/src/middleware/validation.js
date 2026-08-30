/**
 * Request validation middleware
 */
function validateRegistration(req, res, next) {
    const { aadhaar_hash, name, email } = req.body;
    const errors = [];

    if (!aadhaar_hash || aadhaar_hash.trim().length === 0) errors.push('Aadhaar hash is required');
    if (!name || name.trim().length < 2) errors.push('Name must be at least 2 characters');
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) errors.push('Valid email is required');

    if (req.body.income && req.body.income > 500000) {
        errors.push('Income exceeds eligibility limit of ₹5,00,000');
    }

    if (errors.length > 0) {
        return res.status(400).json({ success: false, error: errors.join(', ') });
    }
    next();
}

function validateRecommendation(req, res, next) {
    const { projectType, projectCost } = req.body;
    const errors = [];

    if (!projectType) errors.push('Project type is required');
    if (!projectCost || projectCost <= 0) errors.push('Valid project cost is required');
    if (projectCost > 10000000) errors.push('Project cost exceeds maximum limit of ₹1 crore');

    if (errors.length > 0) {
        return res.status(400).json({ success: false, error: errors.join(', ') });
    }
    next();
}

function validateCalculator(req, res, next) {
    const { principal, interestRate, tenureMonths } = req.body;
    const errors = [];

    if (!principal || principal <= 0) errors.push('Principal must be positive');
    if (interestRate === undefined || interestRate < 0) errors.push('Interest rate must be non-negative');
    if (!tenureMonths || tenureMonths <= 0) errors.push('Tenure must be positive');
    if (interestRate > 30) errors.push('Interest rate seems unreasonably high');

    if (errors.length > 0) {
        return res.status(400).json({ success: false, error: errors.join(', ') });
    }
    next();
}

function validatePartnerSearch(req, res, next) {
    const { lat, lng, scheme } = req.query;
    const errors = [];

    if (!lat || isNaN(parseFloat(lat))) errors.push('Valid latitude is required');
    if (!lng || isNaN(parseFloat(lng))) errors.push('Valid longitude is required');
    if (!scheme) errors.push('Scheme code is required');

    if (errors.length > 0) {
        return res.status(400).json({ success: false, error: errors.join(', ') });
    }
    next();
}

function validateApplication(req, res, next) {
    const { schemeId, projectType, projectCost, loanAmount } = req.body;
    const errors = [];

    if (!schemeId) errors.push('Scheme is required');
    if (!projectType) errors.push('Project type is required');
    if (!projectCost || projectCost <= 0) errors.push('Valid project cost is required');
    if (!loanAmount || loanAmount <= 0) errors.push('Valid loan amount is required');
    if (loanAmount > projectCost) errors.push('Loan amount cannot exceed project cost');

    if (errors.length > 0) {
        return res.status(400).json({ success: false, error: errors.join(', ') });
    }
    next();
}

module.exports = {
    validateRegistration,
    validateRecommendation,
    validateCalculator,
    validatePartnerSearch,
    validateApplication
};
