class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: (json['full_name'] ?? json['fullName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: (json['role'] ?? 'user') as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
