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
    <div className="space-y-6 animate-fade-in max-w-4xl">
      <div>
        <h1 className="text-3xl font-bold text-surface-900">Find Your Scheme</h1>
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
            <div className="card-elevated p-12 text-center">
              <Sparkles className="w-12 h-12 text-surface-300 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-surface-600">Fill in your details</h3>
              <p className="text-surface-400 mt-1">We'll match you with the best available scheme</p>
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
              <div className="card-elevated p-6 border-2 border-primary-200 bg-primary-50/30">
                <div className="flex items-center gap-2 mb-4">
                  <span className="text-2xl">⭐</span>
                  <h3 className="font-bold text-primary-800">Best Match</h3>
                </div>
                <div className="flex items-start justify-between">
                  <div>
                    <h2 className="text-2xl font-bold text-surface-900">{result.primary.scheme}</h2>
                    <span className="badge-blue mt-1">{result.primary.code}</span>
                  </div>
                  <div className="text-right">
                    <div className="text-3xl font-bold text-primary-600">{result.primary.matchScore}</div>
                    <p className="text-xs text-surface-500">Match Score</p>
                  </div>
                </div>

                <div className="mt-4 p-4 bg-white rounded-xl border border-primary-100">
                  <p className="text-sm text-surface-700">{result.primary.rationale}</p>
                  {result.primary.note && <p className="text-sm text-amber-600 mt-2 font-medium">Note: {result.primary.note}</p>}
                </div>

                <div className="mt-4 flex items-center gap-4 text-sm">
                  <div className="flex items-center gap-2">
                    <CheckCircle className="w-4 h-4 text-emerald-500" />
                    <span className="text-surface-600">Eligible</span>
                  </div>
                  <div className="text-surface-300">|</div>
                  <div className="text-surface-600">Approval probability: <strong className="text-emerald-600">{result.primary.approvalProbability}%</strong></div>
                </div>

                {result.primary.details && (
                  <div className="mt-4 grid grid-cols-3 gap-3">
                    <div className="p-3 bg-white rounded-lg border border-surface-100 text-center">
                      <p className="text-xs text-surface-500">Interest Rate</p>
                      <p className="font-bold text-surface-900">{result.primary.details.interest_rate}%</p>
                    </div>
                    <div className="p-3 bg-white rounded-lg border border-surface-100 text-center">
                      <p className="text-xs text-surface-500">Max Tenure</p>
                      <p className="font-bold text-surface-900">{Math.floor(result.primary.details.max_tenure_months / 12)}yr</p>
                    </div>
                    <div className="p-3 bg-white rounded-lg border border-surface-100 text-center">
                      <p className="text-xs text-surface-500">Moratorium</p>
                      <p className="font-bold text-surface-900">{result.primary.details.moratorium_months}mo</p>
                    </div>
                  </div>
                )}

                <div className="mt-4 flex gap-3">
                  <button onClick={() => navigate('/calculator')} className="btn-secondary text-sm flex items-center gap-2">
                    Calculate EMI <ArrowRight className="w-4 h-4" />
                  </button>
                  <button onClick={() => navigate('/partners')} className="btn-primary text-sm flex items-center gap-2">
                    Find Partner <ArrowRight className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Alternatives */}
              {result.alternatives.length > 0 && (
                <div className="card p-4">
                  <h3 className="font-semibold text-surface-800 mb-3">Alternative Options</h3>
                  <div className="space-y-2">
                    {result.alternatives.map((alt, i) => (
                      <div key={i} className="flex items-center justify-between p-3 bg-surface-50 rounded-lg">
                        <div>
                          <p className="font-medium text-surface-800">{alt.scheme}</p>
                          <p className="text-xs text-surface-500">{alt.code} — Rate: {alt.rate}</p>
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
              <XCircle className="w-12 h-12 text-red-400 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-red-700">No Match Found</h3>
              <p className="text-surface-500 mt-2">{result.error}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
