import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { applicationAPI } from '../services/api';
import { ArrowLeft, CheckCircle, Clock, Send, AlertTriangle } from 'lucide-react';

interface StageInfo {
  key: string;
  label: string;
  status: string;
}

export default function ApplicationDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [app, setApp] = useState<any>(null);
  const [chain, setChain] = useState<{ stages: StageInfo[]; currentStage: StageInfo; completedStages: number; totalStages: number } | null>(null);
  const [history, setHistory] = useState<any[]>([]);
  const [rejection, setRejection] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (id) loadStatus();
  }, [id]);

  const loadStatus = async () => {
    try {
      const r = await applicationAPI.status(Number(id));
      setApp(r.application);
      setChain(r.disbursementChain);
      setHistory(r.statusHistory);
      setRejection(r.rejectionInfo);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async () => {
    if (!id) return;
    await applicationAPI.submit(Number(id));
    setLoading(true);
    await loadStatus();
  };

  const fmt = (n: number) => new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(n);

  if (loading) return <div className="flex justify-center py-12"><div className="animate-spin w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full" /></div>;
  if (!app) return <div className="text-center py-12"><p className="text-surface-500">Application not found</p></div>;

  const progress = chain ? (chain.completedStages / chain.totalStages) * 100 : 0;

  return (
    <div className="space-y-6 animate-fade-in max-w-4xl">
      <button onClick={() => navigate('/applications')} className="flex items-center gap-2 text-surface-500 hover:text-surface-700 transition-colors">
        <ArrowLeft className="w-4 h-4" /> Back to Applications
      </button>

      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold text-surface-900">Application #{app.id}</h1>
          <p className="text-surface-500">{app.schemeName} — {app.partnerName || 'No partner selected'}</p>
        </div>
        {app.status === 'draft' && (
          <button onClick={handleSubmit} className="btn-primary flex items-center gap-2">
            <Send className="w-4 h-4" /> Submit Application
          </button>
        )}
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {[
          { label: 'Status', value: app.status?.replace('_', ' ').toUpperCase() },
          { label: 'Project Cost', value: fmt(app.projectCost) },
          { label: 'Loan Amount', value: fmt(app.loanAmount) },
          { label: 'Progress', value: `${Math.round(progress)}%` },
        ].map((item, i) => (
          <div key={i} className="stat-card text-center">
            <p className="text-xs text-surface-500">{item.label}</p>
            <p className="font-bold text-surface-900 mt-1 text-sm">{item.value}</p>
          </div>
        ))}
      </div>

      {/* 9-Step Disbursement Chain */}
      {chain && (
        <div className="card-elevated p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-semibold text-surface-900">Disbursement Pipeline</h2>
            <span className="badge-blue">{chain.completedStages}/{chain.totalStages} stages</span>
          </div>
          <div className="relative">
            {/* Progress bar */}
            <div className="absolute top-4 left-4 right-4 h-1 bg-surface-100 rounded-full">
              <div className="h-full bg-gradient-to-r from-primary-500 to-emerald-500 rounded-full transition-all duration-700" style={{ width: `${progress}%` }} />
            </div>
            {/* Stages */}
            <div className="flex justify-between relative">
              {chain.stages.map((stage, i) => {
                const isCompleted = stage.status === 'completed';
                const isCurrent = stage.status === 'current';
                return (
                  <div key={stage.key} className="flex flex-col items-center flex-1">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold z-10 transition-all duration-300 ${
                      isCompleted ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-200' :
                      isCurrent ? 'bg-primary-500 text-white shadow-lg shadow-primary-200 ring-4 ring-primary-100' :
                      'bg-surface-100 text-surface-400'
                    }`}>
                      {isCompleted ? <CheckCircle className="w-4 h-4" /> : isCurrent ? <Clock className="w-4 h-4" /> : i + 1}
                    </div>
                    <p className={`text-[10px] mt-2 text-center leading-tight max-w-[70px] ${
                      isCurrent ? 'text-primary-700 font-semibold' : isCompleted ? 'text-emerald-600' : 'text-surface-400'
                    }`}>{stage.label}</p>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* Rejection Info */}
      {rejection && (
        <div className="card-elevated p-6 border-2 border-red-200 bg-red-50/50">
          <div className="flex items-center gap-2 mb-3">
            <AlertTriangle className="w-5 h-5 text-red-500" />
            <h2 className="font-semibold text-red-700">Application Rejected</h2>
          </div>
          <div className="space-y-2 text-sm">
            <p><strong>Reason:</strong> {rejection.reason}</p>
            <p><strong>Category:</strong> {rejection.category}</p>
            <p><strong>Remediation Steps:</strong> {rejection.remediation}</p>
          </div>
        </div>
      )}

      {/* Status History Timeline */}
      <div className="card-elevated p-6">
        <h2 className="font-semibold text-surface-900 mb-4">Status History</h2>
        <div className="space-y-4">
          {history.map((entry: any, i: number) => (
            <div key={entry.id} className="flex gap-4 animate-slide-in-left" style={{ animationDelay: `${i * 50}ms` }}>
              <div className="flex flex-col items-center">
                <div className="w-3 h-3 rounded-full bg-primary-500 mt-1.5" />
                {i < history.length - 1 && <div className="w-0.5 flex-1 bg-surface-200 mt-1" />}
              </div>
              <div className="pb-4 flex-1">
                <div className="flex items-center gap-2">
                  <span className="badge-blue text-xs">{entry.stage}</span>
                  <span className="text-xs text-surface-400">{new Date(entry.created_at).toLocaleString()}</span>
                </div>
                <p className="text-sm text-surface-600 mt-1">{entry.notes}</p>
              </div>
            </div>
          ))}
          {history.length === 0 && <p className="text-surface-400 text-sm">No history yet</p>}
        </div>
      </div>
    </div>
  );
}
