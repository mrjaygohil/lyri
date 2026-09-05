class RaagModel {
  final String id;
  final String name;
  final DateTime createdAt;

  const RaagModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory RaagModel.fromJson(Map<String, dynamic> json) {
    return RaagModel(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RaagModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return RaagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
