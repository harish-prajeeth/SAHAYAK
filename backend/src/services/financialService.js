class FinancialService {
    calculateEMI(principal, annualRate, tenureMonths) {
        const monthlyRate = annualRate / 100 / 12;
        if (monthlyRate === 0) return principal / tenureMonths;
        const emi = principal * monthlyRate * Math.pow(1 + monthlyRate, tenureMonths) /
            (Math.pow(1 + monthlyRate, tenureMonths) - 1);
        return Math.round(emi * 100) / 100;
    }

    calculateAmortization(principal, annualRate, tenureMonths, moratoriumMonths = 0) {
        const effectiveTenure = tenureMonths - moratoriumMonths;
        if (effectiveTenure <= 0) return { error: 'Tenure too short after moratorium' };

        const emi = this.calculateEMI(principal, annualRate, effectiveTenure);
        const totalPayment = emi * effectiveTenure;
        const totalInterest = totalPayment - principal;

        const schedule = [];
        let balance = principal;
        const monthlyRate = annualRate / 100 / 12;

        for (let i = 0; i < moratoriumMonths; i++) {
            schedule.push({ month: i + 1, type: 'moratorium', emi: 0, principal: 0, interest: 0, balance });
        }

        for (let i = 1; i <= effectiveTenure; i++) {
            const interest = balance * monthlyRate;
            const principalPaid = emi - interest;
            balance -= principalPaid;
            schedule.push({
                month: moratoriumMonths + i, type: 'payment',
                emi: Math.round(emi * 100) / 100,
                principal: Math.round(principalPaid * 100) / 100,
                interest: Math.round(interest * 100) / 100,
                balance: Math.max(0, Math.round(balance * 100) / 100)
            });
        }

        const paymentMonths = schedule.filter(s => s.type === 'payment');
        const yearlySummary = [];
        for (let year = 1; year <= Math.ceil(paymentMonths.length / 12); year++) {
            const startIdx = (year - 1) * 12;
            const endIdx = Math.min(year * 12, paymentMonths.length);
            const yearData = paymentMonths.slice(startIdx, endIdx);
            yearlySummary.push({
                year, months: yearData.length,
                principalPaid: Math.round(yearData.reduce((sum, s) => sum + s.principal, 0) * 100) / 100,
                interestPaid: Math.round(yearData.reduce((sum, s) => sum + s.interest, 0) * 100) / 100,
                totalPaid: Math.round(yearData.reduce((sum, s) => sum + s.emi, 0) * 100) / 100,
                endingBalance: yearData.length > 0 ? yearData[yearData.length - 1].balance : 0
            });
        }

        return {
            emi: Math.round(emi * 100) / 100,
            totalPayment: Math.round(totalPayment * 100) / 100,
            totalInterest: Math.round(totalInterest * 100) / 100,
            effectiveTenure, moratoriumMonths, totalMonths: schedule.length,
            monthlySchedule: schedule, yearlySummary
        };
    }

    compareSchemes(scenarios) {
        return scenarios.map(scenario => {
            const result = this.calculateAmortization(scenario.principal, scenario.interestRate, scenario.tenureMonths, scenario.moratoriumMonths || 0);
            return {
                name: scenario.name, loanAmount: scenario.principal,
                interestRate: scenario.interestRate, tenureMonths: scenario.tenureMonths,
                moratoriumMonths: scenario.moratoriumMonths || 0,
                emi: result.emi, totalPayment: result.totalPayment,
                totalInterest: result.totalInterest, effectiveTenure: result.effectiveTenure
            };
        });
    }

    calculateVISVASSubvention(principal, annualRate, tenureMonths, isSHG = false) {
        const cap = isSHG ? 400000 : 200000;
        const subventionRate = 5;
        const subventionPrincipal = Math.min(principal, cap);
        const withoutSubvention = this.calculateAmortization(principal, annualRate, tenureMonths);
        const withSubvention = this.calculateAmortization(principal, annualRate - subventionRate, tenureMonths);

        return {
            eligible: true, subventionPrincipal,
            savings: Math.round((withoutSubvention.totalInterest - withSubvention.totalInterest) * 100) / 100,
            cappedAmount: cap,
            message: principal > cap ? `VISVAS subvention applies up to ₹${(cap / 100000).toFixed(1)} lakh` : `Full VISVAS subvention of ${subventionRate}% applies`
        };
    }
}

module.exports = new FinancialService();
