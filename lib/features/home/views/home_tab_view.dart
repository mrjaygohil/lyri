import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/app_glass_container.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../../songs/models/song_model.dart';
import '../../categories/models/category_model.dart';
import '../../authentication/controllers/auth_controller.dart';

class HomeTabView extends StatelessWidget {
  const HomeTabView({super.key});

  Widget _buildTopBar(BuildContext context, bool isMobile) {
    if (isMobile) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.search),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    CustomText(
                      'Search songs, singers, album...',
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Notifications',
                'No new notifications.',
                backgroundColor: Colors.indigo,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final AuthController authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 950;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient(context),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.music_note, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const CustomText(
                    'Lyri',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    useOutfit: true,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => Get.toNamed(AppRoutes.search),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {
                    Get.snackbar(
                      'Notifications',
                      'No new notifications.',
                      backgroundColor: Colors.indigo,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final profile = authController.profile;
                  final avatarUrl = profile?.avatar;
                  return GestureDetector(
                    onTap: () {
                      controller.changeTab(4);
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.indigo.shade800,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? const Icon(Icons.person, size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                }),
                const SizedBox(width: 16),
              ],
            )
          : null,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchHomeData,
          color: Theme.of(context).primaryColor,
          backgroundColor: const Color(0xFF1E293B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context, isMobile),
                    const SizedBox(height: 16),

                    // Welcome header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final name = authController.profile?.fullName ?? 'Music Lover';
                            return CustomText(
                              'Hello, $name 👋',
                              fontSize: 16,
                              color: Colors.grey[400],
                              isSecondary: true,
                            );
                          }),
                          const SizedBox(height: 4),
                          const CustomText(
                            'Find your favorite lyrics',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            useOutfit: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Featured Categories section
                    _buildSectionHeader('Featured Categories', () {
                      controller.changeTab(1); // Go to categories tab
                    }),
                    const SizedBox(height: 12),
                    _buildCategoryList(controller.featuredCategories),

                    const SizedBox(height: 28),

                    // Trending Songs section
                    _buildSectionHeader('Trending Songs', null),
                    const SizedBox(height: 12),
                    _buildSongHorizontalList(controller.trendingSongs),

                    const SizedBox(height: 28),

                    // Recently Added section
                    _buildSectionHeader('Recently Added', null),
                    const SizedBox(height: 12),
                    _buildRecentGridList(context, controller.recentSongs, size.width < 600),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            title,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            useOutfit: true,
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const CustomText(
                'See All',
                fontSize: 14,
                color: Color(0xFF6366F1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CustomText('No categories available.', isSecondary: true),
      );
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.categorySongs, arguments: cat),
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: cat.image != null && cat.image!.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(cat.image!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.55),
                          BlendMode.srcOver,
                        ),
                      )
                    : null,
                gradient: cat.image == null || cat.image!.isEmpty
                    ? const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CustomText(
                    cat.name,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSongHorizontalList(List<SongModel> songs) {
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CustomText('No trending songs yet.', isSecondary: true),
      );
    }

    return SizedBox(
      height: 235,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.songDetail, arguments: song),
            child: Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: song.thumbnail != null && song.thumbnail!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: song.thumbnail!,
                            height: 100,
                            width: 160,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFF334155),
                              child: const Icon(Icons.music_note, color: Colors.indigo),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFF334155),
                              child: const Icon(Icons.music_note, color: Colors.indigo),
                            ),
                          )
                        : Container(
                            height: 100,
                            width: 160,
                            color: const Color(0xFF334155),
                            child: const Icon(Icons.music_note, color: Colors.indigo, size: 40),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          song.title,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        CustomText(
                          song.singerName ?? 'Unknown Artist',
                          fontSize: 12,
                          color: Colors.grey[400],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Mini lyrics preview snippet
                        CustomText(
                          song.lyrics.replaceAll('\n', ' ').trim(),
                          fontSize: 10,
                          color: Colors.grey[500],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentGridList(BuildContext context, List<SongModel> songs, bool isMobile) {
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CustomText('No recent songs.', isSecondary: true),
      );
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return _buildRecentSongCard(song);
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 12,
        childAspectRatio: 3.2,
      ),
      itemBuilder: (context, index) {
        final song = songs[index];
        return _buildRecentSongCard(song);
      },
    );
  }

  Widget _buildRecentSongCard(SongModel song) {
    return AppGlassContainer(
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        onTap: () => Get.toNamed(AppRoutes.songDetail, arguments: song),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: song.thumbnail != null && song.thumbnail!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: song.thumbnail!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFF334155),
                    child: const Icon(Icons.music_note, color: Colors.indigo, size: 20),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: const Color(0xFF334155),
                  child: const Icon(Icons.music_note, color: Colors.indigo, size: 20),
                ),
        ),
        title: CustomText(
          song.title,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              song.singerName ?? 'Unknown Artist',
              fontSize: 12,
              color: Colors.grey[400],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            CustomText(
              song.lyrics.replaceAll('\n', ' ').trim(),
              fontSize: 10,
              color: Colors.grey[500],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1E293B),
        highlightColor: const Color(0xFF334155),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 150, height: 18, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 250, height: 26, color: Colors.white),
            const SizedBox(height: 24),
            Container(width: 140, height: 18, color: Colors.white),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 120,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(width: 140, height: 18, color: Colors.white),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(
                  2,
                  (index) => Container(
                    width: 150,
                    height: 180,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
