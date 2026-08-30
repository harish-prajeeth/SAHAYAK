import { useState } from 'react';
import { calculatorAPI } from '../services/api';
import { Calculation } from '../types';
import { useTranslation } from '../utils/i18n';
import { Calculator, IndianRupee, Clock, TrendingDown } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

export default function CalculatorPage() {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<Calculation | null>(null);
  const [form, setForm] = useState({
    principal: '110000',
    interestRate: '6.5',
    tenureMonths: '36',
    moratoriumMonths: '3',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleCalculate = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await calculatorAPI.calculate({
        principal: Number(form.principal),
        interestRate: Number(form.interestRate),
        tenureMonths: Number(form.tenureMonths),
        moratoriumMonths: Number(form.moratoriumMonths) || 0,
      });
      setResult(res.calculation);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (n: number) =>
    new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(n);

  const { t } = useTranslation();
  const COLORS = ['#338bdf', '#dd3df2', '#10b981'];

  return (
    <div className="space-y-6 animate-fade-in max-w-6xl">
      <div>
        <h1 className="text-3xl font-bold text-surface-900">{t('calc.title')}</h1>
        <p className="text-surface-500 mt-1">{t('calc.subtitle')}</p>
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
              <label className="block text-sm font-medium text-surface-700 mb-1">Interest Rate (% p.a.)</label>
              <input name="interestRate" type="number" step="0.1" value={form.interestRate} onChange={handleChange} className="input-field" required />
            </div>
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Tenure (months)</label>
              <input name="tenureMonths" type="number" value={form.tenureMonths} onChange={handleChange} className="input-field" required />
            </div>
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Moratorium (months)</label>
              <input name="moratoriumMonths" type="number" value={form.moratoriumMonths} onChange={handleChange} className="input-field" />
            </div>
            <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2">
              {loading ? <div className="animate-spin w-5 h-5 border-2 border-white border-t-transparent rounded-full" /> : <><Calculator className="w-5 h-5" /> Calculate</>}
            </button>
          </form>
        </div>

        {/* Results */}
        <div className="lg:col-span-2 space-y-4">
          {!result && !loading && (
            <div className="card-elevated p-12 text-center">
              <Calculator className="w-12 h-12 text-surface-300 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-surface-600">Enter loan details</h3>
              <p className="text-surface-400 mt-1">Click Calculate to see your repayment schedule</p>
            </div>
          )}

          {result && (
            <>
              {/* Summary Cards */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 animate-scale-in">
                <div className="stat-card text-center">
                  <IndianRupee className="w-6 h-6 text-primary-500 mx-auto mb-2" />
                  <p className="text-sm text-surface-500">Monthly EMI</p>
                  <p className="text-2xl font-bold text-primary-600">{formatCurrency(result.emi)}</p>
                </div>
                <div className="stat-card text-center">
                  <TrendingDown className="w-6 h-6 text-amber-500 mx-auto mb-2" />
                  <p className="text-sm text-surface-500">Total Interest</p>
                  <p className="text-2xl font-bold text-amber-600">{formatCurrency(result.totalInterest)}</p>
                </div>
                <div className="stat-card text-center">
                  <Clock className="w-6 h-6 text-emerald-500 mx-auto mb-2" />
                  <p className="text-sm text-surface-500">Total Payment</p>
                  <p className="text-2xl font-bold text-emerald-600">{formatCurrency(result.totalPayment)}</p>
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
                          { name: 'Interest', value: result.totalInterest },
                        ]}
                        cx="50%"
                        cy="50%"
                        innerRadius={60}
                        outerRadius={90}
                        paddingAngle={5}
                        dataKey="value"
                      >
                        {COLORS.slice(0, 2).map((c, i) => <Cell key={i} fill={c} />)}
                      </Pie>
                      <Tooltip formatter={(v: any) => formatCurrency(v)} />
                    </PieChart>
                  </ResponsiveContainer>
                  <div className="flex justify-center gap-6 text-sm">
                    <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-primary-500" /> Principal</div>
                    <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-accent-500" /> Interest</div>
                  </div>
                </div>
              </div>

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
                        <th className="px-4 py-3 text-right font-medium text-surface-600">Principal</th>
                        <th className="px-4 py-3 text-right font-medium text-surface-600">Interest</th>
                        <th className="px-4 py-3 text-right font-medium text-surface-600">Total</th>
                        <th className="px-4 py-3 text-right font-medium text-surface-600">Balance</th>
                      </tr>
                    </thead>
                    <tbody>
                      {result.yearlySummary.map((row) => (
                        <tr key={row.year} className="border-t border-surface-50 hover:bg-surface-50/50">
                          <td className="px-4 py-3 font-medium text-surface-800">Year {row.year}</td>
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

              <p className="text-xs text-surface-400 text-center">
                Estimated repayment — final terms determined by the lending/channel partner.
              </p>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
