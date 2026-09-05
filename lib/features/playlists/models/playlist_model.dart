import '../../songs/models/song_model.dart';

class PlaylistModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? coverImage;
  final String visibility;
  final DateTime createdAt;
  
  // Joined relation: Songs in this playlist
  final List<SongModel> songs;

  const PlaylistModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.coverImage,
    this.visibility = 'public',
    required this.createdAt,
    this.songs = const [],
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    List<SongModel> songsList = [];
    if (json['playlist_songs'] != null) {
      final List<dynamic> psJson = json['playlist_songs'] as List<dynamic>;
      // Sort by order_no to maintain user order
      psJson.sort((a, b) {
        final int aOrd = (a['order_no'] ?? 0) as int;
        final int bOrd = (b['order_no'] ?? 0) as int;
        return aOrd.compareTo(bOrd);
      });
      songsList = psJson
          .map((item) {
            if (item['songs'] != null) {
              return SongModel.fromJson(item['songs'] as Map<String, dynamic>);
            }
            return null;
          })
          .whereType<SongModel>()
          .toList();
    }

    return PlaylistModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      visibility: (json['visibility'] ?? 'public') as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      songs: songsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'cover_image': coverImage,
      'visibility': visibility,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PlaylistModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? coverImage,
    String? visibility,
    DateTime? createdAt,
    List<SongModel>? songs,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      songs: songs ?? this.songs,
    );
  }
}
