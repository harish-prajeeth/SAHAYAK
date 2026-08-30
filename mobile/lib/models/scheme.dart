class Scheme {
  final int id;
  final String name;
  final String code;
  final String? description;
  final double minCost;
  final double maxCost;
  final double maxLoan;
  final double interestRate;
  final int maxTenureMonths;
  final int moratoriumMonths;
  final List<String> channelTypes;
  final bool isActive;

  Scheme({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.minCost,
    required this.maxCost,
    required this.maxLoan,
    required this.interestRate,
    required this.maxTenureMonths,
    required this.moratoriumMonths,
    required this.channelTypes,
    required this.isActive,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      minCost: (json['min_cost'] ?? 0).toDouble(),
      maxCost: (json['max_cost'] ?? 0).toDouble(),
      maxLoan: (json['max_loan'] ?? 0).toDouble(),
      interestRate: (json['interest_rate'] ?? 0).toDouble(),
      maxTenureMonths: json['max_tenure_months'] ?? 0,
      moratoriumMonths: json['moratorium_months'] ?? 0,
      channelTypes: List<String>.from(json['channel_types'] ?? []),
      isActive: json['is_active'] ?? true,
    );
  }

  String get maxCostFormatted => '₹${(maxCost / 100000).toStringAsFixed(1)}L';
  String get maxLoanFormatted => '₹${(maxLoan / 100000).toStringAsFixed(1)}L';
  String get rateFormatted => '${interestRate.toStringAsFixed(1)}%';
  String get tenureFormatted => '${(maxTenureMonths / 12).toStringAsFixed(0)} years';
  String get moratoriumFormatted => '$moratoriumMonths months';
}
