import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Shield, User } from 'lucide-react';

const demoAccounts = [
  { aadhaar: 'demo1', name: 'Priya Sharma', role: 'Entrepreneur', color: 'from-emerald-400 to-teal-500' },
  { aadhaar: 'demo2', name: 'Ravi Kumar', role: 'Entrepreneur', color: 'from-blue-400 to-indigo-500' },
  { aadhaar: 'demo3', name: 'Anita Devi', role: 'Entrepreneur', color: 'from-purple-400 to-pink-500' },
  { aadhaar: 'demo4', name: 'Suresh Patel', role: 'Entrepreneur', color: 'from-amber-400 to-orange-500' },
];

export default function LoginPage() {
  const [aadhaar, setAadhaar] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
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
    <div className="min-h-screen flex">
      {/* Left side - Hero */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-primary-600 via-primary-700 to-accent-700 p-12 flex-col justify-between relative overflow-hidden">
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-20 left-20 w-72 h-72 bg-white rounded-full blur-3xl" />
          <div className="absolute bottom-20 right-20 w-96 h-96 bg-accent-300 rounded-full blur-3xl" />
        </div>
        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-16">
            <div className="w-12 h-12 bg-white/20 backdrop-blur rounded-2xl flex items-center justify-center">
              <Shield className="w-7 h-7 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-white">Surakshit</h1>
              <p className="text-white/70 text-sm">Priority Sector Lending Platform</p>
            </div>
          </div>
          <h2 className="text-4xl font-bold text-white mb-6 leading-tight">
            Access Government Schemes<br />
            <span className="text-white/80">With Confidence</span>
          </h2>
          <p className="text-lg text-white/70 max-w-md leading-relaxed">
            Find eligible schemes, calculate repayment, and connect with authorized lending partners — all in one platform.
          </p>
        </div>
        <div className="relative z-10 flex gap-8">
          <div>
            <p className="text-3xl font-bold text-white">10+</p>
            <p className="text-white/60 text-sm">Government Schemes</p>
          </div>
          <div>
            <p className="text-3xl font-bold text-white">15+</p>
            <p className="text-white/60 text-sm">Authorized Partners</p>
          </div>
          <div>
            <p className="text-3xl font-bold text-white">4</p>
            <p className="text-white/60 text-sm">Partner Types</p>
          </div>
        </div>
      </div>

      {/* Right side - Login */}
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="w-full max-w-md animate-fade-in">
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
            <h2 className="text-2xl font-bold text-surface-900 mb-2">Welcome back</h2>
            <p className="text-surface-500">Sign in with your Aadhaar to continue</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4 mb-6">
            <div>
              <label className="block text-sm font-medium text-surface-700 mb-1.5">Aadhaar Number</label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-surface-400" />
                <input
                  type="text"
                  value={aadhaar}
                  onChange={(e) => setAadhaar(e.target.value)}
                  placeholder="Enter your Aadhaar hash"
                  className="input-field pl-11"
                  required
                />
              </div>
            </div>
            {error && (
              <p className="text-sm text-red-600 bg-red-50 px-4 py-2 rounded-lg">{error}</p>
            )}
            <button
              type="submit"
              disabled={loading || !aadhaar.trim()}
              className="btn-primary w-full disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {loading ? (
                <div className="animate-spin w-5 h-5 border-2 border-white border-t-transparent rounded-full" />
              ) : (
                'Sign In'
              )}
            </button>
          </form>

          <p className="text-center text-sm text-surface-500 mb-4">
            Don't have an account? <Link to="/register" className="text-primary-600 hover:text-primary-700 font-medium">Register here</Link>
          </p>

          <div className="relative mb-6">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-surface-200" />
            </div>
            <div className="relative flex justify-center">
              <span className="px-3 bg-white text-xs text-surface-400 uppercase tracking-wider">Quick Demo Access</span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {demoAccounts.map((account) => (
              <button
                key={account.aadhaar}
                onClick={() => handleDemo(account.aadhaar)}
                disabled={loading}
                className="group p-4 rounded-xl border border-surface-200 hover:border-primary-300 hover:bg-primary-50/50 transition-all duration-200 text-left disabled:opacity-50"
              >
                <div className={`w-8 h-8 rounded-lg bg-gradient-to-br ${account.color} flex items-center justify-center text-white font-bold text-xs mb-2`}>
                  {account.name.charAt(0)}
                </div>
                <p className="text-sm font-medium text-surface-800 group-hover:text-primary-700">{account.name}</p>
                <p className="text-xs text-surface-500">{account.role}</p>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
