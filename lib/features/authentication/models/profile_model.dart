class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? avatar;
  final String authProvider;
  final bool isBanned;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
    this.avatar,
    this.authProvider = 'email',
    this.isBanned = false,
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
      avatar: json['avatar'] as String?,
      authProvider: (json['auth_provider'] ?? 'email') as String,
      isBanned: (json['is_banned'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'avatar': avatar,
      'auth_provider': authProvider,
      'is_banned': isBanned,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    DateTime? createdAt,
    String? avatar,
    String? authProvider,
    bool? isBanned,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      avatar: avatar ?? this.avatar,
      authProvider: authProvider ?? this.authProvider,
      isBanned: isBanned ?? this.isBanned,
    );
  }
}
