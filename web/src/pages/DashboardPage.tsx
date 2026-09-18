import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { schemeAPI, applicationAPI } from '../services/api';
import { useTranslation } from '../utils/i18n';
import {
  FileSearch, Calculator, MapPin, Sparkles, ArrowRight, ArrowUpRight,
  TrendingUp, Users, Banknote, Clock, ShieldCheck
} from 'lucide-react';

export default function DashboardPage() {
  const { user } = useAuth();
  const [schemeCount, setSchemeCount] = useState(0);
  const [appCount, setAppCount] = useState(0);
  const { t } = useTranslation();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      schemeAPI.list().catch(() => ({ schemes: [] })),
      applicationAPI.list().catch(() => ({ applications: [] })),
    ]).then(([schemes, apps]) => {
      setSchemeCount(schemes.schemes?.length || 0);
      setAppCount(apps.applications?.length || 0);
      setLoading(false);
    });
  }, []);

  const stats = [
    { label: t('dash.stats.schemes'), value: schemeCount, icon: FileSearch, gradient: 'from-blue-500 to-indigo-600', glow: 'shadow-blue-500/25', trend: '+2 this month' },
    { label: t('dash.stats.applications'), value: appCount, icon: TrendingUp, gradient: 'from-emerald-500 to-teal-600', glow: 'shadow-emerald-500/25', trend: '1 in review' },
    { label: t('dash.stats.calculator'), value: 'EQI', icon: Calculator, gradient: 'from-amber-500 to-orange-600', glow: 'shadow-amber-500/25', trend: 'Quarterly model' },
    { label: t('dash.stats.partners'), value: '15+', icon: MapPin, gradient: 'from-purple-500 to-pink-600', glow: 'shadow-purple-500/25', trend: 'Across India' },
  ];

  const quickActions = [
    { to: '/recommend', icon: Sparkles, label: t('dash.actions.findScheme'), desc: t('dash.actions.findScheme.desc'), color: 'bg-gradient-to-br from-primary-500 via-primary-600 to-indigo-600', glow: 'shadow-primary-500/30' },
    { to: '/calculator', icon: Calculator, label: t('dash.actions.calculate'), desc: t('dash.actions.calculate.desc'), color: 'bg-gradient-to-br from-emerald-500 via-emerald-600 to-teal-600', glow: 'shadow-emerald-500/30' },
    { to: '/partners', icon: MapPin, label: t('dash.actions.findPartners'), desc: t('dash.actions.findPartners.desc'), color: 'bg-gradient-to-br from-amber-500 via-orange-500 to-orange-600', glow: 'shadow-amber-500/30' },
    { to: '/applications', icon: FileSearch, label: t('dash.actions.trackApps'), desc: t('dash.actions.trackApps.desc'), color: 'bg-gradient-to-br from-purple-500 via-purple-600 to-fuchsia-600', glow: 'shadow-purple-500/30' },
  ];

  const greeting = () => {
    const h = new Date().getHours();
    if (h < 12) return t('dash.greeting.morning');
    if (h < 17) return t('dash.greeting.afternoon');
    return t('dash.greeting.evening');
  };

  return (
    <div className="space-y-8 animate-fade-in max-w-7xl mx-auto">
      {/* Hero banner */}
      <div className="relative bg-aurora rounded-3xl p-8 lg:p-10 overflow-hidden">
        <div className="absolute top-6 right-8 w-36 h-36 bg-white/10 rounded-full blur-2xl animate-float-slow" />
        <div className="absolute -bottom-10 left-1/3 w-48 h-48 bg-accent-400/15 rounded-full blur-3xl" />

        <div className="relative z-10 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
          <div>
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/10 ring-1 ring-white/20 backdrop-blur mb-4">
              <ShieldCheck className="w-3.5 h-3.5 text-emerald-300" />
              <span className="text-xs font-medium text-white/85">NSFDC Verified Beneficiary</span>
            </div>
            <h1 className="text-3xl lg:text-4xl font-bold text-white tracking-tight">
              {greeting()}, {user?.name?.split(' ')[0]} 👋
            </h1>
            <p className="text-white/70 mt-2 max-w-xl">{t('dash.welcome')}</p>
          </div>
          <Link
            to="/recommend"
            className="inline-flex items-center gap-2 px-6 py-3.5 rounded-xl bg-white text-primary-700 font-semibold shadow-xl shadow-black/10 hover:shadow-2xl hover:-translate-y-0.5 transition-all w-fit"
          >
            <Sparkles className="w-[18px] h-[18px]" />
            {t('dash.actions.findScheme')}
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat, i) => (
          <div key={i} className="stat-card animate-slide-up" style={{ animationDelay: `${i * 80}ms` }}>
            <div className="flex items-start justify-between">
              <div>
                <p className="text-xs font-semibold text-surface-500 uppercase tracking-wider">{stat.label}</p>
                <p className="text-3xl font-bold text-surface-900 mt-2 tracking-tight">
                  {loading && i < 2 ? <span className="inline-block w-14 h-9 bg-surface-100 rounded-lg animate-pulse" /> : stat.value}
                </p>
                <p className="text-[11px] text-emerald-600 font-medium mt-2 flex items-center gap-1">
                  <ArrowUpRight className="w-3 h-3" /> {stat.trend}
                </p>
              </div>
              <div className={`p-3 rounded-xl bg-gradient-to-br ${stat.gradient} shadow-lg ${stat.glow}`}>
                <stat.icon className="w-5 h-5 text-white" />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Quick Actions */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="section-title">Quick Actions</h2>
            <p className="section-subtitle">Jump straight to what you need</p>
          </div>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {quickActions.map((action, i) => (
            <Link
              key={i}
              to={action.to}
              className="group card-elevated card-hover p-6 animate-slide-up"
              style={{ animationDelay: `${i * 80 + 200}ms` }}
            >
              <div className={`w-12 h-12 ${action.color} rounded-2xl flex items-center justify-center mb-4 shadow-lg ${action.glow} group-hover:scale-110 group-hover:rotate-3 transition-transform duration-300`}>
                <action.icon className="w-6 h-6 text-white" />
              </div>
              <h3 className="font-semibold text-surface-900 group-hover:text-primary-700 transition-colors">{action.label}</h3>
              <p className="text-sm text-surface-500 mt-1 leading-relaxed">{action.desc}</p>
              <span className="inline-flex items-center gap-1 text-xs font-semibold text-primary-600 mt-4 opacity-0 group-hover:opacity-100 -translate-x-1 group-hover:translate-x-0 transition-all">
                Open <ArrowRight className="w-3.5 h-3.5" />
              </span>
            </Link>
          ))}
        </div>
      </div>

      {/* Scheme Categories */}
      <div className="card-elevated p-6 lg:p-7">
        <div className="flex items-center justify-between mb-5">
          <div>
            <h2 className="section-title">{t('dash.categories.title')}</h2>
            <p className="section-subtitle">Four lending verticals tailored for you</p>
          </div>
          <Link to="/schemes" className="text-sm font-semibold text-primary-600 hover:text-primary-700 flex items-center gap-1">
            View all <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {[
            { name: 'Micro Finance', icon: '🏪', range: 'Up to ₹1.4L', gradient: 'from-sky-400 to-blue-500' },
            { name: 'Term Loan', icon: '💼', range: '₹1.4L – ₹50L', gradient: 'from-violet-400 to-purple-600' },
            { name: 'Education', icon: '🎓', range: 'Up to ₹40L', gradient: 'from-emerald-400 to-teal-600' },
            { name: 'SC/ST Special', icon: '🤝', range: 'Subsidized', gradient: 'from-amber-400 to-orange-600' },
          ].map((cat, i) => (
            <Link
              to="/schemes"
              key={i}
              className="p-5 rounded-2xl bg-surface-50 hover:bg-white border border-surface-100 hover:border-primary-200 hover:shadow-lg hover:shadow-primary-500/5 transition-all text-center group"
            >
              <span className={`w-12 h-12 mx-auto mb-3 rounded-2xl bg-gradient-to-br ${cat.gradient} flex items-center justify-center text-2xl shadow-md group-hover:scale-110 transition-transform`}>
                {cat.icon}
              </span>
              <p className="font-semibold text-surface-800 group-hover:text-primary-700 text-sm">{cat.name}</p>
              <p className="text-xs text-surface-500 mt-1">{cat.range}</p>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
