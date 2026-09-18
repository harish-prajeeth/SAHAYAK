import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { schemeAPI, applicationAPI } from '../services/api';
import { Recommendation } from '../types';
import { Sparkles, CheckCircle, XCircle, AlertTriangle, ArrowRight, FileText } from 'lucide-react';

export default function RecommendPage() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<Recommendation | null>(null);
  const [form, setForm] = useState({
    projectType: 'Business',
    projectCost: '',
    businessType: 'New',
    preferredChannel: '',
    income: '',
    education: 'Graduate',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await schemeAPI.recommend({
        ...form,
        projectCost: Number(form.projectCost),
        income: Number(form.income) || 280000,
      });
      setResult(res.recommendation);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (n: number) => {
    return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(n);
  };

  return (
    <div className="space-y-6 animate-fade-in max-w-5xl">
      <div>
        <h1 className="text-3xl font-bold text-surface-900 tracking-tight">Find Your <span className="text-gradient">Scheme</span></h1>
        <p className="text-surface-500 mt-1">Enter your project details and get matched with the best scheme</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        {/* Form */}
        <div className="lg:col-span-2 card-elevated p-6">
          <h2 className="font-semibold text-surface-900 mb-4">Your Details</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Project Type</label>
              <select name="projectType" value={form.projectType} onChange={handleChange} className="input-field">
                <option value="Business">Business</option>
                <option value="Agriculture">Agriculture</option>
                <option value="Education">Education</option>
                <option value="Skill Development">Skill Development</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Project Cost (₹)</label>
              <input name="projectCost" type="number" value={form.projectCost} onChange={handleChange} className="input-field" placeholder="e.g. 120000" required />
            </div>
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Business Type</label>
              <select name="businessType" value={form.businessType} onChange={handleChange} className="input-field">
                <option value="New">New Enterprise</option>
                <option value="Existing">Existing Business</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Channel Preference</label>
              <select name="preferredChannel" value={form.preferredChannel} onChange={handleChange} className="input-field">
                <option value="">No Preference</option>
                <option value="Bank">Bank (PSB/SCA)</option>
                <option value="NBFC-MFI">NBFC-MFI</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1">Annual Family Income (₹)</label>
              <input name="income" type="number" value={form.income} onChange={handleChange} className="input-field" placeholder="e.g. 280000" />
            </div>
            <button type="submit" disabled={loading || !form.projectCost} className="btn-primary w-full disabled:opacity-50 flex items-center justify-center gap-2">
              {loading ? <div className="animate-spin w-5 h-5 border-2 border-white border-t-transparent rounded-full" /> : <><Sparkles className="w-5 h-5" /> Find My Scheme</>}
            </button>
          </form>
        </div>

        {/* Results */}
        <div className="lg:col-span-3">
          {!result && !loading && (
            <div className="card-elevated p-12 text-center relative overflow-hidden">
              <div className="absolute inset-0 bg-grid-subtle opacity-40 pointer-events-none" />
              <div className="relative">
                <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-primary-500 to-accent-600 flex items-center justify-center mx-auto mb-5 shadow-xl shadow-primary-500/25">
                  <Sparkles className="w-8 h-8 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-surface-800">Fill in your details</h3>
                <p className="text-surface-500 mt-1.5 max-w-sm mx-auto">Our AI engine matches your profile against every scheme parameter — cost, rate, tenure and channel.</p>
              </div>
            </div>
          )}

          {loading && (
            <div className="card-elevated p-12 text-center">
              <div className="animate-spin w-12 h-12 border-4 border-primary-500 border-t-transparent rounded-full mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-surface-600">Analyzing your profile...</h3>
              <p className="text-surface-400 mt-1">Checking eligibility across all schemes</p>
            </div>
          )}

          {result && result.primary && (
            <div className="space-y-4 animate-scale-in">
              {/* Best Match */}
              <div className="card-gradient-border card-elevated p-6 relative overflow-hidden">
                <div className="absolute -top-16 -right-16 w-48 h-48 bg-primary-500/5 rounded-full blur-2xl pointer-events-none" />
                <div className="flex items-center justify-between mb-4">
                  <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-gradient-to-r from-amber-50 to-orange-50 ring-1 ring-amber-200">
                    <span className="text-base">⭐</span>
                    <span className="text-xs font-bold text-amber-700 uppercase tracking-wider">Best Match</span>
                  </div>
                  <div className="text-right">
                    <div className="text-3xl font-bold text-gradient">{result.primary.matchScore}</div>
                    <p className="text-[11px] text-surface-500 uppercase tracking-wider font-medium">Match Score</p>
                  </div>
                </div>
                <h2 className="text-2xl font-bold text-surface-900 tracking-tight">{result.primary.scheme}</h2>
                <span className="badge-blue mt-1.5">{result.primary.code}</span>

                <div className="mt-4 p-4 bg-surface-50 rounded-xl border border-surface-100">
                  <p className="text-sm text-surface-700 leading-relaxed">{result.primary.rationale}</p>
                  {result.primary.note && <p className="text-sm text-amber-600 mt-2 font-medium">Note: {result.primary.note}</p>}
                </div>

                <div className="mt-4 flex items-center gap-4 text-sm">
                  <div className="flex items-center gap-1.5">
                    <CheckCircle className="w-4 h-4 text-emerald-500" />
                    <span className="text-surface-600 font-medium">Eligible</span>
                  </div>
                  <div className="text-surface-300">|</div>
                  <div className="text-surface-600">Approval probability: <strong className="text-emerald-600">{result.primary.approvalProbability}%</strong></div>
                </div>

                {result.primary.details && (
                  <div className="mt-4 grid grid-cols-3 gap-3">
                    <div className="p-3.5 bg-white rounded-xl border border-surface-100 text-center hover:border-primary-200 transition-colors">
                      <p className="text-[11px] text-surface-500 uppercase tracking-wider">Interest Rate</p>
                      <p className="font-bold text-surface-900 mt-0.5">{result.primary.details.interest_rate}%</p>
                    </div>
                    <div className="p-3.5 bg-white rounded-xl border border-surface-100 text-center hover:border-primary-200 transition-colors">
                      <p className="text-[11px] text-surface-500 uppercase tracking-wider">Max Tenure</p>
                      <p className="font-bold text-surface-900 mt-0.5">{Math.floor(result.primary.details.max_tenure_months / 12)}yr</p>
                    </div>
                    <div className="p-3.5 bg-white rounded-xl border border-surface-100 text-center hover:border-primary-200 transition-colors">
                      <p className="text-[11px] text-surface-500 uppercase tracking-wider">Moratorium</p>
                      <p className="font-bold text-surface-900 mt-0.5">{result.primary.details.moratorium_months}mo</p>
                    </div>
                  </div>
                )}

                <div className="mt-5 flex flex-wrap gap-3">
                  <button onClick={() => navigate('/calculator')} className="btn-secondary text-sm flex items-center gap-2">
                    Calculate EQI <ArrowRight className="w-4 h-4" />
                  </button>
                  <button onClick={() => navigate('/partners')} className="btn-primary text-sm flex items-center gap-2">
                    Find Partner <ArrowRight className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Alternatives */}
              {result.alternatives.length > 0 && (
                <div className="card-elevated p-5">
                  <h3 className="font-semibold text-surface-800 mb-3">Alternative Options</h3>
                  <div className="space-y-2">
                    {result.alternatives.map((alt, i) => (
                      <div key={i} className="flex items-center justify-between p-3.5 bg-surface-50 rounded-xl hover:bg-primary-50/50 hover:ring-1 hover:ring-primary-100 transition-all cursor-default">
                        <div>
                          <p className="font-semibold text-surface-800 text-sm">{alt.scheme}</p>
                          <p className="text-xs text-surface-500 mt-0.5">{alt.code} — Rate: {alt.rate}</p>
                        </div>
                        <ArrowRight className="w-4 h-4 text-surface-400" />
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {result && result.error && (
            <div className="card-elevated p-8 text-center animate-scale-in">
              <div className="w-14 h-14 rounded-2xl bg-red-50 flex items-center justify-center mx-auto mb-4">
                <XCircle className="w-7 h-7 text-red-500" />
              </div>
              <h3 className="text-lg font-semibold text-red-700">No Match Found</h3>
              <p className="text-surface-500 mt-2 max-w-sm mx-auto">{result.error}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
