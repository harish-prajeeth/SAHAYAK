/**
 * Application constants
 */

const STAGES = [
    { key: 'SCA_DISTRICT', label: 'SCA District Office', order: 1 },
    { key: 'SCA_HEAD', label: 'SCA Head Office', order: 2 },
    { key: 'NSFDC_DESK', label: 'NSFDC Project & Banking Desk', order: 3 },
    { key: 'PCC', label: 'Project Clearance Committee (PCC)', order: 4 },
    { key: 'CMD', label: 'Chairman-cum-Managing Director', order: 5 },
    { key: 'LOI', label: 'Letter of Intent (LOI) Issuance', order: 6 },
    { key: 'NSFDC_DISBURSEMENT', label: 'NSFDC Disbursement', order: 7 },
    { key: 'PARTNER_DISBURSEMENT', label: 'Channel Partner Disbursement', order: 8 },
    { key: 'COMPLETED', label: 'Loan Fully Disbursed', order: 9 }
];

const STAGE_LABELS = {
    'SCA_DISTRICT': 'Application received at SCA District Office',
    'SCA_HEAD': 'Application forwarded to SCA Head Office',
    'NSFDC_DESK': 'Application under review at NSFDC Project & Banking Desk',
    'PCC': 'Application under review by Project Clearance Committee',
    'CMD': 'Application approved by Chairman-cum-Managing Director',
    'LOI': 'Letter of Intent issued to channel partner',
    'NSFDC_DISBURSEMENT': 'NSFDC disbursed funds to channel partner',
    'PARTNER_DISBURSEMENT': 'Channel partner disbursed funds to beneficiary',
    'COMPLETED': 'Loan fully disbursed and application complete'
};

const APPLICATION_STATUSES = ['draft', 'submitted', 'under_review', 'approved', 'rejected', 'disbursed'];

const REJECTION_CATEGORIES = ['document', 'eligibility', 'project', 'partner'];

const PARTNER_TYPES = ['SCA', 'PSB', 'RRB', 'NBFC-MFI'];

const PROJECT_TYPES = ['Business', 'Education', 'Skill Development', 'Agriculture'];

const BUSINESS_TYPES = ['New', 'Existing'];

const EDUCATION_LEVELS = ['Illiterate', 'Primary', 'Secondary', 'Graduate', 'Post-Graduate'];

const MAX_INCOME = 500000; // ₹5 lakh

const CHANNEL_PREFERENCES = ['', 'Bank', 'NBFC-MFI'];

/**
 * NSFDC Interest Rate Spread
 * Source: NSFDC Official Website (www.nsfdc.nic.in)
 * "NSFDC charges 2.5% from the SCAs/CAs, which in turn shall charge 6.5% from the Beneficiaries."
 * "NSFDC charges 2% from the SCAs/CAs for Educational Loans, which in turn shall charge 6% from the Beneficiaries."
 */
const INTEREST_RATE_SPREAD = {
    standard: { nsfdcToSCA: 2.5, scaToBeneficiary: 6.5, spread: 4.0 },
    educational: { nsfdcToSCA: 2.0, scaToBeneficiary: 6.0, spread: 4.0 },
    source: 'NSFDC Official Website – Scheme Details Page (www.nsfdc.nic.in)'
};

module.exports = {
    STAGES, STAGE_LABELS, APPLICATION_STATUSES, REJECTION_CATEGORIES,
    PARTNER_TYPES, PROJECT_TYPES, BUSINESS_TYPES, EDUCATION_LEVELS,
    MAX_INCOME, CHANNEL_PREFERENCES, INTEREST_RATE_SPREAD
};
