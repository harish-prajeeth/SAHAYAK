class Partner {
  final int id;
  final String name;
  final String type;
  final String? address;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final double fundUtilization;
  final double npaRate;
  final bool isEligible;
  final List<String> supportedSchemes;
  final double? distance;

  Partner({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    required this.fundUtilization,
    required this.npaRate,
    required this.isEligible,
    required this.supportedSchemes,
    this.distance,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      fundUtilization: _toDouble(json['fund_utilization']),
      npaRate: _toDouble(json['npa_rate']),
      isEligible: json['is_eligible'] == true || json['is_eligible'] == 'true',
      supportedSchemes: json['supported_schemes'] is List
          ? List<String>.from(json['supported_schemes'].map((s) => s.toString()))
          : [],
      distance: _toDouble(json['distance']),
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

  String get typeLabel {
    switch (type) {
      case 'SCA': return 'SC Agency';
      case 'PSB': return 'Public Sector Bank';
      case 'RRB': return 'Regional Rural Bank';
      case 'NBFC-MFI': return 'Micro Finance Institution';
      default: return type;
    }
  }

  String get distanceFormatted => distance != null
      ? '${distance!.toStringAsFixed(1)} km'
      : 'N/A';
}
