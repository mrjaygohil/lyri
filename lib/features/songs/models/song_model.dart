import '../../categories/models/category_model.dart';
import '../../tags/models/tag_model.dart';

class SongModel {
  final String id;
  final String title;
  final String lyrics;
  final String? singerName;
  final String? albumName;
  final String? language;
  final String? categoryId;
  final String? thumbnail;
  final bool status;
  final DateTime createdAt;

  // Joined relations
  final CategoryModel? category;
  final List<TagModel>? tags;

  const SongModel({
    required this.id,
    required this.title,
    required this.lyrics,
    this.singerName,
    this.albumName,
    this.language,
    this.categoryId,
    this.thumbnail,
    required this.status,
    required this.createdAt,
    this.category,
    this.tags,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    // Parse nested category
    CategoryModel? categoryObj;
    if (json['categories'] != null) {
      categoryObj = CategoryModel.fromJson(json['categories'] as Map<String, dynamic>);
    }

    // Parse nested tags from many-to-many relationship
    List<TagModel>? tagsList;
    if (json['song_tags'] != null) {
      final List<dynamic> songTagsJson = json['song_tags'] as List<dynamic>;
      tagsList = songTagsJson
          .map((st) {
            if (st['tags'] != null) {
              return TagModel.fromJson(st['tags'] as Map<String, dynamic>);
            }
            return null;
          })
          .whereType<TagModel>()
          .toList();
    } else if (json['tags'] != null) {
      final List<dynamic> tagsJson = json['tags'] as List<dynamic>;
      tagsList = tagsJson.map((t) => TagModel.fromJson(t as Map<String, dynamic>)).toList();
    }

    return SongModel(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      lyrics: (json['lyrics'] ?? '') as String,
      singerName: json['singer_name'] as String?,
      albumName: json['album_name'] as String?,
      language: json['language'] as String?,
      categoryId: json['category_id'] as String?,
      thumbnail: json['thumbnail'] as String?,
      status: (json['status'] ?? true) as bool,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      category: categoryObj,
      tags: tagsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lyrics': lyrics,
      'singer_name': singerName,
      'album_name': albumName,
      'language': language,
      'category_id': categoryId,
      'thumbnail': thumbnail,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? lyrics,
    String? singerName,
    String? albumName,
    String? language,
    String? categoryId,
    String? thumbnail,
    bool? status,
    DateTime? createdAt,
    CategoryModel? category,
    List<TagModel>? tags,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lyrics: lyrics ?? this.lyrics,
      singerName: singerName ?? this.singerName,
      albumName: albumName ?? this.albumName,
      language: language ?? this.language,
      categoryId: categoryId ?? this.categoryId,
      thumbnail: thumbnail ?? this.thumbnail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }
}
