/**
 * ═══════════════════════════════════════════════════════════
 * EQI CALCULATOR – MORATORIUM-ADJUSTED QUARTERLY MODEL
 * ═══════════════════════════════════════════════════════════
 * 
 * Total Tenure = Scheme Max Tenure (inclusive of moratorium)
 * Moratorium Quarters = Moratorium Months / 3
 * Repayment Quarters (n) = Total Tenure - Moratorium Quarters
 * 
 * Step 1: Capitalize Interest During Moratorium
 *   Accumulated Principal = P × (1 + r)^m
 *   Where: r = Annual Rate / 4, m = Moratorium Quarters
 * 
 * Step 2: Calculate EQI
 *   EQI = [Accumulated Principal × r × (1 + r)^n] / [(1 + r)^n - 1]
 * 
 * Step 3: Payment Summary
 *   Total Payment = EQI × n
 *   Total Interest = Total Payment - Original Principal (P)
 * 
 * ──────────────────────────────────────────────────────────
 * EXAMPLE: Micro Finance Scheme
 * ──────────────────────────────────────────────────────────
 * Loan: ₹1,00,000 @ 8%
 * Total Tenure: 12 quarters (3 years) — INCLUSIVE of moratorium
 * Moratorium: 1 quarter (3 months)
 * Repayment: 11 quarters
 * 
 * Accumulated Principal: ₹1,02,000
 * EQI: ₹10,422 per quarter
 * Total Payment: ₹1,14,642
 * Total Interest: ₹14,642
 * ═══════════════════════════════════════════════════════════
 * 
 * Scheme Parameters (all inclusive of moratorium):
 *   Micro Finance:  12 quarters, 1 morat, 11 repay, 6.5%
 *   Term Loan:      28 quarters, 2 morat, 26 repay, 8%
 *   Education Loan: 48 quarters, variable m, 48-m repay, 6.5%
 *   AMY (NBFC-MFI): 12 quarters, 1 morat, 11 repay, 15%
 * 
 * Source: NSFDC Official Website (www.nsfdc.nic.in)
 * Interest Rate Spread:
 *   Standard:    NSFDC→SCA 2.5%, SCA→Beneficiary 6.5%
 *   Educational: NSFDC→SCA 2.0%, SCA→Beneficiary 6.0%
 */
