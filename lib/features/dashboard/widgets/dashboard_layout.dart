import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_animated_button.dart';
import '../../../core/widgets/app_glass_container.dart';
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

    final textColor = AppColors.getTextPrimary(context);

    if (isMobile) {
      // Mobile & Tablet Layout (Glassmorphism Drawer & Header)
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 64,
            borderRadius: 0,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(isDark ? 0.65 : 0.80),
                (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(isDark ? 0.40 : 0.50),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.25 : 0.6),
                (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.08 : 0.15),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: textColor),
              title: Text(
                _getRouteTitle(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Outfit',
                ),
              ),
              actions: [
                // Glass Theme Switcher Pill
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: GlassmorphicContainer(
                    width: 90,
                    height: 38,
                    borderRadius: 20,
                    blur: 15,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)).withOpacity(0.6),
                        (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.3),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.3),
                        (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.1),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Get.changeThemeMode(
                          Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            size: 16,
                            color: isDark ? const Color(0xFFFACC15) : AppColors.primaryIndigo,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isDark ? 'Light' : 'Dark',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.transparent,
          child: _buildSidebarContent(context, isDrawer: true),
        ),
        body: Stack(
          children: [
            _buildAmbientMeshBackground(context, isDark, size),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    // Desktop Layout (Glassmorphism Sidebar + Header + Body over Ambient Mesh)
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Layer 1: Ambient Mesh Background
          _buildAmbientMeshBackground(context, isDark, size),

          // Layer 2: Main Layout
          Row(
            children: [
              // Glassmorphism Sidebar
              SizedBox(
                width: 270,
                child: _buildSidebarContent(context, isDrawer: false),
              ),
              
              // Main Body Content Area
              Expanded(
                child: Column(
                  children: [
                    // Top Header Bar with Glassmorphic Container
                    GlassmorphicContainer(
                      width: double.infinity,
                      height: 70,
                      borderRadius: 0,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(isDark ? 0.60 : 0.78),
                          (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(isDark ? 0.35 : 0.48),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.25 : 0.60),
                          (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(isDark ? 0.08 : 0.15),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title Heading & Gradient Bar
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient(context),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _getRouteTitle(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),

                            // Right Top Controls - Glass Theme Switcher Pill
                            GlassmorphicContainer(
                              width: 135,
                              height: 40,
                              borderRadius: 20,
                              blur: 15,
                              alignment: Alignment.center,
                              border: 1,
                              linearGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)).withOpacity(0.6),
                                  (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.3),
                                ],
                              ),
                              borderGradient: LinearGradient(
                                colors: [
                                  (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.3),
                                  (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.1),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  Get.changeThemeMode(
                                    Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isDark ? Icons.light_mode : Icons.dark_mode,
                                      size: 18,
                                      color: isDark ? const Color(0xFFFACC15) : AppColors.primaryIndigo,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isDark ? 'Light Mode' : 'Dark Mode',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Actual child page content (Transparent container so mesh flows beneath)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientMeshBackground(BuildContext context, bool isDark, Size size) {
    final baseBg = AppColors.getBackground(context);
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: baseBg),
        ),
        // Orb 1: Top-Left Indigo/Violet Ambient Glow
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
        // Orb 2: Center-Right Cyan/Blue Ambient Glow
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
        // Orb 3: Bottom-Left Rose/Magenta Ambient Glow
        Positioned(
          bottom: -140,
          left: size.width * 0.18,
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFFEC4899).withOpacity(0.22),
                        const Color(0xFFA855F7).withOpacity(0.08),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFFF472B6).withOpacity(0.30),
                        const Color(0xFFE879F9).withOpacity(0.12),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarContent(BuildContext context, {required bool isDrawer}) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    final isDark = theme.brightness == Brightness.dark;

    final textColor = AppColors.getTextPrimary(context);

    return GlassmorphicContainer(
      width: 270,
      height: double.infinity,
      borderRadius: 0,
      blur: 25,
      alignment: Alignment.center,
      border: isDrawer ? 0 : 1,
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
                      LocaleKeys.appName.tr,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.primaryIndigo.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'ADMIN CONSOLE',
                        style: TextStyle(
                          color: AppColors.primaryIndigo,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.08) : AppColors.lightBorder),
          
          // Sidebar Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  title: LocaleKeys.dashboard.tr,
                  route: AppRoutes.dashboard,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 6),
                _buildMenuItem(
                  context: context,
                  icon: Icons.library_music_rounded,
                  title: LocaleKeys.songs.tr,
                  route: AppRoutes.songs,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 6),
                _buildMenuItem(
                  context: context,
                  icon: Icons.fact_check_rounded,
                  title: 'Song Approvals',
                  route: AppRoutes.songApprovals,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 6),
                _buildMenuItem(
                  context: context,
                  icon: Icons.category_rounded,
                  title: LocaleKeys.categories.tr,
                  route: AppRoutes.categories,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 6),
                _buildMenuItem(
                  context: context,
                  icon: Icons.local_offer_rounded,
                  title: LocaleKeys.tags.tr,
                  route: AppRoutes.tags,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 6),
                _buildMenuItem(
                  context: context,
                  icon: Icons.graphic_eq_rounded,
                  title: LocaleKeys.raags.tr,
                  route: AppRoutes.raags,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 6),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people_alt_rounded,
                  title: LocaleKeys.users.tr,
                  route: AppRoutes.users,
                  isDrawer: isDrawer,
                ),
              ],
            ),
          ),
          
          // User Profile & Sign Out Footer (Glassmorphic Container)
          Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.08) : AppColors.lightBorder),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 60,
                  borderRadius: 14,
                  blur: 15,
                  alignment: Alignment.center,
                  border: 1,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)).withOpacity(0.65),
                      (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.35),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.2),
                      (isDark ? Colors.white : AppColors.primaryIndigo).withOpacity(0.05),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.songsGradient,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (authController.profile?.fullName.isNotEmpty == true)
                                  ? authController.profile!.fullName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
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
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              Text(
                                authController.profile?.role.toUpperCase() ?? 'ADMIN',
                                style: const TextStyle(
                                  color: AppColors.primaryIndigo,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (isDrawer) Get.back();
                      authController.signOut();
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                    label: Text(
                      LocaleKeys.logout.tr,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.redAccent.withOpacity(0.4), width: 1),
                      backgroundColor: Colors.redAccent.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
    return _AnimatedSidebarMenuItem(
      context: context,
      icon: icon,
      title: title,
      route: route,
      currentRoute: currentRoute,
      isDrawer: isDrawer,
    );
  }

  String _getRouteTitle() {
    switch (currentRoute) {
      case AppRoutes.dashboard:
        return LocaleKeys.dashboard.tr;
      case AppRoutes.songs:
        return LocaleKeys.songs.tr;
      case AppRoutes.songApprovals:
        return 'Song Approvals';
      case AppRoutes.categories:
        return LocaleKeys.categories.tr;
      case AppRoutes.tags:
        return LocaleKeys.tags.tr;
      case AppRoutes.raags:
        return LocaleKeys.raags.tr;
      case AppRoutes.users:
        return LocaleKeys.users.tr;
      default:
        return LocaleKeys.appName.tr;
    }
  }
}

