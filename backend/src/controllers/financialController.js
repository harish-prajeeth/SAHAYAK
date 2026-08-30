const financialService = require('../services/financialService');

exports.calculate = (req, res) => {
    try {
        const { principal, interestRate, tenureMonths, moratoriumMonths } = req.body;
        const result = financialService.calculateAmortization(principal, interestRate, tenureMonths, moratoriumMonths || 0);
        res.json({ success: true, calculation: result });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.compare = (req, res) => {
    try {
        const { scenarios } = req.body;
        if (!scenarios || !Array.isArray(scenarios)) {
            return res.status(400).json({ success: false, error: 'Scenarios array is required' });
        }
        const comparisons = financialService.compareSchemes(scenarios);
        res.json({ success: true, comparisons });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.visvasSubvention = (req, res) => {
    try {
        const { principal, interestRate, tenureMonths, isSHG } = req.body;
        const result = financialService.calculateVISVASSubvention(principal, interestRate, tenureMonths, isSHG);
        res.json({ success: true, subvention: result });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
