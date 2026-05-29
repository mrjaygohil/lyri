import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_layout.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 950;
    
    return DashboardLayout(
      currentRoute: AppRoutes.dashboard,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Determine grid configurations based on screen width
        int crossAxisCount = 4;
        double childAspectRatio = 1.6;
        if (size.width < 600) {
          crossAxisCount = 1;
          childAspectRatio = 2.2;
        } else if (size.width < 950) {
          crossAxisCount = 2;
          childAspectRatio = 1.8;
        } else if (size.width < 1200) {
          crossAxisCount = 4;
          childAspectRatio = 1.3;
        }

        final recentSongsCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.recentSongs.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (controller.recentSongs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No songs found in the database.'),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.recentSongs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final song = controller.recentSongs[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: song.thumbnail != null
                              ? Image.network(
                                  song.thumbnail!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildSongIcon(),
                                )
                              : _buildSongIcon(),
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          '${song.singerName ?? "Unknown"} • ${song.category?.name ?? "No Category"}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: song.status
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            song.status ? LocaleKeys.active.tr : LocaleKeys.inactive.tr,
                            style: TextStyle(
                              color: song.status ? Colors.green : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );

        final quickActionsCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 20),
                _buildActionItem(
                  context: context,
                  icon: Icons.music_video_outlined,
                  title: LocaleKeys.addSong.tr,
                  color: theme.primaryColor,
                  onTap: () => Get.toNamed(AppRoutes.songs),
                ),
                _buildActionItem(
                  context: context,
                  icon: Icons.category_outlined,
                  title: LocaleKeys.addCategory.tr,
                  color: Colors.green,
                  onTap: () => Get.toNamed(AppRoutes.categories),
                ),
                _buildActionItem(
                  context: context,
                  icon: Icons.local_offer_outlined,
                  title: LocaleKeys.addTag.tr,
                  color: Colors.amber,
                  onTap: () => Get.toNamed(AppRoutes.tags),
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
                // Welcome Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Overview',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Real-time database statistics.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: controller.loadDashboardData,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Statistics Grid Layout
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      context: context,
                      title: LocaleKeys.totalSongs.tr,
                      value: '${controller.totalSongs.value}',
                      icon: Icons.music_note_outlined,
                      gradient: AppTheme.primaryGradient(context),
                    ),
                    _buildStatCard(
                      context: context,
                      title: LocaleKeys.totalCategories.tr,
                      value: '${controller.totalCategories.value}',
                      icon: Icons.category_outlined,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    _buildStatCard(
                      context: context,
                      title: LocaleKeys.totalTags.tr,
                      value: '${controller.totalTags.value}',
                      icon: Icons.local_offer_outlined,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    _buildStatCard(
                      context: context,
                      title: LocaleKeys.totalUsers.tr,
                      value: '${controller.totalUsers.value}',
                      icon: Icons.people_outline,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Dashboard Body (Responsive Row/Column)
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
                      // Recent Songs Table Card
                      Expanded(
                        flex: 2,
                        child: recentSongsCard,
                      ),
                      const SizedBox(width: 24),
                      // Quick Action Panel Card
                      Expanded(
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

  Widget _buildSongIcon() {
    return Container(
      width: 44,
      height: 44,
      color: Colors.grey.withOpacity(0.2),
      child: const Icon(Icons.music_note, color: Colors.grey, size: 20),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 500;

    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isCompact ? 11 : 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 20 : 28,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 14),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isCompact ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
