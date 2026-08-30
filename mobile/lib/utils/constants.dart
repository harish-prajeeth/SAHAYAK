class AppConstants {
  static const String appName = 'Surakshit';
  static const String appTagline = 'Priority Sector Lending Platform';
  static const String apiBaseUrl = 'http://localhost:5000/api';

  // Scheme codes
  static const String mfsCode = 'MFS';
  static const String tlCode = 'TL';
  static const String elsCode = 'ELS';
  static const String amyCode = 'AMY';

  // Partner types
  static const String scaType = 'SCA';
  static const String psbType = 'PSB';
  static const String rrbType = 'RRB';
  static const String nbfcMfiType = 'NBFC-MFI';

  // Application statuses
  static const String statusDraft = 'draft';
  static const String statusSubmitted = 'submitted';
  static const String statusUnderReview = 'under_review';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusDisbursed = 'disbursed';

  // 9-step disbursement chain
  static const List<String> disbursementStages = [
    'SCA_DISTRICT',
    'SCA_HEAD',
    'NSFDC_DESK',
    'PCC',
    'CMD',
    'LOI',
    'NSFDC_DISB',
    'PARTNER_DISB',
    'COMPLETE',
  ];

  static const List<String> disbursementStageNames = [
    'SCA District Office',
    'SCA Head Office',
    'NSFDC Project & Banking Desk',
    'Project Clearance Committee',
    'Chairman-cum-Managing Director',
    'Letter of Intent Issuance',
    'NSFDC Disbursement',
    'Channel Partner Disbursement',
    'Loan Fully Disbursed',
  ];

  // Income limit
  static const double maxIncome = 500000;

  // Scheme limits
  static const double mfsMaxCost = 140000;
  static const double tlMaxCost = 5000000;
  static const double elsMaxCost = 4000000;
}
