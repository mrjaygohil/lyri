class CategoryModel {
  final String id;
  final String name;
  final String? image;
  final bool status;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.image,
    required this.status,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      image: json['image'] as String?,
      status: (json['status'] ?? true) as bool,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? image,
    bool? status,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
