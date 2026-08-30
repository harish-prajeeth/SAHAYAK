import { ReactNode, useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useTranslation, languages, Language } from '../utils/i18n';
import {
  LayoutDashboard, FileSearch, Calculator, MapPin,
  FileText, LogOut, Menu, X, Shield, ChevronRight, Sparkles, BarChart3, Globe
} from 'lucide-react';

const navItemsConfig = (t: (key: string) => string) => [
  { to: '/', icon: LayoutDashboard, label: t('nav.dashboard') },
  { to: '/schemes', icon: FileSearch, label: t('nav.schemes') },
  { to: '/recommend', icon: Sparkles, label: t('nav.recommend') },
  { to: '/calculator', icon: Calculator, label: t('nav.calculator') },
  { to: '/partners', icon: MapPin, label: t('nav.partners') },
  { to: '/applications', icon: FileText, label: t('nav.applications') },
  { to: '/analytics', icon: BarChart3, label: t('nav.analytics') },
];

export default function Layout({ children }: { children: ReactNode }) {
  const { user, logout } = useAuth();
  const { t, setLanguage, getLanguage } = useTranslation();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [langOpen, setLangOpen] = useState(false);
  const navItems = navItemsConfig(t);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const handleLangChange = (lang: Language) => {
    setLanguage(lang);
    setLangOpen(false);
    window.location.reload();
  };

  return (
    <div className="flex h-screen bg-surface-50 overflow-hidden">
      {/* Mobile overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 bg-black/50 z-40 lg:hidden" onClick={() => setSidebarOpen(false)} />
      )}

      {/* Sidebar */}
      <aside className={`fixed lg:static inset-y-0 left-0 z-50 w-72 bg-white border-r border-surface-200 transform transition-transform duration-300 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}>
        <div className="flex flex-col h-full">
          {/* Logo */}
          <div className="p-6 border-b border-surface-100">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-accent-600 rounded-xl flex items-center justify-center">
                <Shield className="w-5 h-5 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-surface-900">Surakshit</h1>
                <p className="text-xs text-surface-500">Priority Sector Lending</p>
              </div>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                onClick={() => setSidebarOpen(false)}
                className={({ isActive }) =>
                  `flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200 group ${
                    isActive
                      ? 'bg-primary-50 text-primary-700 shadow-sm'
                      : 'text-surface-600 hover:bg-surface-50 hover:text-surface-900'
                  }`
                }
              >
                {({ isActive }) => (
                  <>
                    <item.icon className={`w-5 h-5 ${isActive ? 'text-primary-600' : 'text-surface-400 group-hover:text-surface-600'}`} />
                    <span>{item.label}</span>
                    {isActive && <ChevronRight className="w-4 h-4 ml-auto text-primary-400" />}
                  </>
                )}
              </NavLink>
            ))}
          </nav>

          {/* User */}
          <div className="p-4 border-t border-surface-100">
            {/* Language Switcher */}
            <div className="mb-3 px-4">
              <div className="relative">
                <button onClick={() => setLangOpen(!langOpen)} className="flex items-center gap-2 w-full px-3 py-2 rounded-lg bg-surface-50 hover:bg-surface-100 transition-colors text-sm">
                  <Globe className="w-4 h-4 text-surface-400" />
                  <span className="text-surface-600">{languages[getLanguage()].flag} {languages[getLanguage()].native}</span>
                  <ChevronRight className={`w-3 h-3 text-surface-400 ml-auto transition-transform ${langOpen ? 'rotate-90' : ''}`} />
                </button>
                {langOpen && (
                  <div className="absolute bottom-full left-0 right-0 mb-1 bg-white border border-surface-200 rounded-xl shadow-lg overflow-hidden z-50">
                    {Object.entries(languages).map(([code, lang]) => (
                      <button
                        key={code}
                        onClick={() => handleLangChange(code as Language)}
                        className={`w-full px-4 py-2.5 text-left text-sm hover:bg-primary-50 transition-colors flex items-center gap-2 ${
                          getLanguage() === code ? 'bg-primary-50 text-primary-700 font-medium' : 'text-surface-600'
                        }`}
                      >
                        <span>{lang.flag}</span>
                        <span>{lang.native}</span>
                        <span className="text-surface-400 text-xs">{lang.name}</span>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>
            <div className="flex items-center gap-3 px-4 py-3">
              <div className="w-9 h-9 rounded-full bg-gradient-to-br from-primary-400 to-accent-500 flex items-center justify-center text-white font-semibold text-sm">
                {user?.name?.charAt(0) || 'U'}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-surface-800 truncate">{user?.name}</p>
                <p className="text-xs text-surface-500 truncate">{user?.email}</p>
              </div>
              <button onClick={handleLogout} className="p-2 rounded-lg hover:bg-red-50 text-surface-400 hover:text-red-600 transition-colors" title={t('nav.logout')}>
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </aside>

      {/* Main content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Mobile header */}
        <header className="lg:hidden flex items-center gap-4 p-4 bg-white border-b border-surface-200">
          <button onClick={() => setSidebarOpen(true)} className="p-2 rounded-lg hover:bg-surface-100">
            <Menu className="w-5 h-5 text-surface-600" />
          </button>
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-gradient-to-br from-primary-500 to-accent-600 rounded-lg flex items-center justify-center">
              <Shield className="w-4 h-4 text-white" />
            </div>
            <span className="font-bold text-surface-900">Surakshit</span>
          </div>
        </header>

        <main className="flex-1 overflow-y-auto p-6 lg:p-8">
          {children}
        </main>
      </div>
    </div>
  );
}
