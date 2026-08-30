import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { schemeAPI, applicationAPI } from '../services/api';
import {
  FileSearch, Calculator, MapPin, Sparkles, ArrowRight,
  TrendingUp, Users, Banknote, Clock
} from 'lucide-react';

export default function DashboardPage() {
  const { user } = useAuth();
  const [schemeCount, setSchemeCount] = useState(0);
  const [appCount, setAppCount] = useState(0);
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
    { label: 'Active Schemes', value: schemeCount, icon: FileSearch, color: 'from-blue-500 to-indigo-600', bgColor: 'bg-blue-50', textColor: 'text-blue-600' },
    { label: 'My Applications', value: appCount, icon: TrendingUp, color: 'from-emerald-500 to-teal-600', bgColor: 'bg-emerald-50', textColor: 'text-emerald-600' },
    { label: 'Loan Calculator', value: 'Quick', icon: Calculator, color: 'from-amber-500 to-orange-600', bgColor: 'bg-amber-50', textColor: 'text-amber-600' },
    { label: 'Partner Network', value: '15+', icon: MapPin, color: 'from-purple-500 to-pink-600', bgColor: 'bg-purple-50', textColor: 'text-purple-600' },
  ];

  const quickActions = [
    { to: '/recommend', icon: Sparkles, label: 'Find My Scheme', desc: 'Get matched to the right scheme', color: 'bg-gradient-to-br from-primary-500 to-primary-700' },
    { to: '/calculator', icon: Calculator, label: 'Calculate EMI', desc: 'Estimate your monthly repayment', color: 'bg-gradient-to-br from-emerald-500 to-teal-600' },
    { to: '/partners', icon: MapPin, label: 'Find Partners', desc: 'Locate nearby lending partners', color: 'bg-gradient-to-br from-amber-500 to-orange-600' },
    { to: '/applications', icon: FileSearch, label: 'Track Applications', desc: 'Check application status', color: 'bg-gradient-to-br from-purple-500 to-pink-600' },
  ];

  const greeting = () => {
    const h = new Date().getHours();
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  };

  return (
    <div className="space-y-8 animate-fade-in">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-surface-900">{greeting()}, {user?.name?.split(' ')[0]}</h1>
        <p className="text-surface-500 mt-1">Welcome to Surakshit — your priority sector lending companion</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat, i) => (
          <div key={i} className="stat-card animate-slide-up" style={{ animationDelay: `${i * 100}ms` }}>
            <div className="flex items-start justify-between">
              <div>
                <p className="text-sm text-surface-500 font-medium">{stat.label}</p>
                <p className="text-2xl font-bold text-surface-900 mt-1">
                  {loading && i < 2 ? <span className="inline-block w-12 h-8 bg-surface-100 rounded animate-pulse" /> : stat.value}
                </p>
              </div>
              <div className={`p-3 rounded-xl ${stat.bgColor}`}>
                <stat.icon className={`w-5 h-5 ${stat.textColor}`} />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Quick Actions */}
      <div>
        <h2 className="text-lg font-semibold text-surface-900 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {quickActions.map((action, i) => (
            <Link
              key={i}
              to={action.to}
              className="group card-elevated p-6 hover:scale-[1.02] transition-all duration-300 animate-slide-up"
              style={{ animationDelay: `${i * 100 + 200}ms` }}
            >
              <div className={`w-12 h-12 ${action.color} rounded-2xl flex items-center justify-center mb-4 shadow-lg`}>
                <action.icon className="w-6 h-6 text-white" />
              </div>
              <h3 className="font-semibold text-surface-900 group-hover:text-primary-700 transition-colors">{action.label}</h3>
              <p className="text-sm text-surface-500 mt-1">{action.desc}</p>
              <ArrowRight className="w-4 h-4 text-surface-300 group-hover:text-primary-500 group-hover:translate-x-1 transition-all mt-3" />
            </Link>
          ))}
        </div>
      </div>

      {/* Scheme Categories */}
      <div className="card-elevated p-6">
        <h2 className="text-lg font-semibold text-surface-900 mb-4">Available Scheme Categories</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {[
            { name: 'Micro Finance', icon: '🏪', range: 'Up to ₹1.4L' },
            { name: 'Term Loan', icon: '💼', range: '₹1.4L - ₹50L' },
            { name: 'Education', icon: '🎓', range: 'Up to ₹40L' },
            { name: 'SC/ST Special', icon: '🤝', range: 'Subsidized' },
          ].map((cat, i) => (
            <Link to="/schemes" key={i} className="p-4 rounded-xl bg-surface-50 hover:bg-primary-50 border border-surface-100 hover:border-primary-200 transition-all text-center group">
              <span className="text-3xl mb-2 block">{cat.icon}</span>
              <p className="font-medium text-surface-800 group-hover:text-primary-700 text-sm">{cat.name}</p>
              <p className="text-xs text-surface-500 mt-1">{cat.range}</p>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
