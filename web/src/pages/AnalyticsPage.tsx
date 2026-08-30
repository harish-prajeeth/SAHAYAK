import { useState, useEffect } from 'react';
import { analyticsAPI } from '../services/api';
import { useTranslation } from '../utils/i18n';
import {
  Users, FileSearch, MapPin, FileText, TrendingUp, BarChart3,
  PieChart as PieChartIcon, Activity, AlertTriangle, CheckCircle
} from 'lucide-react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend
} from 'recharts';

const COLORS = ['#338bdf', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899'];

export default function AnalyticsPage() {
  const { t } = useTranslation();
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    analyticsAPI.dashboard().then(r => {
      setData(r.analytics);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="space-y-6 animate-fade-in">
        <div><h1 className="text-3xl font-bold text-surface-900">{t('analytics.title')}</h1></div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[1, 2, 3, 4].map(i => <div key={i} className="card p-6 animate-pulse"><div className="h-8 bg-surface-100 rounded w-1/2 mb-2" /><div className="h-6 bg-surface-100 rounded w-1/3" /></div>)}
        </div>
      </div>
    );
  }

  if (!data) return <div className="text-center py-12"><p className="text-surface-500">Failed to load analytics</p></div>;

  const { overview, statusBreakdown, byScheme, byProjectType, partnerTypes, rejectionAnalysis, monthlyTrend, topPartners, disbursementPipeline } = data;

  // Prepare chart data
  const statusPieData = Object.entries(statusBreakdown).map(([key, value]) => ({
    name: key.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase()),
    value: Number(value),
  }));

  const schemeBarData = byScheme.map((s: any) => ({
    name: s.code,
    applications: parseInt(s.count),
  }));

  const projectTypeData = byProjectType.map((p: any) => ({
    name: p.project_type,
    count: parseInt(p.count),
    avgCost: parseInt(p.avg_cost),
    avgLoan: parseInt(p.avg_loan),
  }));

  const partnerPieData = partnerTypes.map((p: any) => ({
    name: p.type,
    value: parseInt(p.count),
    avgFund: parseFloat(p.avg_fund_util),
    avgNpa: parseFloat(p.avg_npa),
    eligible: parseInt(p.eligible_count),
  }));

  return (
    <div className="space-y-6 animate-fade-in">
      <div>
        <h1 className="text-3xl font-bold text-surface-900">{t('analytics.title')}</h1>
        <p className="text-surface-500 mt-1">{t('analytics.subtitle')}</p>
      </div>

      {/* Overview Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
        {[
          { label: t('analytics.totalUsers'), value: overview.totalUsers, icon: Users, color: 'bg-blue-50 text-blue-600' },
          { label: t('analytics.totalSchemes'), value: overview.totalSchemes, icon: FileSearch, color: 'bg-emerald-50 text-emerald-600' },
          { label: t('analytics.totalPartners'), value: overview.totalPartners, icon: MapPin, color: 'bg-purple-50 text-purple-600' },
          { label: t('analytics.totalApps'), value: overview.totalApplications, icon: FileText, color: 'bg-amber-50 text-amber-600' },
          { label: t('analytics.approvalRate'), value: `${overview.approvalRate}%`, icon: TrendingUp, color: 'bg-teal-50 text-teal-600' },
        ].map((stat, i) => (
          <div key={i} className="stat-card animate-slide-up" style={{ animationDelay: `${i * 80}ms` }}>
            <div className="flex items-center gap-3">
              <div className={`p-2.5 rounded-xl ${stat.color}`}>
                <stat.icon className="w-5 h-5" />
              </div>
              <div>
                <p className="text-xs text-surface-500 font-medium">{stat.label}</p>
                <p className="text-2xl font-bold text-surface-900">{stat.value}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Charts Row 1: Status Breakdown + Applications by Scheme */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card-elevated p-6">
          <div className="flex items-center gap-2 mb-4">
            <PieChartIcon className="w-5 h-5 text-primary-500" />
            <h2 className="font-semibold text-surface-900">{t('analytics.statusBreakdown')}</h2>
          </div>
          <ResponsiveContainer width="100%" height={280}>
            <PieChart>
              <Pie data={statusPieData} cx="50%" cy="50%" innerRadius={60} outerRadius={100} paddingAngle={4} dataKey="value" label={({ name, value }) => `${name}: ${value}`}>
                {statusPieData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div className="card-elevated p-6">
          <div className="flex items-center gap-2 mb-4">
            <BarChart3 className="w-5 h-5 text-emerald-500" />
            <h2 className="font-semibold text-surface-900">{t('analytics.byScheme')}</h2>
          </div>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={schemeBarData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="applications" fill="#338bdf" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Charts Row 2: Partner Types + Project Types */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card-elevated p-6">
          <div className="flex items-center gap-2 mb-4">
            <MapPin className="w-5 h-5 text-purple-500" />
            <h2 className="font-semibold text-surface-900">{t('analytics.partnerPerformance')}</h2>
          </div>
          <div className="space-y-4">
            {partnerPieData.map((p: any, i: number) => (
              <div key={i} className="p-4 bg-surface-50 rounded-xl">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 rounded-full" style={{ background: COLORS[i % COLORS.length] }} />
                    <span className="font-medium text-surface-800">{p.name}</span>
                    <span className="badge-blue text-xs">{p.value} partners</span>
                  </div>
                  <span className="text-xs text-surface-500">{p.eligible} eligible</span>
                </div>
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-surface-400 text-xs">Avg Fund Utilization</span>
                    <div className="mt-1 h-2 bg-surface-200 rounded-full overflow-hidden">
                      <div className="h-full bg-emerald-500 rounded-full" style={{ width: `${Math.min(p.avgFund, 100)}%` }} />
                    </div>
                    <span className="font-medium text-surface-700">{p.avgFund}%</span>
                  </div>
                  <div>
                    <span className="text-surface-400 text-xs">Avg NPA Rate</span>
                    <div className="mt-1 h-2 bg-surface-200 rounded-full overflow-hidden">
                      <div className={`h-full rounded-full ${p.avgNpa < 5 ? 'bg-emerald-500' : p.avgNpa < 10 ? 'bg-amber-500' : 'bg-red-500'}`} style={{ width: `${Math.min(p.avgNpa * 5, 100)}%` }} />
                    </div>
                    <span className="font-medium text-surface-700">{p.avgNpa}%</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="card-elevated p-6">
          <div className="flex items-center gap-2 mb-4">
            <Activity className="w-5 h-5 text-amber-500" />
            <h2 className="font-semibold text-surface-900">{t('analytics.byProjectType')}</h2>
          </div>
          <div className="space-y-4">
            {projectTypeData.map((pt: any, i: number) => (
              <div key={i} className="p-4 bg-surface-50 rounded-xl">
                <div className="flex items-center justify-between mb-2">
                  <span className="font-medium text-surface-800">{pt.name}</span>
                  <span className="badge-blue">{pt.count} apps</span>
                </div>
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-surface-400 text-xs">Avg Project Cost</span>
                    <p className="font-bold text-surface-900">₹{pt.avgCost?.toLocaleString('en-IN')}</p>
                  </div>
                  <div>
                    <span className="text-surface-400 text-xs">Avg Loan Amount</span>
                    <p className="font-bold text-surface-900">₹{pt.avgLoan?.toLocaleString('en-IN')}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Charts Row 3: Rejection Analysis + Disbursement Pipeline */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card-elevated p-6">
          <div className="flex items-center gap-2 mb-4">
            <AlertTriangle className="w-5 h-5 text-red-500" />
            <h2 className="font-semibold text-surface-900">{t('analytics.rejectionAnalysis')}</h2>
          </div>
          {rejectionAnalysis.length === 0 ? (
            <p className="text-surface-400 text-sm">No rejections recorded yet</p>
          ) : (
            <div className="space-y-3">
              {rejectionAnalysis.map((r: any, i: number) => (
                <div key={i} className="p-4 bg-red-50/50 border border-red-100 rounded-xl">
                  <div className="flex items-center justify-between mb-1">
                    <span className="font-medium text-red-700 capitalize">{r.rejection_category} Issue</span>
                    <span className="badge-red">{r.count} rejected</span>
                  </div>
                  <p className="text-sm text-surface-600">{r.reasons?.filter(Boolean).join('; ') || 'Various reasons'}</p>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="card-elevated p-6">
          <div className="flex items-center gap-2 mb-4">
            <CheckCircle className="w-5 h-5 text-teal-500" />
            <h2 className="font-semibold text-surface-900">{t('analytics.pipeline')}</h2>
          </div>
          {disbursementPipeline.length === 0 ? (
            <p className="text-surface-400 text-sm">No applications in pipeline</p>
          ) : (
            <div className="space-y-3">
              {disbursementPipeline.map((p: any, i: number) => {
                const stageLabels: Record<string, string> = {
                  SCA_DISTRICT: 'SCA District Office',
                  SCA_HEAD: 'SCA Head Office',
                  NSFDC_DESK: 'NSFDC Desk',
                  PCC: 'Project Clearance Committee',
                  CMD: 'Chairman-cum-MD',
                  LOI: 'Letter of Intent',
                  NSFDC_DISBURSEMENT: 'NSFDC Disbursement',
                  PARTNER_DISBURSEMENT: 'Partner Disbursement',
                  COMPLETED: 'Completed',
                };
                const progress = ((i + 1) / disbursementPipeline.length) * 100;
                return (
                  <div key={i} className="p-3 bg-surface-50 rounded-xl">
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-sm font-medium text-surface-800">{stageLabels[p.current_stage] || p.current_stage}</span>
                      <span className="text-sm font-bold text-primary-600">{p.count} apps</span>
                    </div>
                    <div className="h-2 bg-surface-200 rounded-full overflow-hidden">
                      <div className="h-full bg-gradient-to-r from-primary-500 to-teal-500 rounded-full" style={{ width: `${progress}%` }} />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* Monthly Trend */}
      {monthlyTrend.length > 0 && (
        <div className="card-elevated p-6">
          <div className="flex items-center gap-2 mb-4">
            <TrendingUp className="w-5 h-5 text-blue-500" />
            <h2 className="font-semibold text-surface-900">{t('analytics.monthlyTrend')}</h2>
          </div>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={monthlyTrend.map((m: any) => ({ month: m.month, total: parseInt(m.count), approved: parseInt(m.approved), rejected: parseInt(m.rejected) }))}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="total" fill="#338bdf" name="Total" radius={[4, 4, 0, 0]} />
              <Bar dataKey="approved" fill="#10b981" name="Approved" radius={[4, 4, 0, 0]} />
              <Bar dataKey="rejected" fill="#ef4444" name="Rejected" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* Top Partners */}
      <div className="card-elevated p-6">
        <h2 className="font-semibold text-surface-900 mb-4">Top Performing Partners</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-surface-50">
                <th className="px-4 py-3 text-left font-medium text-surface-600">Partner</th>
                <th className="px-4 py-3 text-left font-medium text-surface-600">Type</th>
                <th className="px-4 py-3 text-right font-medium text-surface-600">Fund Utilization</th>
                <th className="px-4 py-3 text-right font-medium text-surface-600">NPA Rate</th>
              </tr>
            </thead>
            <tbody>
              {topPartners.map((p: any, i: number) => (
                <tr key={i} className="border-t border-surface-50 hover:bg-surface-50/50">
                  <td className="px-4 py-3 font-medium text-surface-800">{p.name}</td>
                  <td className="px-4 py-3"><span className="badge-blue text-xs">{p.type}</span></td>
                  <td className="px-4 py-3 text-right">
                    <span className="font-medium text-emerald-600">{p.fund_utilization}%</span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <span className={`font-medium ${p.npa_rate < 5 ? 'text-emerald-600' : p.npa_rate < 10 ? 'text-amber-600' : 'text-red-600'}`}>
                      {p.npa_rate}%
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