class FinancialService {
    /**
     * Calculate Quarterly EQI (Equal Quarterly Installment)
     * @param {number} principal - Loan amount in ₹
     * @param {number} annualRate - Annual interest rate (e.g., 8 for 8%)
     * @param {number} tenureMonths - Total tenure in months
     * @param {number} moratoriumMonths - Moratorium period in months
     * @returns {object} Full calculation result
     */
    calculateEQI(principal, annualRate, tenureMonths, moratoriumMonths = 0, courseDurationYears = 0) {
        const quarterlyRate = annualRate / 100 / 4;
        const totalQuarters = Math.ceil(tenureMonths / 3);

        // Educational Loan: variable moratorium = (Course Duration in years × 4) + 4 quarters (1 year grace)
        let effectiveMoratoriumMonths = moratoriumMonths;
        if (courseDurationYears > 0) {
            effectiveMoratoriumMonths = (courseDurationYears * 12) + 12; // Course period + 1 year
        }
        const moratoriumQuarters = Math.ceil(effectiveMoratoriumMonths / 3);
        const repaymentQuarters = totalQuarters - moratoriumQuarters;

        if (repaymentQuarters <= 0) {
            return { error: 'Repayment period too short after moratorium adjustment' };
        }

        // Step 1: Moratorium Interest Capitalization
        // During moratorium, interest accrues quarterly and is added to principal
        const accumulatedPrincipal = principal * Math.pow(1 + quarterlyRate, moratoriumQuarters);

        // Step 2: Calculate EQI on accumulated principal
        let eqi;
        if (quarterlyRate === 0) {
            eqi = accumulatedPrincipal / repaymentQuarters;
        } else {
            eqi = accumulatedPrincipal * quarterlyRate * Math.pow(1 + quarterlyRate, repaymentQuarters) /
                (Math.pow(1 + quarterlyRate, repaymentQuarters) - 1);
        }

        const totalPayment = eqi * repaymentQuarters;
        const totalInterest = totalPayment - principal;
        const moratoriumInterest = accumulatedPrincipal - principal;

        // Generate quarterly amortization schedule
        const schedule = [];
        let balance = principal;

        // Moratorium phase — show quarterly interest accrual (no payments)
        for (let q = 1; q <= moratoriumQuarters; q++) {
            const quarterInterest = balance * quarterlyRate;
            balance += quarterInterest; // Interest capitalizes into principal
            schedule.push({
                quarter: q,
                phase: 'moratorium',
                eqi: 0,
                principal: 0,
                interest: 0,
                capitalizedInterest: Math.round(quarterInterest * 100) / 100,
                balance: Math.round(balance * 100) / 100
            });
        }

        // Repayment phase — equal quarterly installments
        let repaymentBalance = accumulatedPrincipal;
        for (let q = 1; q <= repaymentQuarters; q++) {
            const quarterInterest = repaymentBalance * quarterlyRate;
            const principalPaid = eqi - quarterInterest;
            repaymentBalance -= principalPaid;

            schedule.push({
                quarter: moratoriumQuarters + q,
                phase: 'repayment',
                eqi: Math.round(eqi * 100) / 100,
                principal: Math.round(principalPaid * 100) / 100,
                interest: Math.round(quarterInterest * 100) / 100,
                capitalizedInterest: 0,
                balance: Math.max(0, Math.round(repaymentBalance * 100) / 100)
            });
        }

        // Yearly summary (4 quarters per year)
        const repaymentSchedule = schedule.filter(s => s.phase === 'repayment');
        const yearlySummary = [];
        const totalYears = Math.ceil(repaymentQuarters / 4);

        for (let year = 1; year <= totalYears; year++) {
            const startIdx = (year - 1) * 4;
            const endIdx = Math.min(year * 4, repaymentSchedule.length);
            const yearData = repaymentSchedule.slice(startIdx, endIdx);

            yearlySummary.push({
                year,
                quarters: yearData.length,
                principalPaid: Math.round(yearData.reduce((sum, s) => sum + s.principal, 0) * 100) / 100,
                interestPaid: Math.round(yearData.reduce((sum, s) => sum + s.interest, 0) * 100) / 100,
                totalPaid: Math.round(yearData.reduce((sum, s) => sum + s.eqi, 0) * 100) / 100,
                endingBalance: yearData.length > 0 ? yearData[yearData.length - 1].balance : 0
            });
        }

        return {
            eqi: Math.round(eqi * 100) / 100,
            totalPayment: Math.round(totalPayment * 100) / 100,
            totalInterest: Math.round(totalInterest * 100) / 100,
            moratoriumInterest: Math.round(moratoriumInterest * 100) / 100,
            accumulatedPrincipal: Math.round(accumulatedPrincipal * 100) / 100,
            effectivePrincipal: Math.round(accumulatedPrincipal * 100) / 100,
            quarterlyRate: Math.round(quarterlyRate * 10000) / 100, // as percentage
            totalQuarters,
            moratoriumQuarters,
            repaymentQuarters,
            effectiveTenure: repaymentQuarters * 3, // in months for backward compat
            moratoriumMonths: effectiveMoratoriumMonths, // actual moratorium used (may differ from input for education loans)
            totalMonths: schedule.length * 3,
            quarterlySchedule: schedule,
            yearlySummary,
            // Backward compatibility fields
            emi: Math.round(eqi * 100) / 100,
            monthlySchedule: schedule
        };
    }

    /**
     * Compare multiple schemes side by side using Quarterly EQI model
     */
    compareSchemes(scenarios) {
        return scenarios.map(scenario => {
            const result = this.calculateEQI(
                scenario.principal,
                scenario.interestRate,
                scenario.tenureMonths,
                scenario.moratoriumMonths || 0
            );
            return {
                name: scenario.name,
                loanAmount: scenario.principal,
                interestRate: scenario.interestRate,
                tenureMonths: scenario.tenureMonths,
                moratoriumMonths: scenario.moratoriumMonths || 0,
                eqi: result.eqi,
                totalPayment: result.totalPayment,
                totalInterest: result.totalInterest,
                moratoriumInterest: result.moratoriumInterest,
                accumulatedPrincipal: result.accumulatedPrincipal,
                effectiveTenure: result.effectiveTenure,
                repaymentQuarters: result.repaymentQuarters
            };
        });
    }

    /**
     * Calculate VISVAS subvention savings
     * NSFDC subsidizes 5% interest (cap: ₹2L individual, ₹4L SHG)
     */
    calculateVISVASSubvention(principal, annualRate, tenureMonths, moratoriumMonths = 0, isSHG = false) {
        const cap = isSHG ? 400000 : 200000;
        const subventionRate = 5;

        const withoutSubvention = this.calculateEQI(principal, annualRate, tenureMonths, moratoriumMonths);
        const effectivePrincipal = Math.min(principal, cap);
        const withSubvention = this.calculateEQI(effectivePrincipal, annualRate - subventionRate, tenureMonths, moratoriumMonths);

        const savings = withoutSubvention.totalInterest - withSubvention.totalInterest;

        return {
            eligible: true,
            subventionPrincipal: effectivePrincipal,
            savings: Math.round(Math.max(0, savings) * 100) / 100,
            cappedAmount: cap,
            message: principal > cap
                ? `VISVAS subvention applies up to ₹${(cap / 100000).toFixed(1)} lakh`
                : `Full VISVAS subvention of ${subventionRate}% applies`,
            source: 'NSFDC Official Website (www.nsfdc.nic.in)'
        };
    }
}

module.exports = new FinancialService();
