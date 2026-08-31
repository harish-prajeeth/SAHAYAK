export interface User {
  id: number;
  name: string;
  email: string;
  phone: string;
  income: number;
  caste_category: string;
  education: string;
}

export interface Scheme {
  id: number;
  name: string;
  code: string;
  description: string;
  min_cost: number;
  max_cost: number;
  max_loan: number;
  interest_rate: number;
  max_tenure_months: number;
  moratorium_months: number;
  channel_types: string;
  is_active: number;
}

export interface Partner {
  id: number;
  name: string;
  type: string;
  address: string;
  phone: string;
  email: string;
  latitude: number;
  longitude: number;
  fund_utilization: number;
  npa_rate: number;
  is_eligible: number;
  supported_schemes: string;
  distance?: number;
  fundStatus?: string;
  npaStatus?: string;
}

export interface Application {
  id: number;
  user_id: number;
  scheme_id: number;
  partner_id: number;
  project_type: string;
  project_cost: number;
  loan_amount: number;
  status: string;
  current_stage: string | null;
  scheme_name?: string;
  scheme_code?: string;
  partner_name?: string;
  created_at: string;
  updated_at: string;
}

export interface Recommendation {
  primary?: {
    scheme: string;
    code: string;
    matchScore: number;
    approvalProbability: number;
    details: Scheme | null;
    rationale: string;
    note?: string;
  };
  alternatives: { scheme: string; code: string; rate: string }[];
  error?: string;
  userInput: Record<string, any>;
}

export interface Calculation {
  eqi: number;
  emi: number;
  totalPayment: number;
  totalInterest: number;
  moratoriumInterest: number;
  accumulatedPrincipal: number;
  effectivePrincipal: number;
  quarterlyRate: number;
  totalQuarters: number;
  moratoriumQuarters: number;
  repaymentQuarters: number;
  effectiveTenure: number;
  moratoriumMonths: number;
  quarterlySchedule: { quarter: number; phase: string; eqi: number; principal: number; interest: number; capitalizedInterest: number; balance: number }[];
  yearlySummary: { year: number; quarters: number; principalPaid: number; interestPaid: number; totalPaid: number; endingBalance: number }[];
}

export interface HistoryEntry {
  id: number;
  application_id: number;
  stage: string;
  status: string;
  notes: string;
  created_at: string;
}
