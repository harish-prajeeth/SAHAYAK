const financialService = require('../services/financialService');

exports.calculate = (req, res) => {
    try {
        const { principal, interestRate, tenureMonths, moratoriumMonths } = req.body;

        if (!principal || !interestRate || !tenureMonths) {
            return res.status(400).json({
                success: false,
                error: 'Required fields: principal, interestRate, tenureMonths'
            });
        }

        const result = financialService.calculateEQI(
            principal,
            interestRate,
            tenureMonths,
            moratoriumMonths || 0
        );

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
        const { principal, interestRate, tenureMonths, moratoriumMonths, isSHG } = req.body;
        const result = financialService.calculateVISVASSubvention(
            principal, interestRate, tenureMonths, moratoriumMonths || 0, isSHG
        );
        res.json({ success: true, subvention: result });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

/**
 * Interest Rate Information
 * Source: NSFDC Official Website (www.nsfdc.nic.in)
 * "NSFDC charges 2.5% from the SCAs/CAs, which in turn shall charge 6.5% from the Beneficiaries."
 * "NSFDC charges 2% from the SCAs/CAs for Educational Loans, which in turn shall charge 6% from the Beneficiaries."
 */
exports.interestRateInfo = (req, res) => {
    res.json({
        success: true,
        info: {
            spread: {
                description: 'NSFDC charges SCAs/CAs a lower rate, who then charge beneficiaries a higher rate. The spread covers administrative costs.',
                standard: {
                    nsfdcToSCA: '2.5%',
                    scaToBeneficiary: '6.5%',
                    spread: '~4%'
                },
                educational: {
                    nsfdcToSCA: '2.0%',
                    scaToBeneficiary: '6.0%',
                    spread: '~4%'
                }
            },
            source: 'NSFDC Official Website – Scheme Details Page (www.nsfdc.nic.in)',
            note: 'NSFDC does not lend directly to beneficiaries. All lending is through channel partners (SCAs, PSBs, RRBs, NBFC-MFIs).'
        }
    });
};
