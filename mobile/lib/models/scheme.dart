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
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      minCost: _toDouble(json['min_cost']),
      maxCost: _toDouble(json['max_cost']),
      maxLoan: _toDouble(json['max_loan']),
      interestRate: _toDouble(json['interest_rate']),
      maxTenureMonths: _toInt(json['max_tenure_months']),
      moratoriumMonths: _toInt(json['moratorium_months']),
      channelTypes: json['channel_types'] is List
          ? List<String>.from(json['channel_types'].map((s) => s.toString()))
          : [],
      isActive: json['is_active'] == true || json['is_active'] == 'true',
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

  String get maxCostFormatted => '₹${(maxCost / 100000).toStringAsFixed(1)}L';
  String get maxLoanFormatted => '₹${(maxLoan / 100000).toStringAsFixed(1)}L';
  String get rateFormatted => '${interestRate.toStringAsFixed(1)}%';
  String get tenureFormatted => '${(maxTenureMonths / 12).toStringAsFixed(0)} years';
  String get moratoriumFormatted => '$moratoriumMonths months';
}
