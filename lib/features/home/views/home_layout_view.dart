import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
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
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          Obx(() => _buildSidebar(context, controller, authController)),
          Expanded(
            child: Obx(() => IndexedStack(
                  index: controller.tabIndex.value,
                  children: tabs,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, HomeController controller, AuthController authController) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
        border: Border(
          right: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const CustomText(
                  'Lyri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  useOutfit: true,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildSidebarItem(context, controller, 0, Icons.home_outlined, Icons.home, 'Home'),
                const SizedBox(height: 8),
                _buildSidebarItem(context, controller, 1, Icons.explore_outlined, Icons.explore, 'Explore'),
                const SizedBox(height: 8),
                _buildSidebarItem(context, controller, 2, Icons.add_circle_outline, Icons.add_circle, 'Write Lyrics'),
                const SizedBox(height: 8),
                _buildSidebarItem(context, controller, 3, Icons.playlist_play_outlined, Icons.playlist_play, 'Playlists'),
                const SizedBox(height: 8),
                _buildSidebarItem(context, controller, 4, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),

          // User Profile Info & Logout
          const Divider(height: 1),
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
                            CustomText(
                              profile.fullName,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            CustomText(
                              profile.role.toUpperCase(),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: authController.signOut,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text('Logout'),
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

  Widget _buildSidebarItem(
    BuildContext context,
    HomeController controller,
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    String title,
  ) {
    final isSelected = controller.tabIndex.value == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.changeTab(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: isSelected ? AppTheme.primaryGradient(context) : null,
            color: isSelected
                ? null
                : (isDark ? Colors.transparent : Colors.grey.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? Colors.white : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomText(
                  title,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
