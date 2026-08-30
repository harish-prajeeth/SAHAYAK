import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { authAPI } from '../services/api';
import { Shield, User, Mail, Phone, ArrowLeft } from 'lucide-react';

export default function RegisterPage() {
  const [form, setForm] = useState({ aadhaar_hash: '', name: '', email: '', phone: '', income: '', education: 'Graduate' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      await authAPI.register({
        ...form,
        income: Number(form.income) || 0,
      });
      // Auto-login after registration
      await login(form.aadhaar_hash);
      navigate('/');
    } catch (err: any) {
      setError(err.message || 'Registration failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-8 bg-surface-50">
      <div className="w-full max-w-md animate-fade-in">
        <Link to="/login" className="flex items-center gap-2 text-surface-500 hover:text-surface-700 mb-6 text-sm">
          <ArrowLeft className="w-4 h-4" /> Back to Login
        </Link>

        <div className="flex items-center gap-3 mb-8">
          <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-accent-600 rounded-xl flex items-center justify-center">
            <Shield className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-surface-900">Create Account</h1>
            <p className="text-xs text-surface-500">Register to access government schemes</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="card-elevated p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-surface-700 mb-1">Aadhaar Number</label>
            <input name="aadhaar_hash" type="text" value={form.aadhaar_hash} onChange={handleChange} className="input-field" placeholder="12-digit Aadhaar" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-surface-700 mb-1">Full Name</label>
            <div className="relative">
              <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-surface-400" />
              <input name="name" type="text" value={form.name} onChange={handleChange} className="input-field pl-10" placeholder="Enter your name" required />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-surface-700 mb-1">Email</label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-surface-400" />
              <input name="email" type="email" value={form.email} onChange={handleChange} className="input-field pl-10" placeholder="email@example.com" required />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-surface-700 mb-1">Phone</label>
            <div className="relative">
              <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-surface-400" />
              <input name="phone" type="tel" value={form.phone} onChange={handleChange} className="input-field pl-10" placeholder="10-digit mobile" />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-surface-700 mb-1">Annual Family Income (₹)</label>
            <input name="income" type="number" value={form.income} onChange={handleChange} className="input-field" placeholder="e.g. 280000" />
          </div>
          <div>
            <label className="block text-sm font-medium text-surface-700 mb-1">Education</label>
            <select name="education" value={form.education} onChange={handleChange} className="input-field">
              <option value="Illiterate">Illiterate</option>
              <option value="Primary">Primary</option>
              <option value="Secondary">Secondary</option>
              <option value="Graduate">Graduate</option>
              <option value="Post-Graduate">Post-Graduate</option>
            </select>
          </div>
          {error && <p className="text-sm text-red-600 bg-red-50 px-4 py-2 rounded-lg">{error}</p>}
          <button type="submit" disabled={loading} className="btn-primary w-full disabled:opacity-50 flex items-center justify-center gap-2">
            {loading ? <div className="animate-spin w-5 h-5 border-2 border-white border-t-transparent rounded-full" /> : 'Create Account'}
          </button>
        </form>
      </div>
    </div>
  );
}
