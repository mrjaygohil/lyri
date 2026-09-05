import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/widgets/app_animated_button.dart';
import '../../../core/widgets/app_glass_container.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/search_helper.dart';
import '../controllers/search_controller.dart';
import '../../playlists/controllers/playlists_controller.dart';
import '../../playlists/models/playlist_model.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle baseStyle,
    TextStyle highlightStyle,
  ) {
    if (query.isEmpty) return Text(text, style: baseStyle);
    final segments = SearchHelper.highlightSegments(text, query);
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: segments.map((seg) {
          return TextSpan(
            text: seg.key,
            style: seg.value ? highlightStyle : null,
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SongSearchController controller = Get.put(SongSearchController());
    final PlaylistsController playlistsController = Get.put(PlaylistsController());

    PlaylistModel? targetPlaylist;
    if (Get.arguments is Map && (Get.arguments as Map).containsKey('playlist')) {
      targetPlaylist = (Get.arguments as Map)['playlist'] as PlaylistModel?;
    } else if (Get.arguments is PlaylistModel) {
      targetPlaylist = Get.arguments as PlaylistModel?;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => CustomTextFormField(
          controller: controller.searchFieldController,
          hintText: targetPlaylist != null 
              ? 'Search to add to "${targetPlaylist.title}"...' 
              : 'Search songs, singers, album...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: controller.hasActiveFilters
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: controller.clearAllFilters,
                )
              : null,
          onChanged: controller.onQueryChanged,
        )),
      ),
      body: Column(
        children: [
          if (targetPlaylist != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.playlist_add_check, color: Color(0xFF818CF8), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomText(
                      'Adding songs to: ${targetPlaylist.title}',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          // Multi-Select Tags & Raags Accordion/Section with scrollable constrained box
          Obx(() {
            if (controller.tags.isEmpty && controller.raags.isEmpty) {
              return const SizedBox.shrink();
            }
            final int activeFilterCount = controller.selectedTags.length + controller.selectedRaags.length;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                visualDensity: VisualDensity.compact,
                collapsedBackgroundColor: const Color(0xFF1E293B),
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Row(
                  children: [
                    const Icon(Icons.tune, size: 18, color: Color(0xFF818CF8)),
                    const SizedBox(width: 8),
                    const CustomText(
                      'Filter by Tags & Raags (Multi-Select)',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    if (activeFilterCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$activeFilterCount selected',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.tags.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const CustomText('Select Tags:', fontSize: 12, isSecondary: true),
                                if (controller.selectedTags.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      controller.selectedTags.clear();
                                      controller.searchSongs();
                                    },
                                    child: const Text(
                                      'Clear tags',
                                      style: TextStyle(color: Colors.indigoAccent, fontSize: 11),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: controller.tags.map((tag) {
                                final isSelected = controller.selectedTags.contains(tag.name);
                                return FilterChip(
                                  selected: isSelected,
                                  label: Text('#${tag.name}'),
                                  selectedColor: const Color(0xFF6366F1),
                                  backgroundColor: const Color(0xFF0F172A),
                                  checkmarkColor: Colors.white,
                                  showCheckmark: true,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[300],
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF6366F1).withValues(alpha: 0.3),
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  onSelected: (_) => controller.toggleTag(tag.name),
                                );
                              }).toList(),
                            ),
                          ],
                          if (controller.raags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const CustomText('Select Raags:', fontSize: 12, isSecondary: true),
                                if (controller.selectedRaags.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      controller.selectedRaags.clear();
                                      controller.searchSongs();
                                    },
                                    child: const Text(
                                      'Clear raags',
                                      style: TextStyle(color: Colors.purpleAccent, fontSize: 11),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: controller.raags.map((raag) {
                                final isSelected = controller.selectedRaags.contains(raag.name);
                                return FilterChip(
                                  selected: isSelected,
                                  label: Text('#${raag.name}'),
                                  selectedColor: Colors.purple,
                                  backgroundColor: const Color(0xFF0F172A),
                                  checkmarkColor: Colors.white,
                                  showCheckmark: true,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[300],
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? Colors.purpleAccent : Colors.purple.withValues(alpha: 0.4),
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  onSelected: (_) => controller.toggleRaag(raag.name),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Active Filters Badges Row (if any)
          Obx(() {
            if (!controller.hasActiveFilters) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Active Filters: ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    if (controller.query.value.trim().isNotEmpty) ...[
                      InputChip(
                        label: Text('Query: "${controller.query.value}"'),
                        onDeleted: controller.clearSearchText,
                        deleteIconColor: Colors.white,
                        backgroundColor: const Color(0xFF334155),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 6),
                    ],
                    ...controller.selectedTags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text('#$tag'),
                            onDeleted: () => controller.toggleTag(tag),
                            deleteIconColor: Colors.white,
                            backgroundColor: const Color(0xFF6366F1),
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            visualDensity: VisualDensity.compact,
                          ),
                        )),
                    ...controller.selectedRaags.map((raag) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text('#$raag'),
                            onDeleted: () => controller.toggleRaag(raag),
                            deleteIconColor: Colors.white,
                            backgroundColor: Colors.purple,
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            visualDensity: VisualDensity.compact,
                          ),
                        )),
                  ],
                ),
              ),
            );
          }),

          // Song List with Infinite Scroll
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final songs = controller.displayedSongs;
              if (songs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.hasActiveFilters ? Icons.search_off : Icons.music_off,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        controller.hasActiveFilters
                            ? 'No songs match your active filters'
                            : 'No songs available in database',
                        isSecondary: true,
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: songs.length + (controller.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == songs.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        );
                      }

                      final song = songs[index];
                      return AppGlassContainer(
                        borderRadius: 14,
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: () => Get.toNamed(AppRoutes.songDetail, arguments: song),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          onTap: () => Get.toNamed(AppRoutes.songDetail, arguments: song),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: song.thumbnail != null && song.thumbnail!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: song.thumbnail!,
                                    width: 54,
                                    height: 54,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: const Color(0xFF334155),
                                      child: const Icon(Icons.music_note, color: Colors.indigo),
                                    ),
                                  )
                                : Container(
                                    width: 54,
                                    height: 54,
                                    color: const Color(0xFF334155),
                                    child: const Icon(Icons.music_note, color: Colors.indigo),
                                  ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: _buildHighlightedText(
                              song.title,
                              controller.query.value,
                              const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Outfit',
                              ),
                              const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w900),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHighlightedText(
                                song.singerName ?? 'Unknown Artist',
                                controller.query.value,
                                TextStyle(fontSize: 12, color: Colors.grey[400], fontFamily: 'Inter'),
                                const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (song.tags != null && song.tags!.isNotEmpty) ...[
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: song.tags!.map((t) {
                                    final isTagSelected = controller.selectedTags.contains(t.name);
                                    final isMatch = isTagSelected ||
                                        (controller.query.value.trim().isNotEmpty &&
                                            t.name
                                                .toLowerCase()
                                                .contains(controller.query.value.toLowerCase().trim()));
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isMatch
                                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                                            : const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isMatch
                                              ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                                              : Colors.grey.withValues(alpha: 0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '#${t.name}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: isMatch ? FontWeight.bold : FontWeight.normal,
                                          color: isMatch ? const Color(0xFFC084FC) : Colors.grey[400],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 6),
                              ],
                              if (song.raags != null && song.raags!.isNotEmpty) ...[
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: song.raags!.map((r) {
                                    final isRaagSelected = controller.selectedRaags.contains(r.name);
                                    final isMatch = isRaagSelected ||
                                        (controller.query.value.trim().isNotEmpty &&
                                            r.name
                                                .toLowerCase()
                                                .contains(controller.query.value.toLowerCase().trim()));
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isMatch
                                            ? Colors.purple.withValues(alpha: 0.2)
                                            : const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isMatch
                                              ? Colors.purple.withValues(alpha: 0.4)
                                              : Colors.grey.withValues(alpha: 0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '#${r.name}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: isMatch ? FontWeight.bold : FontWeight.normal,
                                          color: isMatch ? Colors.purpleAccent : Colors.grey[400],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                          trailing: targetPlaylist != null
                              ? Obx(() {
                                  final currentPlaylist = playlistsController.playlists.firstWhere(
                                    (p) => p.id == targetPlaylist!.id,
                                    orElse: () => targetPlaylist!,
                                  );
                                  final isAdded = currentPlaylist.songs.any((s) => s.id == song.id);

                                  return isAdded
                                      ? InkWell(
                                          onTap: () {
                                            playlistsController.removeSongFromPlaylist(currentPlaylist.id, song.id);
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.greenAccent.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Colors.greenAccent),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check, color: Colors.greenAccent, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Added',
                                                  style: TextStyle(
                                                    color: Colors.greenAccent,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : ElevatedButton.icon(
                                          onPressed: () {
                                            playlistsController.addSongToPlaylist(currentPlaylist.id, song.id);
                                          },
                                          icon: const Icon(Icons.add, size: 16),
                                          label: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6366F1),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          ),
                                        );
                                })
                              : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
