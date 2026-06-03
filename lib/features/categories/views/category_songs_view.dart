import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../routes/app_routes.dart';
import '../../songs/controllers/songs_controller.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../models/category_model.dart';

class CategorySongsView extends StatefulWidget {
  const CategorySongsView({super.key});

  @override
  State<CategorySongsView> createState() => _CategorySongsViewState();
}

class _CategorySongsViewState extends State<CategorySongsView> {
  final SongsController _songsController = Get.find<SongsController>();
  final FavoritesController _favoritesController = Get.put(FavoritesController());
  late CategoryModel _category;

  @override
  void initState() {
    super.initState();
    _category = Get.arguments as CategoryModel;
    // Set filter and fetch songs asynchronously
    _songsController.selectedCategoryFilter.value = _category.id;
    _songsController.selectedStatusFilter.value = true; // only active ones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _songsController.loadSongs();
    });
  }

  @override
  void dispose() {
    // Reset filters when leaving
    _songsController.selectedCategoryFilter.value = null;
    _songsController.selectedStatusFilter.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _songsController.loadSongs();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CustomText(
          _category.name,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          useOutfit: true,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_songsController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter for approved public songs
        final displaySongs = _songsController.songs
            .where((s) => s.approvalStatus == 'approved' && s.visibility == 'public')
            .toList();

        if (displaySongs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_music_outlined, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                CustomText(
                  'No songs found in this category',
                  isSecondary: true,
                  color: Colors.grey[400],
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _songsController.loadSongs(),
          color: theme.primaryColor,
          backgroundColor: const Color(0xFF1E293B),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displaySongs.length,
                itemBuilder: (context, index) {
              final song = displaySongs[index];
              
              // Extract first 3 lines of lyrics for preview
              final lines = song.lyrics.split('\n');
              final previewLyrics = lines.take(3).join('\n').trim();

              return Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Get.toNamed(AppRoutes.songDetail, arguments: song),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header part of song card
                      ListTile(
                        contentPadding: const EdgeInsets.only(left: 16, right: 8, top: 8),
                        leading: ClipRRect(
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
                        title: CustomText(
                          song.title,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        subtitle: CustomText(
                          song.singerName ?? 'Unknown Singer',
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                        trailing: Obx(() {
                          final isFav = _favoritesController.isFavorite(song.id);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.pink : Colors.grey,
                            ),
                            onPressed: () => _favoritesController.toggleFavorite(song),
                          );
                        }),
                      ),
                      
                      // Lyrics Preview section
                      if (previewLyrics.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomText(
                              previewLyrics,
                              fontSize: 12,
                              color: Colors.grey[300],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                      // Tags tags
                      if (song.tags != null && song.tags!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: song.tags!.take(3).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                                ),
                                child: CustomText(
                                  '#${tag.name}',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo.shade300,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }),
    );
  }
}
