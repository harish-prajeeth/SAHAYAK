class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final double? income;
  final String? casteCategory;
  final String? education;

  User({required this.id, required this.name, required this.email, this.phone, this.income, this.casteCategory, this.education});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], email: json['email'],
      phone: json['phone'], income: (json['income'] ?? 0).toDouble(),
      casteCategory: json['caste_category'], education: json['education']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'phone': phone, 'income': income, 'caste_category': casteCategory, 'education': education};
}
