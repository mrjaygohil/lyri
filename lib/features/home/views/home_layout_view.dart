import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_animated_button.dart';
import '../../../core/widgets/app_glass_container.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../../categories/views/categories_tab_view.dart';
import '../../songs/views/song_editor_view.dart';
import '../../playlists/views/playlists_tab_view.dart';
import '../../profile/views/profile_tab_view.dart';
import 'home_tab_view.dart';

class HomeLayoutView extends StatelessWidget {
  const HomeLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final AuthController authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 950;

    final List<Widget> tabs = [
      const HomeTabView(),
      const CategoriesTabView(),
      const SongEditorView(),
      const PlaylistsTabView(),
      const ProfileTabView(),
    ];

    if (isMobile) {
      return Scaffold(
        body: Obx(() => IndexedStack(
              index: controller.tabIndex.value,
              children: tabs,
            )),
        bottomNavigationBar: Obx(() => BottomNavigationBar(
              currentIndex: controller.tabIndex.value,
              onTap: controller.changeTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF0F172A),
              selectedItemColor: const Color(0xFF6366F1),
              unselectedItemColor: Colors.grey[500],
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  activeIcon: Icon(Icons.add_circle),
                  label: 'Write',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.playlist_play_outlined),
                  activeIcon: Icon(Icons.playlist_play),
                  label: 'Playlists',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Ambient Background Glow Orbs
          _buildAmbientBackgroundOrbs(context, isDark, size),

          // Main Layout Content
          SafeArea(
            child: Row(
              children: [
                _buildSidebar(context, controller, authController),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Obx(() => IndexedStack(
                          index: controller.tabIndex.value,
                          children: tabs,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBackgroundOrbs(BuildContext context, bool isDark, Size size) {
    final baseBg = AppColors.getBackground(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: baseBg),
        ),
        // Orb 1: Top-Left Indigo Glow
        Positioned(
          top: -120,
          left: -100,
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF6366F1).withOpacity(0.32),
                        const Color(0xFF8B5CF6).withOpacity(0.14),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF818CF8).withOpacity(0.40),
                        const Color(0xFFC084FC).withOpacity(0.18),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        // Orb 2: Center-Right Cyan Glow
        Positioned(
          top: size.height * 0.22,
          right: -140,
          child: Container(
            width: 580,
            height: 580,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF06B6D4).withOpacity(0.26),
                        const Color(0xFF3B82F6).withOpacity(0.10),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF38BDF8).withOpacity(0.35),
                        const Color(0xFF60A5FA).withOpacity(0.15),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, HomeController controller, AuthController authController) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimary(context);

    return GlassmorphicContainer(
      width: 270,
      height: double.infinity,
      borderRadius: 0,
      blur: 25,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.55),
          (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)).withOpacity(0.35),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.15),
          (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.05),
        ],
      ),
      child: Column(
        children: [
          // Header Branding Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient(context),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryIndigo.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lyri',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Lyrics Explorer',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 11,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Colors.white10),
          
          // Menu Items List
          Expanded(
            child: Obx(() {
              final currentIndex = controller.tabIndex.value;
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                children: [
                  _UserSidebarMenuItem(
                    index: 0,
                    currentIndex: currentIndex,
                    unselectedIcon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    title: 'Home',
                    onTap: controller.changeTab,
                  ),
                  const SizedBox(height: 8),
                  _UserSidebarMenuItem(
                    index: 1,
                    currentIndex: currentIndex,
                    unselectedIcon: Icons.explore_outlined,
                    selectedIcon: Icons.explore,
                    title: 'Explore',
                    onTap: controller.changeTab,
                  ),
                  const SizedBox(height: 8),
                  _UserSidebarMenuItem(
                    index: 2,
                    currentIndex: currentIndex,
                    unselectedIcon: Icons.add_circle_outline,
                    selectedIcon: Icons.add_circle,
                    title: 'Write Lyrics',
                    onTap: controller.changeTab,
                  ),
                  const SizedBox(height: 8),
                  _UserSidebarMenuItem(
                    index: 3,
                    currentIndex: currentIndex,
                    unselectedIcon: Icons.playlist_play_outlined,
                    selectedIcon: Icons.playlist_play,
                    title: 'Playlists',
                    onTap: controller.changeTab,
                  ),
                  const SizedBox(height: 8),
                  _UserSidebarMenuItem(
                    index: 4,
                    currentIndex: currentIndex,
                    unselectedIcon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    title: 'Profile',
                    onTap: controller.changeTab,
                  ),
                ],
              );
            }),
          ),

          // User Profile Info & Logout Section
          const Divider(height: 1, indent: 16, endIndent: 16, color: Colors.white10),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() {
                  final profile = authController.profile;
                  if (profile == null) return const SizedBox.shrink();
                  final avatarUrl = profile.avatar;
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                            ? CachedNetworkImageProvider(avatarUrl)
                            : null,
                        child: avatarUrl == null || avatarUrl.isEmpty
                            ? Text(
                                profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U',
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.fullName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryIndigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                AppAnimatedButton(
                  onTap: authController.signOut,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.35), width: 1.2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_outlined, size: 18, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserSidebarMenuItem extends StatefulWidget {
  final int index;
  final int currentIndex;
  final IconData unselectedIcon;
  final IconData selectedIcon;
  final String title;
  final ValueChanged<int> onTap;

  const _UserSidebarMenuItem({
    required this.index,
    required this.currentIndex,
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_UserSidebarMenuItem> createState() => _UserSidebarMenuItemState();
}

class _UserSidebarMenuItemState extends State<_UserSidebarMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentIndex == widget.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeIconColor = AppColors.primaryIndigo;
    final activeTextColor = isDark ? Colors.white : AppColors.primaryIndigo;
    final inactiveTextColor = AppColors.getTextSecondary(context);

    final rowChild = Row(
      children: [
        Icon(
          isSelected ? widget.selectedIcon : widget.unselectedIcon,
          color: isSelected ? activeIconColor : (isHovered ? AppColors.primaryIndigo : inactiveTextColor),
          size: 20,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              color: isSelected ? activeTextColor : (isHovered ? activeTextColor : inactiveTextColor),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ),
        if (isSelected)
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: activeIconColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: activeIconColor.withOpacity(0.8),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
      ],
    );

    Widget itemContent;
    if (isSelected) {
      itemContent = AppGlassContainer(
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        animateHover: false,
        child: rowChild,
      );
    } else {
      itemContent = AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isHovered ? AppColors.primaryIndigo.withOpacity(0.10) : Colors.transparent,
          border: isHovered
              ? Border.all(color: AppColors.primaryIndigo.withOpacity(0.15), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: rowChild,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(isHovered && !isSelected ? 6.0 : 0.0, 0, 0),
          child: itemContent,
        ),
      ),
    );
  }
}
