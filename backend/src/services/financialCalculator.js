/**
 * Calculate Monthly EMI
 * Formula: EMI = P × r × (1+r)^n / ((1+r)^n - 1)
 */
function calculateEMI(principal, annualRate, tenureMonths) {
  const monthlyRate = annualRate / 100 / 12;
  if (monthlyRate === 0) return principal / tenureMonths;

  const emi =
    (principal * monthlyRate * Math.pow(1 + monthlyRate, tenureMonths)) /
    (Math.pow(1 + monthlyRate, tenureMonths) - 1);
  return Math.round(emi * 100) / 100;
}

/**
 * Generate Full Amortization Schedule
 */
function calculateAmortization(principal, annualRate, tenureMonths, moratoriumMonths = 0) {
  const effectiveTenure = tenureMonths - moratoriumMonths;

  if (effectiveTenure <= 0) {
    return { error: 'Tenure too short after moratorium' };
  }

  const emi = calculateEMI(principal, annualRate, effectiveTenure);
  const totalPayment = emi * effectiveTenure;
  const totalInterest = totalPayment - principal;

  const schedule = [];
  let balance = principal;
  const monthlyRate = annualRate / 100 / 12;

  for (let i = 1; i <= effectiveTenure; i++) {
    const interest = balance * monthlyRate;
    const principalPaid = emi - interest;
    balance -= principalPaid;

    schedule.push({
      month: i,
      emi: Math.round(emi * 100) / 100,
      principal: Math.round(principalPaid * 100) / 100,
      interest: Math.round(interest * 100) / 100,
      balance: Math.max(0, Math.round(balance * 100) / 100),
    });
  }

  const yearlySummary = [];
  for (let year = 1; year <= Math.ceil(effectiveTenure / 12); year++) {
    const startIdx = (year - 1) * 12;
    const endIdx = Math.min(year * 12, effectiveTenure);
    const yearSchedules = schedule.slice(startIdx, endIdx);

    yearlySummary.push({
      year,
      months: yearSchedules.length,
      principalPaid: Math.round(
        yearSchedules.reduce((sum, s) => sum + s.principal, 0) * 100
      ) / 100,
      interestPaid: Math.round(
        yearSchedules.reduce((sum, s) => sum + s.interest, 0) * 100
      ) / 100,
      totalPaid: Math.round(
        yearSchedules.reduce((sum, s) => sum + s.emi, 0) * 100
      ) / 100,
      endingBalance:
        yearSchedules.length > 0
          ? yearSchedules[yearSchedules.length - 1].balance
          : 0,
    });
  }

  return {
    emi: Math.round(emi * 100) / 100,
    totalPayment: Math.round(totalPayment * 100) / 100,
    totalInterest: Math.round(totalInterest * 100) / 100,
    effectiveTenure,
    monthlySchedule: schedule.slice(0, 12),
    yearlySummary,
    fullSchedule: schedule,
  };
}

/**
 * Compare Multiple Schemes
 */
function compareSchemes(scenarios) {
  return scenarios.map((scenario) => {
    const result = calculateAmortization(
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
      emi: result.emi,
      totalPayment: result.totalPayment,
      totalInterest: result.totalInterest,
      effectiveTenure: result.effectiveTenure,
    };
  });
}

module.exports = { calculateEMI, calculateAmortization, compareSchemes };
