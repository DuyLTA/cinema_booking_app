class CustomerModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String membershipLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.membershipLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create CustomerModel from JSON (Supabase response)
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      membershipLevel: json['membership_level'] as String? ?? 'regular',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert CustomerModel to JSON for inserting into Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'membership_level': membershipLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with some fields replaced
  CustomerModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? membershipLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'CustomerModel(id: $id, fullName: $fullName, email: $email, membershipLevel: $membershipLevel)';
}
