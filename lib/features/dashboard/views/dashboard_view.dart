import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_animated_button.dart';
import '../../../core/widgets/app_glass_container.dart';
import '../../../routes/app_routes.dart';
import '../../songs/controllers/songs_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_layout.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 950;

    final textColor = AppColors.getTextPrimary(context);
    final secondaryTextColor = AppColors.getTextSecondary(context);

    return DashboardLayout(
      currentRoute: AppRoutes.dashboard,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading metrics...',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          );
        }

        // Determine grid layout counts dynamically
        int crossAxisCount = 5;
        double childAspectRatio = 1.45;
        if (size.width < 600) {
          crossAxisCount = 1;
          childAspectRatio = 2.4;
        } else if (size.width < 950) {
          crossAxisCount = 2;
          childAspectRatio = 1.8;
        } else if (size.width < 1300) {
          crossAxisCount = 3;
          childAspectRatio = 1.5;
        }

        // Recent Songs Glassmorphic Card Widget
        final recentSongsCard = GlassmorphicContainer(
          width: double.infinity,
          height: 380,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 1.5,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(isDark ? 0.45 : 0.75),
              (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(isDark ? 0.25 : 0.45),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.35 : 0.85),
              (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.08 : 0.20),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryIndigo.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.history_rounded, color: AppColors.primaryIndigo, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          LocaleKeys.recentSongs.tr,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                    AppAnimatedButton(
                      onTap: () => Get.offAllNamed(AppRoutes.songs),
                      child: TextButton.icon(
                        onPressed: () => Get.offAllNamed(AppRoutes.songs),
                        icon: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        label: const Icon(Icons.arrow_forward_rounded, size: 14),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primaryIndigo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (controller.recentSongs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No songs found in the database.',
                        style: TextStyle(color: secondaryTextColor, fontSize: 13),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.recentSongs.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 14,
                        color: isDark ? Colors.white.withOpacity(0.08) : AppColors.lightBorder,
                      ),
                      itemBuilder: (context, index) {
                        final song = controller.recentSongs[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(AppRoutes.songDetail, arguments: song);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                              child: Row(
                                children: [
                                  // Song Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: song.thumbnail != null && song.thumbnail!.isNotEmpty
                                        ? Image.network(
                                            song.thumbnail!,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => _buildSongIcon(context),
                                          )
                                        : _buildSongIcon(context),
                                  ),
                                  const SizedBox(width: 12),

                                  // Song Title & Singer Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Outfit',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${song.singerName ?? "Unknown Artist"} • ${song.category?.name ?? "General"}',
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: song.status
                                          ? AppColors.accentEmerald.withOpacity(0.15)
                                          : AppColors.accentRose.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: song.status
                                            ? AppColors.accentEmerald.withOpacity(0.4)
                                            : AppColors.accentRose.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Text(
                                      song.status ? LocaleKeys.active.tr : LocaleKeys.inactive.tr,
                                      style: TextStyle(
                                        color: song.status ? AppColors.accentEmerald : AppColors.accentRose,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.chevron_right, size: 16, color: secondaryTextColor),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );

        // Quick Actions Glassmorphic Card Widget
        final quickActionsCard = GlassmorphicContainer(
          width: double.infinity,
          height: 380,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 1.5,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(isDark ? 0.45 : 0.75),
              (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(isDark ? 0.25 : 0.45),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.35 : 0.85),
              (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.08 : 0.20),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryViolet.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: AppColors.secondaryViolet, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionTile(
                        context: context,
                        icon: Icons.add_rounded,
                        title: LocaleKeys.addSong.tr,
                        subtitle: 'Upload lyrics, audio & details',
                        gradientColors: AppColors.songsGradient,
                        onTap: () {
                          if (Get.isRegistered<SongsController>()) {
                            Get.find<SongsController>().clearSelectedImage();
                          }
                          Get.toNamed(AppRoutes.songEditor);
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.category_rounded,
                        title: LocaleKeys.addCategory.tr,
                        subtitle: 'Organize songs by genre',
                        gradientColors: AppColors.categoriesGradient,
                        onTap: () => Get.offAllNamed(AppRoutes.categories),
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.local_offer_rounded,
                        title: LocaleKeys.addTag.tr,
                        subtitle: 'Tag songs with keywords',
                        gradientColors: AppColors.tagsGradient,
                        onTap: () => Get.offAllNamed(AppRoutes.tags),
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.graphic_eq_rounded,
                        title: LocaleKeys.addRaag.tr,
                        subtitle: 'Manage musical raga classifications',
                        gradientColors: AppColors.raagsGradient,
                        onTap: () => Get.offAllNamed(AppRoutes.raags),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        return RefreshIndicator(
          onRefresh: () => controller.loadDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Welcome Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Overview & Analytics',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentEmerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Realtime Database Metrics',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _AnimatedRefreshButton(controller: controller),
                  ],
                ),
                const SizedBox(height: 20),

                // Statistics Cards Grid (Glassmorphism Package Cards)
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _HoverStatCard(
                      title: LocaleKeys.totalSongs.tr,
                      value: '${controller.totalSongs.value}',
                      icon: Icons.library_music_rounded,
                      gradientColors: AppColors.songsGradient,
                      onTap: () => Get.offAllNamed(AppRoutes.songs),
                    ),
                    _HoverStatCard(
                      title: LocaleKeys.totalCategories.tr,
                      value: '${controller.totalCategories.value}',
                      icon: Icons.category_rounded,
                      gradientColors: AppColors.categoriesGradient,
                      onTap: () => Get.offAllNamed(AppRoutes.categories),
                    ),
                    _HoverStatCard(
                      title: LocaleKeys.totalTags.tr,
                      value: '${controller.totalTags.value}',
                      icon: Icons.local_offer_rounded,
                      gradientColors: AppColors.tagsGradient,
                      onTap: () => Get.offAllNamed(AppRoutes.tags),
                    ),
                    _HoverStatCard(
                      title: LocaleKeys.totalRaags.tr,
                      value: '${controller.totalRaags.value}',
                      icon: Icons.graphic_eq_rounded,
                      gradientColors: AppColors.raagsGradient,
                      onTap: () => Get.offAllNamed(AppRoutes.raags),
                    ),
                    _HoverStatCard(
                      title: LocaleKeys.totalUsers.tr,
                      value: '${controller.totalUsers.value}',
                      icon: Icons.people_alt_rounded,
                      gradientColors: AppColors.usersGradient,
                      onTap: () => Get.offAllNamed(AppRoutes.users),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Responsive Cards Row/Column
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      recentSongsCard,
                      const SizedBox(height: 16),
                      quickActionsCard,
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: recentSongsCard,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: quickActionsCard,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSongIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.getCardHover(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.music_note,
        color: isDark ? const Color(0xFF818CF8) : AppColors.primaryIndigo,
        size: 20,
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return _AnimatedActionTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      gradientColors: gradientColors,
      onTap: onTap,
    );
  }
}

class _AnimatedActionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _AnimatedActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_AnimatedActionTile> createState() => _AnimatedActionTileState();
}

class _AnimatedActionTileState extends State<_AnimatedActionTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimary(context);
    final secondaryTextColor = AppColors.getTextSecondary(context);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(isHovered ? 4.0 : 0.0, 0, 0),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 60,
            borderRadius: 14,
            blur: 15,
            alignment: Alignment.center,
            border: isHovered ? 1.5 : 1.0,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)).withValues(alpha: isHovered ? 0.85 : 0.65),
                (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: isHovered ? 0.55 : 0.35),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                isHovered
                    ? widget.gradientColors.first.withValues(alpha: 0.8)
                    : (isDark ? Colors.white : AppColors.primaryIndigo).withValues(alpha: 0.2),
                isHovered
                    ? widget.gradientColors.last.withValues(alpha: 0.5)
                    : (isDark ? Colors.white : AppColors.primaryIndigo).withValues(alpha: 0.05),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  AnimatedScale(
                    scale: isHovered ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: widget.gradientColors),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradientColors.first.withValues(alpha: isHovered ? 0.5 : 0.3),
                            blurRadius: isHovered ? 10 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: isHovered ? widget.gradientColors.first : textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 10,
                            fontFamily: 'Inter',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AnimatedSlide(
                    offset: isHovered ? const Offset(0.3, 0) : Offset.zero,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: isHovered ? widget.gradientColors.first : secondaryTextColor,
                    ),
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

// Glassmorphic Stat Card with Hover Micro-Animations
class _HoverStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _HoverStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_HoverStatCard> createState() => _HoverStatCardState();
}

class _HoverStatCardState extends State<_HoverStatCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimary(context);
    final secondaryTextColor = AppColors.getTextSecondary(context);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 20,
            blur: 20,
            alignment: Alignment.center,
            border: isHovered ? 2 : 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(isDark ? 0.45 : 0.75),
                (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(isDark ? 0.25 : 0.45),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isHovered
                    ? widget.gradientColors.first.withOpacity(0.9)
                    : (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.35 : 0.75),
                isHovered
                    ? widget.gradientColors.last.withOpacity(0.6)
                    : (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.08 : 0.20),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.value,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.gradientColors.first.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 20,
                    ),
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

class _AnimatedRefreshButton extends StatefulWidget {
  final DashboardController controller;
  const _AnimatedRefreshButton({required this.controller});

  @override
  State<_AnimatedRefreshButton> createState() => _AnimatedRefreshButtonState();
}

class _AnimatedRefreshButtonState extends State<_AnimatedRefreshButton> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    widget.controller.isLoading.listen((loading) {
      if (loading) {
        if (!_rotationController.isAnimating) {
          _rotationController.repeat();
        }
      } else {
        _rotationController.stop();
        _rotationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimary(context);

    return AppAnimatedButton(
      onTap: () {
        _rotationController.repeat();
        widget.controller.loadDashboardData().whenComplete(() {
          _rotationController.stop();
          _rotationController.reset();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: GlassmorphicContainer(
        width: 110,
        height: 42,
        borderRadius: 12,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.8),
            (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)).withOpacity(0.4),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.25),
            (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.05),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _rotationController,
              child: Icon(Icons.refresh_rounded, size: 16, color: textColor),
            ),
            const SizedBox(width: 6),
            Text(
              'Refresh',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
