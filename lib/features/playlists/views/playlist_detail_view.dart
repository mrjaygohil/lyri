import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lyri_web/features/songs/models/song_model.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../routes/app_routes.dart';
import '../controllers/playlists_controller.dart';
import '../models/playlist_model.dart';

class PlaylistDetailView extends StatefulWidget {
  const PlaylistDetailView({super.key});

  @override
  State<PlaylistDetailView> createState() => _PlaylistDetailViewState();
}

class _PlaylistDetailViewState extends State<PlaylistDetailView> {
  late final PlaylistModel initialPlaylist;
  late final PlaylistsController controller;

  @override
  void initState() {
    super.initState();
    initialPlaylist = Get.arguments as PlaylistModel;
    controller = Get.find<PlaylistsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: CustomText(
          initialPlaylist.title,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          useOutfit: true,
        ),
        actions: [
          Obx(() {
            final playlist = controller.playlists.firstWhere(
              (p) => p.id == initialPlaylist.id,
              orElse: () => initialPlaylist,
            );
            return IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
              tooltip: 'Add Songs',
              onPressed: () {
                Get.toNamed(AppRoutes.search, arguments: {'playlist': playlist});
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        // Find latest version of playlist from controller reactive state
        final playlist = controller.playlists.firstWhere(
          (p) => p.id == initialPlaylist.id,
          orElse: () => initialPlaylist,
        );

        if (playlist.songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note_outlined, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                const CustomText('No songs in this playlist yet', isSecondary: true),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.search, arguments: {'playlist': playlist});
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Add Songs to Playlist',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: playlist.songs.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final list = List<SongModel>.from(playlist.songs);
                final item = list.removeAt(oldIndex);
                list.insert(newIndex, item);
                // Call controller to update DB order
                controller.updatePlaylistSongsOrder(playlist.id, list.map((s) => s.id).toList());
              },
              itemBuilder: (context, index) {
                final song = playlist.songs[index];
                return Card(
                  key: ValueKey(song.id),
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    onTap: () => Get.toNamed(AppRoutes.songDetail, arguments: song),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: song.thumbnail != null && song.thumbnail!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: song.thumbnail!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFF334155),
                                    child: const Icon(Icons.music_note, color: Colors.indigo),
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: const Color(0xFF334155),
                                  child: const Icon(Icons.music_note, color: Colors.indigo),
                                ),
                        ),
                      ],
                    ),
                    title: CustomText(
                      song.title,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: CustomText(
                      song.singerName ?? 'Unknown Artist',
                      fontSize: 12,
                      color: Colors.grey[400],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // trailing: IconButton(
                    //   padding: EdgeInsets.all(19)
                    //   icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    //   onPressed: () {
                    //     controller.removeSongFromPlaylist(playlist.id, song.id);
                    //   },
                    // ),
                  ),
                );
              },
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final playlist = controller.playlists.firstWhere(
            (p) => p.id == initialPlaylist.id,
            orElse: () => initialPlaylist,
          );
          Get.toNamed(AppRoutes.search, arguments: {'playlist': playlist});
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Songs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

