import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/search_helper.dart';
import '../controllers/search_controller.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: CustomTextFormField(
          controller: controller.searchFieldController,
          hintText: 'Search songs, singers, album...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          onChanged: controller.onQueryChanged,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.query.value.trim().isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    Icon(Icons.search, size: 64, color: Colors.grey[600]),
                    const SizedBox(height: 16),
                    const CustomText('Type above to find lyrics', isSecondary: true),
                    if (controller.tags.isNotEmpty) ...[
                      const SizedBox(height: 48),
                      const CustomText(
                        'Explore by Tags',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        useOutfit: true,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 10,
                        children: controller.tags.map((tag) {
                          return ActionChip(
                            label: Text('#${tag.name}'),
                            backgroundColor: const Color(0xFF1E293B),
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
                            side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            onPressed: () => controller.selectTag(tag.name),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        if (controller.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                CustomText(
                  'No results found for "${controller.query.value}"',
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
              padding: const EdgeInsets.all(16),
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final song = controller.searchResults[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        if (song.tags != null && song.tags!.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: song.tags!.map((t) {
                              final isMatch = t.name
                                  .toLowerCase()
                                  .contains(controller.query.value.toLowerCase().trim());
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isMatch
                                      ? const Color(0xFF8B5CF6).withOpacity(0.2)
                                      : const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isMatch
                                        ? const Color(0xFF8B5CF6).withOpacity(0.4)
                                        : Colors.grey.withOpacity(0.1),
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
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
