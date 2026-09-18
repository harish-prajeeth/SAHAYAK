import { useState, useEffect } from 'react';
import { schemeAPI } from '../services/api';
import { Scheme } from '../types';
import { useTranslation } from '../utils/i18n';
import { Search, Percent, Clock, Banknote, Building2 } from 'lucide-react';

export default function SchemesPage() {
  const [schemes, setSchemes] = useState<Scheme[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const { t } = useTranslation();
  const [search, setSearch] = useState('');

  useEffect(() => {
    schemeAPI.list().then(r => { setSchemes(r.schemes); setLoading(false); });
  }, []);

  const categories = [
    { key: 'all', label: 'All Schemes' },
    { key: 'MFS', label: 'Micro Finance' },
    { key: 'TL', label: 'Term Loan' },
    { key: 'ELS', label: 'Education' },
    { key: 'SUI', label: 'Stand-Up India' },
    { key: 'SCST', label: 'SC/ST Special' },
    { key: 'PMY', label: 'Mudra Yojana' },
    { key: 'ACC', label: 'Artisan' },
  ];

  const filtered = schemes.filter(s => {
    if (filter !== 'all' && !s.code.includes(filter)) return false;
    if (search && !s.name.toLowerCase().includes(search.toLowerCase()) && !s.description?.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  const formatCurrency = (n: number) => {
    if (n >= 10000000) return `₹${(n / 10000000).toFixed(1)}Cr`;
    if (n >= 100000) return `₹${(n / 100000).toFixed(2)}L`;
    if (n >= 1000) return `₹${(n / 1000).toFixed(0)}K`;
    return `₹${n}`;
  };

  return (
    <div className="space-y-6 animate-fade-in max-w-7xl mx-auto">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-surface-900 tracking-tight">{t('scheme.title')}</h1>
          <p className="text-surface-500 mt-1">{t('scheme.subtitle')}</p>
        </div>
        <span className="badge-blue w-fit">{schemes.length} active schemes</span>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-[18px] h-[18px] text-surface-400" />
        <input
          type="text"
          value={search}
          onChange={e => setSearch(e.target.value)}
          placeholder={t('scheme.search')}
          className="input-field pl-11 shadow-sm"
        />
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-2">
        {categories.map(c => (
          <button
            key={c.key}
            onClick={() => setFilter(c.key)}
            className={`px-4 py-2 rounded-full text-sm font-semibold transition-all duration-200 ${
              filter === c.key
                ? 'bg-gradient-to-r from-primary-600 to-primary-500 text-white shadow-lg shadow-primary-500/25 scale-[1.03]'
                : 'bg-white text-surface-600 border border-surface-200 hover:border-primary-300 hover:text-primary-700 hover:shadow-sm'
            }`}
          >
            {c.label}
          </button>
        ))}
      </div>

      {/* Schemes Grid */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3].map(i => (
            <div key={i} className="card p-6 animate-pulse">
              <div className="h-6 bg-surface-100 rounded w-3/4 mb-3" />
              <div className="h-4 bg-surface-100 rounded w-full mb-2" />
              <div className="h-4 bg-surface-100 rounded w-2/3" />
            </div>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {filtered.map((scheme, i) => (
            <div key={scheme.id} className="card-elevated card-hover p-6 animate-slide-up group relative overflow-hidden" style={{ animationDelay: `${i * 50}ms` }}>
              {/* top gradient accent line */}
              <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-primary-500 via-accent-500 to-emerald-500 opacity-0 group-hover:opacity-100 transition-opacity" />
              <div className="flex items-start justify-between mb-3">
                <div>
                  <h3 className="font-bold text-surface-900 group-hover:text-primary-700 transition-colors">{scheme.name}</h3>
                  <span className="badge-blue mt-1.5">{scheme.code}</span>
                </div>
                {scheme.interest_rate <= 7 && (
                  <span className="badge-green">Low Interest</span>
                )}
              </div>
              <p className="text-sm text-surface-500 mb-4 line-clamp-2 leading-relaxed">{scheme.description}</p>
              <div className="space-y-2.5">
                <div className="flex items-center gap-2.5 text-sm">
                  <span className="w-7 h-7 rounded-lg bg-primary-50 flex items-center justify-center shrink-0"><Percent className="w-3.5 h-3.5 text-primary-600" /></span>
                  <span className="text-surface-600">Interest: <strong className="text-surface-900">{scheme.interest_rate}%</strong></span>
                </div>
                <div className="flex items-center gap-2.5 text-sm">
                  <span className="w-7 h-7 rounded-lg bg-emerald-50 flex items-center justify-center shrink-0"><Clock className="w-3.5 h-3.5 text-emerald-600" /></span>
                  <span className="text-surface-600">Tenure: <strong className="text-surface-900">{Math.floor(scheme.max_tenure_months / 12)} years {scheme.max_tenure_months % 12 > 0 ? `${scheme.max_tenure_months % 12}mo` : ''}</strong></span>
                </div>
                <div className="flex items-center gap-2.5 text-sm">
                  <span className="w-7 h-7 rounded-lg bg-amber-50 flex items-center justify-center shrink-0"><Banknote className="w-3.5 h-3.5 text-amber-600" /></span>
                  <span className="text-surface-600">Max Loan: <strong className="text-surface-900">{formatCurrency(scheme.max_loan)}</strong></span>
                </div>
                <div className="flex items-center gap-2.5 text-sm">
                  <span className="w-7 h-7 rounded-lg bg-purple-50 flex items-center justify-center shrink-0"><Building2 className="w-3.5 h-3.5 text-purple-600" /></span>
                  <span className="text-surface-600">Channels: <strong className="text-surface-900">{scheme.channel_types}</strong></span>
                </div>
              </div>
              <div className="mt-4 pt-4 border-t border-surface-100 flex items-center justify-between">
                <span className="text-xs text-surface-400">Cost range: {formatCurrency(scheme.min_cost)} — {formatCurrency(scheme.max_cost)}</span>
                <span className="text-xs font-semibold text-primary-600 opacity-0 group-hover:opacity-100 transition-opacity">Details →</span>
              </div>
            </div>
          ))}
        </div>
      )}

      {!loading && filtered.length === 0 && (
        <div className="text-center py-16">
          <div className="w-14 h-14 mx-auto rounded-2xl bg-surface-100 flex items-center justify-center mb-4">
            <Search className="w-6 h-6 text-surface-400" />
          </div>
          <p className="text-surface-500 font-medium">No schemes match your search.</p>
          <p className="text-sm text-surface-400 mt-1">Try a different keyword or category filter.</p>
        </div>
      )}
    </div>
  );
}
