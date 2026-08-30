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
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      fundUtilization: (json['fund_utilization'] ?? 0).toDouble(),
      npaRate: (json['npa_rate'] ?? 0).toDouble(),
      isEligible: json['is_eligible'] ?? true,
      supportedSchemes: List<String>.from(json['supported_schemes'] ?? []),
      distance: json['distance']?.toDouble(),
    );
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
