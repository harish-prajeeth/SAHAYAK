import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authAPI } from '../services/api';
import { User } from '../types';

interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (aadhaarHash: string) => Promise<void>;
  logout: () => void;
  loading: boolean;
  clearSession: () => void;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  token: null,
  login: async () => {},
  logout: () => {},
  loading: true,
  clearSession: () => {},
});

export function useAuth() {
  return useContext(AuthContext);
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedToken = localStorage.getItem('token');
    const savedUser = localStorage.getItem('user');
    // Only restore complete sessions — a token without a user (or vice versa)
    // is a broken leftover that would otherwise dead-end the login flow
    if (savedToken && savedUser) {
      setToken(savedToken);
      try {
        setUser(JSON.parse(savedUser));
      } catch {
        localStorage.removeItem('user');
      }
    }
    setLoading(false);
  }, []);

  const login = async (aadhaarHash: string) => {
    const result = await authAPI.login(aadhaarHash);
    if (result.success) {
      localStorage.setItem('token', result.token);
      localStorage.setItem('user', JSON.stringify(result.user));
      setToken(result.token);
      setUser(result.user);
    }
  };

  const clearSession = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setToken(null);
    setUser(null);
  };

  const logout = clearSession;

  return (
    <AuthContext.Provider value={{ user, token, login, logout, loading, clearSession }}>
      {children}
    </AuthContext.Provider>
  );
}
