/**
 * Financial Service — Quarterly EQI (Equal Quarterly Installment) Model
 * 
 * Implements NSFDC's moratorium-adjusted quarterly repayment structure:
 * 1. During moratorium, interest accrues and capitalizes into principal
 * 2. After moratorium, borrower repays accumulated principal in equal quarterly installments
 * 
 * Formula:
 *   Step 1: Accumulated Principal = P × (1 + r)^m
 *   Step 2: EQI = [Accumulated × r × (1 + r)^n] / [(1 + r)^n - 1]
 * 
 * Where:
 *   P = Initial principal
 *   r = Quarterly interest rate (Annual Rate / 4)
 *   m = Moratorium quarters (moratoriumMonths / 3)
 *   n = Repayment quarters (totalQuarters - moratoriumQuarters)
 * 
 * Source: NSFDC Official Website (www.nsfdc.nic.in)
 * Interest rate spread: NSFDC charges 2.5% from SCAs/CAs, which charge 6.5% from beneficiaries
 * Source: NSFDC Official Website – Scheme Details Page
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
    calculateEQI(principal, annualRate, tenureMonths, moratoriumMonths = 0) {
        const quarterlyRate = annualRate / 100 / 4;
        const totalQuarters = Math.ceil(tenureMonths / 3);
        const moratoriumQuarters = Math.ceil(moratoriumMonths / 3);
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
            moratoriumMonths,
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
