class TagModel {
  final String id;
  final String name;
  final DateTime createdAt;

  const TagModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
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

  TagModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
