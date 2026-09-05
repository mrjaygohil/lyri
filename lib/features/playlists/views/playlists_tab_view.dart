import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../routes/app_routes.dart';
import '../controllers/playlists_controller.dart';
import '../models/playlist_model.dart';

class PlaylistsTabView extends StatelessWidget {
  const PlaylistsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final PlaylistsController controller = Get.put(PlaylistsController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CustomText(
          'My Playlists',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          useOutfit: true,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.playlists.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.playlist_play, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                const CustomText('No playlists created yet', isSecondary: true),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Create Playlist',
                  width: 180,
                  onPressed: () => _showCreatePlaylistDialog(context, controller),
                ),
              ],
            ),
          );
        }

        final size = MediaQuery.of(context).size;
        final isMobile = size.width < 600;

        return RefreshIndicator(
          onRefresh: controller.fetchPlaylists,
          color: Theme.of(context).primaryColor,
          backgroundColor: const Color(0xFF1E293B),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: isMobile
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = controller.playlists[index];
                        return Card(
                          color: const Color(0xFF1E293B),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            onTap: () => Get.toNamed(AppRoutes.playlistDetail, arguments: playlist),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.playlist_play, color: Colors.indigo, size: 30),
                            ),
                            title: CustomText(
                              playlist.title,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: CustomText(
                              '${playlist.songs.length} songs • ${playlist.visibility.capitalizeFirst}',
                              fontSize: 12,
                              color: Colors.grey[400],
                              isSecondary: true,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, controller, playlist.id, playlist.title),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size.width > 1200 ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: controller.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = controller.playlists[index];
                        return _HoverPlaylistCard(
                          playlist: playlist,
                          onTap: () => Get.toNamed(AppRoutes.playlistDetail, arguments: playlist),
                          onDelete: () => _confirmDelete(context, controller, playlist.id, playlist.title),
                        );
                      },
                    ),
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.playlists.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _showCreatePlaylistDialog(context, controller),
        );
      }),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, PlaylistsController controller) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final RxString visibility = 'public'.obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: CustomText(
          'Create Playlist',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          useOutfit: true,
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextFormField(
                  controller: titleController,
                  labelText: 'Playlist Title',
                  hintText: 'Gym Mix, Sad Songs...',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: descController,
                  labelText: 'Description (Optional)',
                  hintText: 'Songs that keep me motivated',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<String>(
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      value: visibility.value,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Visibility',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'public', child: Text('Public')),
                        DropdownMenuItem(value: 'private', child: Text('Private')),
                      ],
                      onChanged: (val) {
                        if (val != null) visibility.value = val;
                      },
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                controller.createPlaylist(
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  visibility: visibility.value,
                );
                Get.back();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PlaylistsController controller, String id, String title) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Playlist', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete the playlist "$title"? This action cannot be undone.', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              controller.deletePlaylist(id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}


class _HoverPlaylistCard extends StatefulWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HoverPlaylistCard({
    required this.playlist,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_HoverPlaylistCard> createState() => _HoverPlaylistCardState();
}

class _HoverPlaylistCardState extends State<_HoverPlaylistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: _isHovered ? 8 : 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.playlist_play, color: Colors.indigo, size: 48),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: widget.onDelete,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomText(
                    playlist.title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    '${playlist.songs.length} songs • ${playlist.visibility.capitalizeFirst}',
                    fontSize: 12,
                    color: Colors.grey[400],
                    isSecondary: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
