import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import Layout from './components/Layout';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import DashboardPage from './pages/DashboardPage';
import SchemesPage from './pages/SchemesPage';
import RecommendPage from './pages/RecommendPage';
import CalculatorPage from './pages/CalculatorPage';
import PartnersPage from './pages/PartnersPage';
import ApplicationsPage from './pages/ApplicationsPage';
import ApplicationDetailPage from './pages/ApplicationDetailPage';
import AnalyticsPage from './pages/AnalyticsPage';
import ComparePage from './pages/ComparePage';

function FullScreenSpinner() {
  return (
    <div className="flex items-center justify-center h-screen">
      <div className="animate-spin w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full" />
    </div>
  );
}

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, token, loading } = useAuth();
  if (loading) return <FullScreenSpinner />;
  // Heal broken sessions: token present but no user (or vice versa) → force re-auth
  if (!user || !token) return <Navigate to="/login" replace />;
  return <Layout>{children}</Layout>;
}

export default function App() {
  const { user, token, loading } = useAuth();

  if (loading) return <FullScreenSpinner />;

  return (
    <Routes>
      <Route path="/login" element={user && token ? <Navigate to="/" replace /> : <LoginPage />} />
      <Route path="/register" element={user && token ? <Navigate to="/" replace /> : <RegisterPage />} />
      <Route path="/" element={<ProtectedRoute><DashboardPage /></ProtectedRoute>} />
      <Route path="/schemes" element={<ProtectedRoute><SchemesPage /></ProtectedRoute>} />
      <Route path="/recommend" element={<ProtectedRoute><RecommendPage /></ProtectedRoute>} />
      <Route path="/calculator" element={<ProtectedRoute><CalculatorPage /></ProtectedRoute>} />
      <Route path="/partners" element={<ProtectedRoute><PartnersPage /></ProtectedRoute>} />
      <Route path="/applications" element={<ProtectedRoute><ApplicationsPage /></ProtectedRoute>} />
      <Route path="/applications/:id" element={<ProtectedRoute><ApplicationDetailPage /></ProtectedRoute>} />
      <Route path="/analytics" element={<ProtectedRoute><AnalyticsPage /></ProtectedRoute>} />
      <Route path="/compare" element={<ProtectedRoute><ComparePage /></ProtectedRoute>} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
