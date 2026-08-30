import { useState, useEffect } from 'react';
import { useTranslation } from '../utils/i18n';
import { schemeAPI } from '../services/api';
import { GitCompareArrows, CheckCircle2, XCircle, Info } from 'lucide-react';

interface Scheme {
  id: number; name: string; code: string; description: string;
  min_cost: number; max_cost: number; max_loan: number;
  interest_rate: number; max_tenure_months: number; moratorium_months: number;
  channel_types: string[]; is_active: boolean;
}

const fmt = (n: number) => n >= 100000 ? `₹${(n/100000).toFixed(2)}L` : `₹${n.toLocaleString()}`;

export default function ComparePage() {
  const { t } = useTranslation();
  const [schemes, setSchemes] = useState<Scheme[]>([]);
  const [selected, setSelected] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    schemeAPI.list().then(r => { setSchemes(r.schemes); setLoading(false); });
  }, []);

  const toggle = (code: string) => {
    if (selected.includes(code)) setSelected(selected.filter(c => c !== code));
    else if (selected.length < 4) setSelected([...selected, code]);
  };

  const compared = schemes.filter(s => selected.includes(s.code));

  if (loading) return <div className="flex items-center justify-center h-64"><div className="animate-spin w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full" /></div>;

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl flex items-center justify-center">
          <GitCompareArrows className="w-5 h-5 text-white" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-surface-900">Compare Schemes</h1>
          <p className="text-surface-500 text-sm">Select up to 4 schemes to compare side-by-side</p>
        </div>
      </div>

      {/* Scheme selector */}
      <div className="bg-white rounded-2xl border border-surface-200 p-6 shadow-sm">
        <h2 className="text-sm font-semibold text-surface-700 mb-3">Select Schemes to Compare ({selected.length}/4)</h2>
        <div className="flex flex-wrap gap-3">
          {schemes.map(scheme => {
            const isSelected = selected.includes(scheme.code);
            const disabled = !isSelected && selected.length >= 4;
            return (
              <button key={scheme.code} onClick={() => toggle(scheme.code)} disabled={disabled}
                className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all ${
                  isSelected
                    ? 'bg-primary-500 text-white shadow-md ring-2 ring-primary-200'
                    : disabled
                      ? 'bg-surface-100 text-surface-400 cursor-not-allowed'
                      : 'bg-surface-100 text-surface-600 hover:bg-surface-200 hover:text-surface-800'
                }`}>
                {isSelected ? <CheckCircle2 className="w-4 h-4" /> : <Info className="w-4 h-4" />}
                {scheme.name}
              </button>
            );
          })}
        </div>
      </div>

      {/* Comparison table */}
      {compared.length >= 2 && (
        <div className="bg-white rounded-2xl border border-surface-200 shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-surface-50 border-b border-surface-200">
                  <th className="text-left px-6 py-4 font-semibold text-surface-700 w-48">Feature</th>
                  {compared.map(s => (
                    <th key={s.code} className="text-center px-6 py-4 font-bold text-surface-800">
                      <div>{s.name}</div>
                      <div className="text-xs text-surface-500 font-normal">{s.code}</div>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-surface-100">
                {[
                  { label: 'Description', render: (s: Scheme) => <span className="text-xs">{s.description}</span> },
                  { label: 'Max Loan Amount', render: (s: Scheme) => <span className="font-semibold text-primary-600">{fmt(s.max_loan)}</span> },
                  { label: 'Project Cost Range', render: (s: Scheme) => `${fmt(s.min_cost)} – ${fmt(s.max_cost)}` },
                  { label: 'Interest Rate', render: (s: Scheme) => (
                    <span className={`font-bold ${s.interest_rate <= 8 ? 'text-green-600' : 'text-orange-600'}`}>
                      {s.interest_rate}%
                    </span>
                  )},
                  { label: 'Max Tenure', render: (s: Scheme) => `${(s.max_tenure_months/12).toFixed(1)} years (${s.max_tenure_months} months)` },
                  { label: 'Moratorium Period', render: (s: Scheme) => `${s.moratorium_months} months` },
                  { label: 'Channel Partners', render: (s: Scheme) => (
                    <div className="flex flex-wrap gap-1 justify-center">
                      {s.channel_types.map(ct => (
                        <span key={ct} className="px-2 py-0.5 bg-primary-50 text-primary-700 rounded text-xs font-medium">{ct}</span>
                      ))}
                    </div>
                  )},
                  { label: 'EMI (₹1L, 36mo)', render: (s: Scheme) => {
                    const r = s.interest_rate / 100 / 12;
                    const n = s.max_tenure_months > 36 ? 36 : s.max_tenure_months;
                    const emi = r > 0 ? 100000 * r * Math.pow(1+r, n) / (Math.pow(1+r, n) - 1) : 100000 / n;
                    return `₹${Math.round(emi).toLocaleString()}/mo`;
                  }},
                  { label: 'Total Interest (₹1L, 36mo)', render: (s: Scheme) => {
                    const r = s.interest_rate / 100 / 12;
                    const n = s.max_tenure_months > 36 ? 36 : s.max_tenure_months;
                    const emi = r > 0 ? 100000 * r * Math.pow(1+r, n) / (Math.pow(1+r, n) - 1) : 100000 / n;
                    return fmt(Math.round(emi * n - 100000));
                  }},
                  { label: 'Best For', render: (s: Scheme) => {
                    const best: Record<string, string> = {
                      MFS: 'Small projects up to ₹1.4L', TL: 'Business expansion ₹1.4L–₹50L',
                      ELS: 'Higher education funding', AMY: 'Micro-enterprises via NBFC-MFI'
                    };
                    return <span className="text-xs italic">{best[s.code] || 'Various needs'}</span>;
                  }},
                ].map(({ label, render }) => (
                  <tr key={label} className="hover:bg-surface-50">
                    <td className="px-6 py-3.5 font-medium text-surface-700 whitespace-nowrap">{label}</td>
                    {compared.map(s => (
                      <td key={s.code} className="px-6 py-3.5 text-center text-surface-600">{render(s)}</td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {compared.length < 2 && (
        <div className="text-center py-12 text-surface-400">
          <GitCompareArrows className="w-12 h-12 mx-auto mb-3 opacity-50" />
          <p>Select at least 2 schemes above to compare</p>
        </div>
      )}
    </div>
  );
}
