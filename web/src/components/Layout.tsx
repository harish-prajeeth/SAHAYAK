import { ReactNode, useState } from 'react';
import { NavLink, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useTranslation, languages, Language } from '../utils/i18n';
import {
  LayoutDashboard, FileSearch, Calculator, MapPin,
  FileText, LogOut, Menu, X, Shield, ChevronRight, Sparkles, BarChart3, Globe, GitCompareArrows, Bell
} from 'lucide-react';

const navItemsConfig = (t: (key: string) => string) => [
  { to: '/', icon: LayoutDashboard, label: t('nav.dashboard') },
  { to: '/schemes', icon: FileSearch, label: t('nav.schemes') },
  { to: '/recommend', icon: Sparkles, label: t('nav.recommend') },
  { to: '/calculator', icon: Calculator, label: t('nav.calculator') },
  { to: '/partners', icon: MapPin, label: t('nav.partners') },
  { to: '/applications', icon: FileText, label: t('nav.applications') },
  { to: '/analytics', icon: BarChart3, label: t('nav.analytics') },
  { to: '/compare', icon: GitCompareArrows, label: t('nav.compare') },
];

export default function Layout({ children }: { children: ReactNode }) {
  const { user, logout } = useAuth();
  const { t, setLanguage, getLanguage } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [langOpen, setLangOpen] = useState(false);
  const navItems = navItemsConfig(t);
  const currentLabel = navItems.find((i) => i.to === location.pathname)?.label;

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
    <div className="flex h-screen bg-mesh overflow-hidden">
      {/* Mobile overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-sm z-40 lg:hidden" onClick={() => setSidebarOpen(false)} />
      )}

      {/* Sidebar — dark premium */}
      <aside className={`fixed lg:static inset-y-0 left-0 z-50 w-72 bg-[#0b1220] transform transition-transform duration-300 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'} flex flex-col`}>
        {/* Ambient glow */}
        <div className="absolute inset-0 pointer-events-none overflow-hidden">
          <div className="absolute -top-24 -left-24 w-72 h-72 bg-primary-600/20 rounded-full blur-3xl" />
          <div className="absolute bottom-0 -right-24 w-72 h-72 bg-accent-600/15 rounded-full blur-3xl" />
        </div>

        <div className="relative flex flex-col h-full">
          {/* Logo */}
          <div className="p-6 border-b border-white/[0.06]">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-gradient-to-br from-primary-400 via-primary-500 to-accent-600 rounded-xl flex items-center justify-center shadow-lg shadow-primary-500/30">
                  <Shield className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h1 className="text-lg font-bold text-white tracking-tight">Surakshit</h1>
                  <p className="text-[11px] text-slate-400">Priority Sector Lending</p>
                </div>
              </div>
              <button className="lg:hidden p-1.5 rounded-lg hover:bg-white/10 text-slate-400" onClick={() => setSidebarOpen(false)}>
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
            <p className="px-4 pb-2 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-500">Main Menu</p>
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                onClick={() => setSidebarOpen(false)}
                className={({ isActive }) =>
                  `nav-item-dark ${isActive ? 'nav-item-dark-active' : 'text-slate-400 hover:text-white hover:bg-white/[0.06]'}`
                }
              >
                {({ isActive }) => (
                  <>
                    <item.icon className={`w-[18px] h-[18px] shrink-0 ${isActive ? 'text-primary-300' : 'text-slate-500 group-hover:text-slate-300'}`} />
                    <span>{item.label}</span>
                    {isActive && <ChevronRight className="w-3.5 h-3.5 ml-auto text-primary-300/70" />}
                  </>
                )}
              </NavLink>
            ))}
          </nav>

          {/* User footer */}
          <div className="p-4 border-t border-white/[0.06]">
            {/* Language Switcher */}
            <div className="mb-3">
              <div className="relative">
                <button onClick={() => setLangOpen(!langOpen)} className="flex items-center gap-2 w-full px-4 py-2.5 rounded-xl bg-white/[0.05] hover:bg-white/[0.09] transition-colors text-sm text-slate-300">
                  <Globe className="w-4 h-4 text-slate-500" />
                  <span>{languages[getLanguage()].flag} {languages[getLanguage()].native}</span>
                  <ChevronRight className={`w-3 h-3 text-slate-500 ml-auto transition-transform ${langOpen ? 'rotate-90' : ''}`} />
                </button>
                {langOpen && (
                  <div className="absolute bottom-full left-0 right-0 mb-1 bg-[#111a2e] border border-white/10 rounded-xl shadow-2xl overflow-hidden z-50 backdrop-blur-xl">
                    {Object.entries(languages).map(([code, lang]) => (
                      <button
                        key={code}
                        onClick={() => handleLangChange(code as Language)}
                        className={`w-full px-4 py-2.5 text-left text-sm hover:bg-white/[0.06] transition-colors flex items-center gap-2 ${
                          getLanguage() === code ? 'bg-primary-500/15 text-primary-200 font-medium' : 'text-slate-400'
                        }`}
                      >
                        <span>{lang.flag}</span>
                        <span>{lang.native}</span>
                        <span className="text-slate-500 text-xs ml-auto">{lang.name}</span>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>

            <div className="flex items-center gap-3 px-4 py-3 rounded-xl bg-white/[0.04] border border-white/[0.06]">
              <div className="w-9 h-9 rounded-full bg-gradient-to-br from-primary-400 to-accent-500 flex items-center justify-center text-white font-bold text-sm shadow-lg shadow-primary-500/25">
                {user?.name?.charAt(0) || 'U'}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-white truncate">{user?.name}</p>
                <p className="text-[11px] text-slate-500 truncate">{user?.email || 'Verified beneficiary'}</p>
              </div>
              <button onClick={handleLogout} className="p-2 rounded-lg hover:bg-red-500/15 text-slate-500 hover:text-red-400 transition-colors" title={t('nav.logout')}>
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </aside>

      {/* Main content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Topbar */}
        <header className="flex items-center gap-4 px-6 lg:px-8 py-4 bg-white/70 backdrop-blur-xl border-b border-surface-200/60">
          <button onClick={() => setSidebarOpen(true)} className="lg:hidden p-2 rounded-lg hover:bg-surface-100">
            <Menu className="w-5 h-5 text-surface-600" />
          </button>
          <div className="hidden lg:block">
            <p className="text-[11px] text-surface-400 font-medium uppercase tracking-wider">{t('nav.dashboard')}</p>
            <h2 className="text-sm font-bold text-surface-800">{currentLabel || t('nav.dashboard')}</h2>
          </div>
          <div className="lg:hidden flex items-center gap-2">
            <div className="w-8 h-8 bg-gradient-to-br from-primary-500 to-accent-600 rounded-lg flex items-center justify-center">
              <Shield className="w-4 h-4 text-white" />
            </div>
            <span className="font-bold text-surface-900">Surakshit</span>
          </div>

          <div className="ml-auto flex items-center gap-3">
            <span className="hidden md:inline-flex badge-green">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
              System Online
            </span>
            <button className="p-2.5 rounded-xl bg-white border border-surface-200 text-surface-500 hover:text-surface-800 hover:shadow-sm transition-all relative">
              <Bell className="w-4.5 h-4.5 w-[18px] h-[18px]" />
              <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full ring-2 ring-white" />
            </button>
          </div>
        </header>

        <main className="flex-1 overflow-y-auto p-6 lg:p-8">
          {children}
        </main>
      </div>
    </div>
  );
}
