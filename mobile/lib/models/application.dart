class Application {
  final int id;
  final int userId;
  final int schemeId;
  final int? partnerId;
  final String? projectType;
  final double? projectCost;
  final double? loanAmount;
  final String status;
  final String? currentStage;
  final String? rejectionReason;
  final String? rejectionCategory;
  final String? remediationSteps;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? schemeName;
  final String? schemeCode;
  final String? partnerName;

  Application({
    required this.id,
    required this.userId,
    required this.schemeId,
    this.partnerId,
    this.projectType,
    this.projectCost,
    this.loanAmount,
    required this.status,
    this.currentStage,
    this.rejectionReason,
    this.rejectionCategory,
    this.remediationSteps,
    required this.createdAt,
    required this.updatedAt,
    this.schemeName,
    this.schemeCode,
    this.partnerName,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      schemeId: _toInt(json['scheme_id']),
      partnerId: _toInt(json['partner_id']),
      projectType: json['project_type'],
      projectCost: _toDouble(json['project_cost']),
      loanAmount: _toDouble(json['loan_amount']),
      status: json['status'] ?? 'draft',
      currentStage: json['current_stage'],
      rejectionReason: json['rejection_reason'],
      rejectionCategory: json['rejection_category'],
      remediationSteps: json['remediation_steps'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
      schemeName: json['scheme_name'],
      schemeCode: json['scheme_code'],
      partnerName: json['partner_name'],
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String get statusLabel {
    switch (status) {
      case 'draft': return 'Draft';
      case 'submitted': return 'Submitted';
      case 'under_review': return 'Under Review';
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      case 'disbursed': return 'Disbursed';
      default: return status;
    }
  }

  String? get projectCostFormatted =>
      projectCost != null ? '₹${(projectCost! / 100000).toStringAsFixed(2)}L' : null;

  String? get loanAmountFormatted =>
      loanAmount != null ? '₹${(loanAmount! / 100000).toStringAsFixed(2)}L' : null;
}

/// 9-step NSFDC disbursement chain
class DisbursementStage {
  final String id;
  final String name;
  final String description;
  final bool completed;
  final bool current;
  final String? notes;
  final DateTime? timestamp;

  DisbursementStage({
    required this.id,
    required this.name,
    required this.description,
    required this.completed,
    required this.current,
    this.notes,
    this.timestamp,
  });

  factory DisbursementStage.fromJson(Map<String, dynamic> json) {
    return DisbursementStage(
      id: json['stage'] ?? '',
      name: json['stage'] ?? '',
      description: json['notes'] ?? '',
      completed: json['status'] == 'completed',
      current: json['status'] == 'current',
      notes: json['notes'],
      timestamp: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  /// Full 9-step chain definition
  static const List<Map<String, String>> chainSteps = [
    {'id': 'SCA_DISTRICT', 'name': 'SCA District Office', 'desc': 'District-level review and verification'},
    {'id': 'SCA_HEAD', 'name': 'SCA Head Office', 'desc': 'State agency consolidation and approval'},
    {'id': 'NSFDC_DESK', 'name': 'NSFDC Project & Banking Desk', 'desc': 'National fund desk review'},
    {'id': 'PCC', 'name': 'Project Clearance Committee', 'desc': 'Committee clearance and approval'},
    {'id': 'CMD', 'name': 'Chairman-cum-Managing Director', 'desc': 'CMD final approval'},
    {'id': 'LOI', 'name': 'Letter of Intent Issuance', 'desc': 'LOI issued to applicant'},
    {'id': 'NSFDC_DISB', 'name': 'NSFDC Disbursement', 'desc': 'Funds released from NSFDC'},
    {'id': 'PARTNER_DISB', 'name': 'Channel Partner Disbursement', 'desc': 'Funds passed through partner'},
    {'id': 'COMPLETE', 'name': 'Loan Fully Disbursed', 'desc': 'Loan amount credited to beneficiary'},
  ];
}
