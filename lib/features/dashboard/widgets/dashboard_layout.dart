import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../authentication/controllers/auth_controller.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const DashboardLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 950;

    if (isMobile) {
      // Mobile & Tablet Layout (Drawer based)
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _getRouteTitle(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        drawer: Drawer(
          child: _buildSidebarContent(context, isDrawer: true),
        ),
        body: SafeArea(
          child: Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );
    }

    // Desktop Layout (Inline Sidebar)
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Panel
          SizedBox(
            width: 260,
            child: _buildSidebarContent(context, isDrawer: false),
          ),
          
          // Main Body Content
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Title Heading
                      Text(
                        _getRouteTitle(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      // Dark/Light Theme Toggle
                      IconButton(
                        onPressed: () {
                          Get.changeThemeMode(
                            Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                          );
                        },
                        icon: Icon(
                          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actual child page content
                Expanded(
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context, {required bool isDrawer}) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
        border: isDrawer 
            ? null 
            : Border(
                right: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1,
                ),
              ),
      ),
      child: Column(
        children: [
          // Header / App Title
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
                Text(
                  LocaleKeys.appName.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Sidebar Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  title: LocaleKeys.dashboard.tr,
                  route: AppRoutes.dashboard,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  context: context,
                  icon: Icons.music_note_outlined,
                  title: LocaleKeys.songs.tr,
                  route: AppRoutes.songs,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  context: context,
                  icon: Icons.category_outlined,
                  title: LocaleKeys.categories.tr,
                  route: AppRoutes.categories,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  context: context,
                  icon: Icons.local_offer_outlined,
                  title: LocaleKeys.tags.tr,
                  route: AppRoutes.tags,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people_outline,
                  title: LocaleKeys.users.tr,
                  route: AppRoutes.users,
                  isDrawer: isDrawer,
                ),
              ],
            ),
          ),
          
          // User Profile & Logout Section
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      child: Text(
                        (authController.profile?.fullName.isNotEmpty == true)
                            ? authController.profile!.fullName[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            authController.profile?.fullName ?? 'Admin User',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            authController.profile?.role.toUpperCase() ?? 'ADMIN',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (isDrawer) Get.back(); // close drawer first
                      authController.signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(LocaleKeys.logout.tr),
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

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required bool isDrawer,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentRoute == route;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isDrawer) Get.back(); // close drawer
          if (!isSelected) {
            Get.offAllNamed(route);
          }
        },
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
                icon,
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? Colors.white 
                        : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRouteTitle() {
    switch (currentRoute) {
      case AppRoutes.dashboard:
        return LocaleKeys.dashboard.tr;
      case AppRoutes.songs:
        return LocaleKeys.songs.tr;
      case AppRoutes.categories:
        return LocaleKeys.categories.tr;
      case AppRoutes.tags:
        return LocaleKeys.tags.tr;
      case AppRoutes.users:
        return LocaleKeys.users.tr;
      default:
        return LocaleKeys.appName.tr;
    }
  }
}
