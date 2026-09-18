import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useTranslation } from '../utils/i18n';
import { Shield, User, Lock, ArrowRight, Loader2, CheckCircle2, Sparkles, Landmark, Users, Globe2 } from 'lucide-react';

const demoAccounts = [
  { aadhaar: 'demo1', name: 'Priya Sharma', role: 'First-generation entrepreneur', color: 'from-emerald-400 to-teal-500' },
  { aadhaar: 'demo2', name: 'Ravi Kumar', role: 'Small business owner', color: 'from-blue-400 to-indigo-500' },
  { aadhaar: 'demo3', name: 'Anita Devi', role: 'Skill-development trainee', color: 'from-purple-400 to-pink-500' },
  { aadhaar: 'demo4', name: 'Suresh Patel', role: 'Agri-allied business', color: 'from-amber-400 to-orange-500' },
];

export default function LoginPage() {
  const [aadhaar, setAadhaar] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const { t } = useTranslation();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!aadhaar.trim()) return;
    setLoading(true);
    setError('');
    try {
      await login(aadhaar.trim());
      navigate('/');
    } catch (err: any) {
      setError(err.message || 'Login failed. Try a demo account.');
    } finally {
      setLoading(false);
    }
  };

  const handleDemo = async (aadhaarHash: string) => {
    setLoading(true);
    setError('');
    try {
      await login(aadhaarHash);
      navigate('/');
    } catch (err: any) {
      setError(err.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex bg-surface-950">
      {/* Left side - Aurora hero */}
      <div className="hidden lg:flex lg:w-[55%] bg-aurora p-14 flex-col justify-between relative overflow-hidden">
        {/* Floating orbs */}
        <div className="absolute top-24 left-16 w-40 h-40 bg-white/10 rounded-full blur-2xl animate-float-slow" />
        <div className="absolute top-1/2 right-24 w-24 h-24 bg-accent-300/20 rounded-full blur-xl animate-float-slow" style={{ animationDelay: '2s' }} />
        <div className="absolute bottom-32 left-1/3 w-32 h-32 bg-primary-300/15 rounded-full blur-2xl animate-float-slow" style={{ animationDelay: '4s' }} />

        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-20">
            <div className="w-12 h-12 bg-white/15 backdrop-blur-xl rounded-2xl flex items-center justify-center ring-1 ring-white/25">
              <Shield className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-white tracking-tight">Surakshit</h1>
              <p className="text-white/60 text-sm">Priority Sector Lending Platform</p>
            </div>
          </div>

          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-xl ring-1 ring-white/15 mb-8 w-fit">
            <Sparkles className="w-4 h-4 text-amber-300" />
            <span className="text-sm text-white/85 font-medium">Government of India · NSFDC Schemes</span>
          </div>

          <h2 className="text-5xl font-bold text-white mb-6 leading-[1.1] tracking-tight">
            Access Government<br />Schemes with<br />
            <span className="text-gradient bg-clip-text text-transparent bg-gradient-to-r from-sky-300 via-fuchsia-300 to-amber-200">Confidence.</span>
          </h2>
          <p className="text-lg text-white/65 max-w-lg leading-relaxed">
            Find eligible schemes, calculate repayments with moratorium-aware EQI, and connect with authorized lending partners — all in one platform.
          </p>
        </div>

        {/* Floating stat chips */}
        <div className="relative z-10 grid grid-cols-3 gap-4">
          {[
            { icon: Landmark, value: '10+', label: 'Government Schemes' },
            { icon: Users, value: '15+', label: 'Authorized Partners' },
            { icon: Globe2, value: '22', label: 'Languages via Bhashini' },
          ].map((s, i) => (
            <div key={i} className="p-4 rounded-2xl bg-white/[0.08] backdrop-blur-xl ring-1 ring-white/12 hover:bg-white/[0.12] transition-colors">
              <s.icon className="w-5 h-5 text-white/70 mb-3" />
              <p className="text-2xl font-bold text-white">{s.value}</p>
              <p className="text-white/55 text-xs mt-1">{s.label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Right side - Login */}
      <div className="flex-1 flex items-center justify-center p-6 lg:p-10 bg-surface-50 relative overflow-hidden">
        <div className="absolute inset-0 bg-grid-subtle opacity-60 pointer-events-none" />
        <div className="w-full max-w-md relative z-10 animate-fade-in">
          {/* Mobile logo */}
          <div className="lg:hidden flex items-center gap-3 mb-10">
            <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-accent-600 rounded-xl flex items-center justify-center">
              <Shield className="w-5 h-5 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-surface-900">Surakshit</h1>
              <p className="text-xs text-surface-500">Priority Sector Lending</p>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-bold text-surface-900 tracking-tight">Welcome back</h2>
            <p className="text-surface-500 mt-1.5">Sign in with your Aadhaar to continue</p>
          </div>

          {error && (
            <div className="mb-5 p-3.5 rounded-xl bg-red-50 border border-red-200 text-sm text-red-700 flex items-center gap-2 animate-fade-in">
              <span className="w-1.5 h-1.5 rounded-full bg-red-500" />
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="input-label">Aadhaar / Demo ID</label>
              <div className="relative">
                <User className="absolute left-4 top-1/2 -translate-y-1/2 w-[18px] h-[18px] text-surface-400" />
                <input
                  type="text"
                  value={aadhaar}
                  onChange={(e) => setAadhaar(e.target.value)}
                  placeholder="Enter your Aadhaar ID"
                  className="input-field pl-11"
                />
              </div>
            </div>

            <button type="submit" disabled={loading || !aadhaar.trim()} className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-60 disabled:hover:translate-y-0 disabled:cursor-not-allowed">
              {loading ? <Loader2 className="w-4.5 h-4.5 w-[18px] h-[18px] animate-spin" /> : <Lock className="w-[18px] h-[18px]" />}
              {loading ? 'Verifying…' : 'Sign In Securely'}
            </button>
          </form>

          <div className="my-7 flex items-center gap-3">
            <div className="flex-1 h-px bg-surface-200" />
            <span className="text-xs font-medium text-surface-400 uppercase tracking-wider">Quick demo access</span>
            <div className="flex-1 h-px bg-surface-200" />
          </div>

          <div className="space-y-2.5">
            {demoAccounts.map((acc) => (
              <button
                key={acc.aadhaar}
                onClick={() => handleDemo(acc.aadhaar)}
                disabled={loading}
                className="w-full flex items-center gap-3 p-3.5 rounded-xl bg-white border border-surface-200 hover:border-primary-300 hover:shadow-md hover:shadow-primary-500/5 transition-all text-left group disabled:opacity-60"
              >
                <div className={`w-10 h-10 rounded-full bg-gradient-to-br ${acc.color} flex items-center justify-center text-white font-bold text-sm shadow-md shrink-0`}>
                  {acc.name.charAt(0)}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold text-surface-800">{acc.name}</p>
                  <p className="text-xs text-surface-500 truncate">{acc.role}</p>
                </div>
                <ArrowRight className="w-4 h-4 text-surface-300 group-hover:text-primary-500 group-hover:translate-x-0.5 transition-all" />
              </button>
            ))}
          </div>

          <p className="text-center text-sm text-surface-500 mt-8">
            New to Surakshit?{' '}
            <Link to="/register" className="font-semibold text-primary-600 hover:text-primary-700 hover:underline underline-offset-2">
              Create an account
            </Link>
          </p>

          <div className="mt-6 flex items-center justify-center gap-1.5 text-xs text-surface-400">
            <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" />
            Aadhaar-based · JWT secured · IT Act compliant
          </div>
        </div>
      </div>
    </div>
  );
}
