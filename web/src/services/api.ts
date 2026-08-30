const BASE = '/api';

function getToken(): string | null {
  return localStorage.getItem('token');
}

async function request<T>(url: string, options: RequestInit = {}): Promise<T> {
  const token = getToken();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string> || {}),
  };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${BASE}${url}`, { ...options, headers });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Request failed');
  return data;
}

// Auth
export const authAPI = {
  login: (aadhaarHash: string) =>
    request<{ success: boolean; token: string; user: any }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ aadhaar_hash: aadhaarHash }),
    }),
  register: (data: any) =>
    request<{ success: boolean; token: string; user: any }>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
};

// Schemes
export const schemeAPI = {
  list: () => request<{ success: boolean; schemes: any[] }>('/schemes'),
  get: (code: string) => request<{ success: boolean; scheme: any }>(`/schemes/${code}`),
  recommend: (input: any) =>
    request<{ success: boolean; recommendation: any }>('/schemes/recommend', {
      method: 'POST',
      body: JSON.stringify(input),
    }),
};

// Partners
export const partnerAPI = {
  list: () => request<{ success: boolean; partners: any[] }>('/partners'),
  nearby: (lat: number, lng: number, scheme: string, limit = 5) =>
    request<{ success: boolean; partners: any[] }>(
      `/partners/nearby?lat=${lat}&lng=${lng}&scheme=${scheme}&limit=${limit}`
    ),
  get: (id: number) => request<{ success: boolean; partner: any }>(`/partners/${id}`),
};

// Applications
export const applicationAPI = {
  list: () => request<{ success: boolean; applications: any[] }>('/applications'),
  get: (id: number) => request<{ success: boolean; application: any; history: any[] }>(`/applications/${id}`),
  create: (data: any) =>
    request<{ success: boolean; applicationId: number }>('/applications', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  submit: (id: number) =>
    request<{ success: boolean; message: string }>(`/applications/${id}/submit`, { method: 'POST' }),
  status: (id: number) =>
    request<{ success: boolean; application: any; disbursementChain: any; rejectionInfo: any; statusHistory: any[] }>(`/applications/${id}/status`),
};

// Calculator
export const calculatorAPI = {
  calculate: (params: { principal: number; interestRate: number; tenureMonths: number; moratoriumMonths?: number }) =>
    request<{ success: boolean; calculation: any }>('/calculate', {
      method: 'POST',
      body: JSON.stringify(params),
    }),
};
