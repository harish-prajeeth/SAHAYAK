import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { applicationAPI } from '../services/api';
import { Application } from '../types';
import { useTranslation } from '../utils/i18n';
import { FileText, ArrowRight, Clock, CheckCircle, AlertCircle } from 'lucide-react';

const statusConfig: Record<string, { color: string; icon: any; label: string }> = {
  draft: { color: 'bg-surface-100 text-surface-600', icon: FileText, label: 'Draft' },
  submitted: { color: 'bg-blue-100 text-blue-700', icon: Clock, label: 'Submitted' },
  under_review: { color: 'bg-amber-100 text-amber-700', icon: Clock, label: 'Under Review' },
  approved: { color: 'bg-emerald-100 text-emerald-700', icon: CheckCircle, label: 'Approved' },
  rejected: { color: 'bg-red-100 text-red-700', icon: AlertCircle, label: 'Rejected' },
  disbursed: { color: 'bg-purple-100 text-purple-700', icon: CheckCircle, label: 'Disbursed' },
};

const stages = ['DRAFT', 'SCA_DISTRICT', 'SCA_HEAD', 'NSFDC_DESK', 'PCC', 'CMD', 'LOI', 'DISBURSEMENT'];

export default function ApplicationsPage() {
  const [applications, setApplications] = useState<Application[]>([]);
  const [loading, setLoading] = useState(true);

  const { t } = useTranslation();

  useEffect(() => {
    applicationAPI.list().then(r => { setApplications(r.applications); setLoading(false); });
  }, []);

  const formatCurrency = (n: number) =>
    new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(n);

  return (
    <div className="space-y-6 animate-fade-in">
      <div>
        <h1 className="text-3xl font-bold text-surface-900">{t('app.title')}</h1>
        <p className="text-surface-500 mt-1">{t('app.subtitle')}</p>
      </div>

      {loading ? (
        <div className="space-y-4">
          {[1, 2, 3].map(i => <div key={i} className="card p-6 animate-pulse"><div className="h-6 bg-surface-100 rounded w-1/2 mb-3" /><div className="h-4 bg-surface-100 rounded w-full" /></div>)}
        </div>
      ) : applications.length === 0 ? (
        <div className="card-elevated p-12 text-center">
          <FileText className="w-12 h-12 text-surface-300 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-surface-600">No applications yet</h3>
          <p className="text-surface-400 mt-1 mb-4">Start by finding a matching scheme</p>
          <Link to="/recommend" className="btn-primary inline-flex items-center gap-2">
            Find a Scheme <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      ) : (
        <div className="space-y-4">
          {applications.map((app, i) => {
            const sc = statusConfig[app.status] || statusConfig.draft;
            const currentStageIdx = app.current_stage ? stages.indexOf(app.current_stage) : 0;
            const progress = Math.max(0, currentStageIdx) / (stages.length - 1) * 100;

            return (
              <Link
                key={app.id}
                to={`/applications/${app.id}`}
                className="block card p-6 hover:shadow-lg transition-all duration-300 animate-slide-up"
                style={{ animationDelay: `${i * 50}ms` }}
              >
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <h3 className="font-semibold text-surface-900">{app.scheme_name || 'Scheme'}</h3>
                    <p className="text-sm text-surface-500">{app.project_type} — {formatCurrency(app.project_cost)}</p>
                  </div>
                  <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold ${sc.color}`}>
                    <sc.icon className="w-3.5 h-3.5" />
                    {sc.label}
                  </span>
                </div>

                {/* Progress bar */}
                <div className="mb-3">
                  <div className="h-2 bg-surface-100 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-primary-500 to-primary-600 rounded-full transition-all duration-500" style={{ width: `${progress}%` }} />
                  </div>
                  <div className="flex justify-between mt-1 text-xs text-surface-400">
                    <span>{app.current_stage || 'Draft'}</span>
                    <span>{Math.round(progress)}%</span>
                  </div>
                </div>

                <div className="flex items-center justify-between text-sm">
                  <span className="text-surface-500">{app.partner_name || 'No partner selected'}</span>
                  <span className="text-surface-400">{new Date(app.created_at).toLocaleDateString()}</span>
                </div>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