class _AnimatedSidebarMenuItem extends StatefulWidget {
  final BuildContext context;
  final IconData icon;
  final String title;
  final String route;
  final String currentRoute;
  final bool isDrawer;

  const _AnimatedSidebarMenuItem({
    required this.context,
    required this.icon,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.isDrawer,
  });

  @override
  State<_AnimatedSidebarMenuItem> createState() => _AnimatedSidebarMenuItemState();
}

class _AnimatedSidebarMenuItemState extends State<_AnimatedSidebarMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentRoute == widget.route;
    final isDark = Theme.of(widget.context).brightness == Brightness.dark;
    final activeIconColor = isDark ? const Color(0xFF818CF8) : AppColors.primaryIndigo;
    final activeTextColor = isDark ? Colors.white : AppColors.getTextPrimary(widget.context);
    final inactiveColor = AppColors.getTextSecondary(widget.context);

    final rowChild = Row(
      children: [
        AnimatedScale(
          scale: isHovered || isSelected ? 1.12 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            widget.icon,
            color: isSelected ? activeIconColor : (isHovered ? AppColors.primaryIndigo : inactiveColor),
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              color: isSelected ? activeTextColor : (isHovered ? AppColors.getTextPrimary(widget.context) : inactiveColor),
              fontWeight: isSelected || isHovered ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
        ),
        if (isSelected)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: activeIconColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: activeIconColor.withValues(alpha: 0.9),
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isHovered ? AppColors.primaryIndigo.withValues(alpha: 0.10) : Colors.transparent,
          border: isHovered
              ? Border.all(color: AppColors.primaryIndigo.withValues(alpha: 0.15), width: 1)
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
        onTap: () {
          if (widget.isDrawer) Get.back();
          if (!isSelected) {
            Get.offAllNamed(widget.route);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(isHovered && !isSelected ? 6.0 : 0.0, 0, 0),
          child: itemContent,
        ),
      ),
    );
  }
}
