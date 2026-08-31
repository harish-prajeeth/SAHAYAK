import { useState } from 'react';
import { calculatorAPI } from '../services/api';
import { Calculation } from '../types';
import { useTranslation } from '../utils/i18n';
import { Calculator, IndianRupee, Clock, TrendingDown, Info, Shield } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

export default function CalculatorPage() {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<Calculation | null>(null);
  const [form, setForm] = useState({
    principal: '100000',
    interestRate: '8.0',
    tenureMonths: '36',
    moratoriumMonths: '3',
    courseDurationYears: '0',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleCalculate = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const courseYears = Number(form.courseDurationYears);
      const res = await calculatorAPI.calculate({
        principal: Number(form.principal),
        interestRate: Number(form.interestRate),
        tenureMonths: Number(form.tenureMonths),
        moratoriumMonths: courseYears > 0 ? 0 : (Number(form.moratoriumMonths) || 0),
        courseDurationYears: courseYears,
      });
      setResult(res.calculation);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const isEducationLoan = Number(form.courseDurationYears) > 0;
  const computedMoratoriumMonths = isEducationLoan ? (Number(form.courseDurationYears) * 12) + 12 : Number(form.moratoriumMonths);
  const computedMoratQuarters = Math.ceil(computedMoratoriumMonths / 3);

  const formatCurrency = (n: number) =>
    new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(n);

  const { t } = useTranslation();
  const COLORS = ['#338bdf', '#dd3df2', '#10b981', '#f59e0b'];

  // Pre-filled scheme presets
  const presets = [
    { label: 'Micro Finance (₹1.1L, 6.5%, 3yr, 3mo moratorium)', principal: '110000', rate: '6.5', tenure: '36', moratorium: '3' },
    { label: 'Term Loan (₹3L, 8%, 7yr, 6mo moratorium)', principal: '300000', rate: '8.0', tenure: '84', moratorium: '6' },
    { label: 'Educational Loan (₹10L, 6.5%, 12yr, 2yr course)', principal: '1000000', rate: '6.5', tenure: '144', moratorium: '0', courseDuration: '2' },
    { label: 'Example (₹1L, 8%, 3yr, 1qr moratorium)', principal: '100000', rate: '8.0', tenure: '36', moratorium: '3', courseDuration: '0' },
  ];

  const applyPreset = (p: typeof presets[0]) => {
    setForm({ principal: p.principal, interestRate: p.rate, tenureMonths: p.tenure, moratoriumMonths: p.moratorium, courseDurationYears: p.courseDuration || '0' });
  };

  return (
    <div className="space-y-6 animate-fade-in max-w-6xl">
      <div>
        <h1 className="text-3xl font-bold text-surface-900">Quarterly EQI Calculator</h1>
        <p className="text-surface-500 mt-1">NSFDC moratorium-adjusted quarterly installment calculator with interest capitalization</p>
      </div>

      {/* Info Banner */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 flex items-start gap-3">
        <Info className="w-5 h-5 text-blue-500 mt-0.5 shrink-0" />
        <div className="text-sm text-blue-800">
          <p className="font-medium">How it works</p>
          <p className="mt-1">During the moratorium period, interest accrues quarterly and is capitalized into your principal. After the moratorium, you repay the accumulated amount in equal quarterly installments (EQI). This is the standard NSFDC model.</p>
          <p className="mt-1 text-blue-600 text-xs">Formula: Accumulated = P × (1+r)^m → EQI = [Accumulated × r × (1+r)^n] / [(1+r)^n - 1]</p>
        </div>
      </div>

      {/* Preset Buttons */}
      <div className="flex flex-wrap gap-2">
        {presets.map((p, i) => (
          <button key={i} onClick={() => applyPreset(p)} className="text-xs px-3 py-1.5 rounded-full border border-surface-200 hover:bg-primary-50 hover:border-primary-300 text-surface-600 hover:text-primary-700 transition-colors">
            {p.label}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Form */}
        <div className="card-elevated p-6">
          <h2 className="font-semibold text-surface-900 mb-4">Loan Details</h2>
          <form onSubmit={handleCalculate} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Loan Amount (₹)</label>
              <input name="principal" type="number" value={form.principal} onChange={handleChange} className="input-field" required />
            </div>
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Annual Interest Rate (%)</label>
              <input name="interestRate" type="number" step="0.1" value={form.interestRate} onChange={handleChange} className="input-field" required />
            </div>
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Total Tenure (months)</label>
              <input name="tenureMonths" type="number" value={form.tenureMonths} onChange={handleChange} className="input-field" required />
            </div>
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Course Duration (Education Loans only)</label>
              <select name="courseDurationYears" value={form.courseDurationYears} onChange={handleChange} className="input-field">
                <option value="0">Not an education loan</option>
                <option value="1">1 year course</option>
                <option value="2">2 year course</option>
                <option value="3">3 year course</option>
                <option value="4">4 year course (e.g., Engineering)</option>
                <option value="5">5 year course (e.g., Medicine)</option>
              </select>
              <p className="text-xs text-surface-400 mt-1">
                {isEducationLoan
                  ? `Moratorium = Course (${form.courseDurationYears}yr) + 1yr grace = ${computedMoratQuarters} quarters (${computedMoratoriumMonths} months)`
                  : 'Select course duration for variable moratorium calculation'}
              </p>
            </div>
            {!isEducationLoan && (
              <div>
                <label className="block text-sm font-medium text-surface-700 mb-1">Moratorium Period (months)</label>
                <input name="moratoriumMonths" type="number" value={form.moratoriumMonths} onChange={handleChange} className="input-field" />
                <p className="text-xs text-surface-400 mt-1">
                  {Number(form.moratoriumMonths) > 0
                    ? `${Math.ceil(Number(form.moratoriumMonths) / 3)} quarter(s) — interest capitalizes during this period`
                    : 'No moratorium — payments start immediately'}
                </p>
              </div>
            )}
            <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2">
              {loading ? <div className="animate-spin w-5 h-5 border-2 border-white border-t-transparent rounded-full" /> : <><Calculator className="w-5 h-5" /> Calculate EQI</>}
            </button>
          </form>
        </div>

        {/* Results */}
        <div className="lg:col-span-2 space-y-4">
          {!result && !loading && (
            <div className="card-elevated p-12 text-center">
              <Calculator className="w-12 h-12 text-surface-300 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-surface-600">Enter loan details</h3>
              <p className="text-surface-400 mt-1">Click Calculate to see your quarterly repayment schedule</p>
            </div>
          )}

          {result && (
            <>
              {/* Primary EQI Card */}
              <div className="card-elevated p-6 bg-gradient-to-r from-primary-600 to-primary-700 text-white">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-primary-100 text-sm font-medium">Quarterly EQI (Equal Quarterly Installment)</p>
                    <p className="text-4xl font-bold mt-1">{formatCurrency(result.eqi || result.emi)}</p>
                    <p className="text-primary-200 text-sm mt-2">
                      {result.repaymentQuarters || Math.ceil((result.effectiveTenure || 0) / 3)} quarterly payments after {result.moratoriumQuarters || Math.ceil((result.moratoriumMonths || 0) / 3)} quarter moratorium
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-primary-200 text-xs">Quarterly Rate</p>
                    <p className="text-xl font-semibold">{result.quarterlyRate || ((Number(form.interestRate) / 4)).toFixed(2)}%</p>
                  </div>
                </div>
              </div>

              {/* Summary Cards */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 animate-scale-in">
                <div className="stat-card text-center">
                  <IndianRupee className="w-5 h-5 text-primary-500 mx-auto mb-1" />
                  <p className="text-xs text-surface-500">Total Payment</p>
                  <p className="text-lg font-bold text-primary-600">{formatCurrency(result.totalPayment)}</p>
                </div>
                <div className="stat-card text-center">
                  <TrendingDown className="w-5 h-5 text-amber-500 mx-auto mb-1" />
                  <p className="text-xs text-surface-500">Total Interest</p>
                  <p className="text-lg font-bold text-amber-600">{formatCurrency(result.totalInterest)}</p>
                </div>
                <div className="stat-card text-center">
                  <Clock className="w-5 h-5 text-emerald-500 mx-auto mb-1" />
                  <p className="text-xs text-surface-500">Moratorium Interest</p>
                  <p className="text-lg font-bold text-emerald-600">{formatCurrency(result.moratoriumInterest || 0)}</p>
                </div>
                <div className="stat-card text-center">
                  <Shield className="w-5 h-5 text-blue-500 mx-auto mb-1" />
                  <p className="text-xs text-surface-500">Accumulated Principal</p>
                  <p className="text-lg font-bold text-blue-600">{formatCurrency(result.accumulatedPrincipal || result.effectivePrincipal || Number(form.principal))}</p>
                </div>
              </div>

              {/* Charts */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="card p-4">
                  <h3 className="font-semibold text-surface-800 mb-3 text-sm">Yearly Principal vs Interest</h3>
                  <ResponsiveContainer width="100%" height={250}>
                    <BarChart data={result.yearlySummary}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                      <XAxis dataKey="year" label={{ value: 'Year', position: 'bottom' }} />
                      <YAxis />
                      <Tooltip formatter={(v: any) => formatCurrency(v)} />
                      <Bar dataKey="principalPaid" fill="#338bdf" name="Principal" radius={[4, 4, 0, 0]} />
                      <Bar dataKey="interestPaid" fill="#dd3df2" name="Interest" radius={[4, 4, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
                <div className="card p-4">
                  <h3 className="font-semibold text-surface-800 mb-3 text-sm">Payment Breakdown</h3>
                  <ResponsiveContainer width="100%" height={250}>
                    <PieChart>
                      <Pie
                        data={[
                          { name: 'Principal', value: Number(form.principal) },
                          { name: 'Moratorium Interest', value: result.moratoriumInterest || 0 },
                          { name: 'Repayment Interest', value: result.totalInterest - (result.moratoriumInterest || 0) },
                        ]}
                        cx="50%" cy="50%" innerRadius={60} outerRadius={90} paddingAngle={5} dataKey="value"
                      >
                        {COLORS.map((c, i) => <Cell key={i} fill={c} />)}
                      </Pie>
                      <Tooltip formatter={(v: any) => formatCurrency(v)} />
                    </PieChart>
                  </ResponsiveContainer>
                  <div className="flex justify-center gap-4 text-xs">
                    <div className="flex items-center gap-1"><div className="w-2 h-2 rounded-full bg-[#338bdf]" /> Principal</div>
                    <div className="flex items-center gap-1"><div className="w-2 h-2 rounded-full bg-[#dd3df2]" /> Moratorium</div>
                    <div className="flex items-center gap-1"><div className="w-2 h-2 rounded-full bg-[#10b981]" /> Interest</div>
                  </div>
                </div>
              </div>

              {/* Quarterly Schedule */}
              {result.quarterlySchedule && result.quarterlySchedule.length > 0 && (
                <div className="card overflow-hidden">
                  <div className="p-4 border-b border-surface-100 flex items-center justify-between">
                    <h3 className="font-semibold text-surface-800 text-sm">Quarterly Repayment Schedule</h3>
                    <span className="text-xs text-surface-400">{result.quarterlySchedule.length} quarters</span>
                  </div>
                  <div className="overflow-x-auto max-h-80 overflow-y-auto">
                    <table className="w-full text-sm">
                      <thead className="sticky top-0 bg-surface-50">
                        <tr>
                          <th className="px-3 py-2 text-left font-medium text-surface-600">Qtr</th>
                          <th className="px-3 py-2 text-left font-medium text-surface-600">Phase</th>
                          <th className="px-3 py-2 text-right font-medium text-surface-600">EQI</th>
                          <th className="px-3 py-2 text-right font-medium text-surface-600">Principal</th>
                          <th className="px-3 py-2 text-right font-medium text-surface-600">Interest</th>
                          <th className="px-3 py-2 text-right font-medium text-surface-600">Cap. Interest</th>
                          <th className="px-3 py-2 text-right font-medium text-surface-600">Balance</th>
                        </tr>
                      </thead>
                      <tbody>
                        {result.quarterlySchedule.map((row: any, i: number) => (
                          <tr key={i} className={`border-t border-surface-50 hover:bg-surface-50/50 ${row.phase === 'moratorium' ? 'bg-amber-50/50' : ''}`}>
                            <td className="px-3 py-2 font-medium text-surface-800">Q{row.quarter}</td>
                            <td className="px-3 py-2">
                              <span className={`text-xs px-2 py-0.5 rounded-full ${row.phase === 'moratorium' ? 'bg-amber-100 text-amber-700' : 'bg-emerald-100 text-emerald-700'}`}>
                                {row.phase === 'moratorium' ? 'Moratorium' : 'Repayment'}
                              </span>
                            </td>
                            <td className="px-3 py-2 text-right text-primary-600 font-medium">
                              {row.eqi > 0 ? formatCurrency(row.eqi) : '—'}
                            </td>
                            <td className="px-3 py-2 text-right text-primary-600">
                              {row.principal > 0 ? formatCurrency(row.principal) : '—'}
                            </td>
                            <td className="px-3 py-2 text-right text-accent-600">
                              {row.interest > 0 ? formatCurrency(row.interest) : '—'}
                            </td>
                            <td className="px-3 py-2 text-right text-amber-600">
                              {row.capitalizedInterest > 0 ? formatCurrency(row.capitalizedInterest) : '—'}
                            </td>
                            <td className="px-3 py-2 text-right text-surface-500">{formatCurrency(row.balance)}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* Yearly Summary Table */}
              <div className="card overflow-hidden">
                <div className="p-4 border-b border-surface-100">
                  <h3 className="font-semibold text-surface-800 text-sm">Yearly Repayment Summary</h3>
                </div>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="bg-surface-50">
                        <th className="px-4 py-3 text-left font-medium text-surface-600">Year</th>
                        <th className="px-4 py-3 text-right font-medium text-surface-600">Quarters</th>
                        <th className="px-4 py-3 text-right font-medium text-surface-600">Principal</th>
                        <th className="px-4 py-3 text-right font-medium text-surface-600">Interest</th>
                        <th className="px-4 py-3 text-right font-medium text-surface-600">Total</th>
                        <th className="px-4 py-3 text-right font-medium text-surface-600">Balance</th>
                      </tr>
                    </thead>
                    <tbody>
                      {result.yearlySummary.map((row: any) => (
                        <tr key={row.year} className="border-t border-surface-50 hover:bg-surface-50/50">
                          <td className="px-4 py-3 font-medium text-surface-800">Year {row.year}</td>
                          <td className="px-4 py-3 text-right text-surface-500">{row.quarters || 4}</td>
                          <td className="px-4 py-3 text-right text-primary-600">{formatCurrency(row.principalPaid)}</td>
                          <td className="px-4 py-3 text-right text-accent-600">{formatCurrency(row.interestPaid)}</td>
                          <td className="px-4 py-3 text-right text-surface-800 font-medium">{formatCurrency(row.totalPaid)}</td>
                          <td className="px-4 py-3 text-right text-surface-500">{formatCurrency(row.endingBalance)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Interest Rate Source */}
              <div className="bg-surface-50 border border-surface-200 rounded-lg p-4 text-xs text-surface-500">
                <p className="font-medium text-surface-700 mb-1">Interest Rate Mechanism</p>
                <p>NSFDC charges 2.5% from SCAs/CAs, which in turn charge 6.5% from beneficiaries. The ~4% spread covers channel partner administrative costs.</p>
                <p className="mt-1 italic">Source: NSFDC Official Website – Scheme Details Page (www.nsfdc.nic.in)</p>
                <p className="mt-2">Estimated repayment — final terms determined by the lending/channel partner.</p>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
