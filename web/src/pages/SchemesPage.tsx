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
    <div className="space-y-6 animate-fade-in">
      <div>
        <h1 className="text-3xl font-bold text-surface-900">{t('scheme.title')}</h1>
        <p className="text-surface-500 mt-1">{t('scheme.subtitle')}</p>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-surface-400" />
        <input
          type="text"
          value={search}
          onChange={e => setSearch(e.target.value)}
          placeholder={t('scheme.search')}
          className="input-field pl-11"
        />
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-2">
        {categories.map(c => (
          <button
            key={c.key}
            onClick={() => setFilter(c.key)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
              filter === c.key
                ? 'bg-primary-600 text-white shadow-md'
                : 'bg-surface-100 text-surface-600 hover:bg-surface-200'
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
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map((scheme, i) => (
            <div key={scheme.id} className="card p-6 hover:shadow-lg transition-all duration-300 animate-slide-up" style={{ animationDelay: `${i * 50}ms` }}>
              <div className="flex items-start justify-between mb-3">
                <div>
                  <h3 className="font-bold text-surface-900">{scheme.name}</h3>
                  <span className="badge-blue mt-1">{scheme.code}</span>
                </div>
                {scheme.interest_rate <= 7 && (
                  <span className="badge-green">Low Interest</span>
                )}
              </div>
              <p className="text-sm text-surface-500 mb-4 line-clamp-2">{scheme.description}</p>
              <div className="space-y-2">
                <div className="flex items-center gap-2 text-sm">
                  <Percent className="w-4 h-4 text-primary-500" />
                  <span className="text-surface-600">Interest: <strong>{scheme.interest_rate}%</strong></span>
                </div>
                <div className="flex items-center gap-2 text-sm">
                  <Clock className="w-4 h-4 text-emerald-500" />
                  <span className="text-surface-600">Tenure: <strong>{Math.floor(scheme.max_tenure_months / 12)} years {scheme.max_tenure_months % 12 > 0 ? `${scheme.max_tenure_months % 12}mo` : ''}</strong></span>
                </div>
                <div className="flex items-center gap-2 text-sm">
                  <Banknote className="w-4 h-4 text-amber-500" />
                  <span className="text-surface-600">Max Loan: <strong>{formatCurrency(scheme.max_loan)}</strong></span>
                </div>
                <div className="flex items-center gap-2 text-sm">
                  <Building2 className="w-4 h-4 text-purple-500" />
                  <span className="text-surface-600">Channels: <strong>{scheme.channel_types}</strong></span>
                </div>
              </div>
              <div className="mt-4 pt-4 border-t border-surface-100 text-xs text-surface-400">
                Cost range: {formatCurrency(scheme.min_cost)} — {formatCurrency(scheme.max_cost)}
              </div>
            </div>
          ))}
        </div>
      )}

      {!loading && filtered.length === 0 && (
        <div className="text-center py-12">
          <p className="text-surface-500">No schemes match your search.</p>
        </div>
      )}
    </div>
  );
}
