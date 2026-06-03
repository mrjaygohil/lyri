import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../routes/app_routes.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../playlists/controllers/playlists_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final FavoritesController favoritesController = Get.put(FavoritesController());
    final PlaylistsController playlistsController = Get.put(PlaylistsController());
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CustomText(
          'My Profile',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          useOutfit: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _showLogoutConfirm(context, authController),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await favoritesController.fetchFavorites();
          await playlistsController.fetchPlaylists();
          await profileController.fetchMySongs();
        },
        color: Theme.of(context).primaryColor,
        backgroundColor: const Color(0xFF1E293B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Builder(
                  builder: (context) {
                    final size = MediaQuery.of(context).size;
                    final isMobile = size.width < 700;

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _buildProfileCard(context, authController),
                          const SizedBox(height: 24),
                          _buildStatsRow(context, favoritesController, playlistsController, profileController),
                          const SizedBox(height: 28),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: CustomText(
                              'My Uploaded Lyrics',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              useOutfit: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildUploadedList(profileController),
                          const SizedBox(height: 32),
                        ],
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),
                                _buildProfileCard(context, authController),
                                const SizedBox(height: 24),
                                _buildStatsRow(context, favoritesController, playlistsController, profileController),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),
                                const CustomText(
                                  'My Uploaded Lyrics',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  useOutfit: true,
                                ),
                                const SizedBox(height: 12),
                                _buildUploadedList(profileController),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AuthController authController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Obx(() {
          final profile = authController.profile;
          if (profile == null) return const SizedBox.shrink();
          final avatarUrl = profile.avatar;
          return Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.indigo.shade800,
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 36, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      profile.fullName,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      useOutfit: true,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      profile.email,
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.indigo.withOpacity(0.4)),
                      ),
                      child: CustomText(
                        profile.role.toUpperCase(),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    FavoritesController favoritesController,
    PlaylistsController playlistsController,
    ProfileController profileController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildStatCard(
                  context: context,
                  label: 'Favorites',
                  value: '${favoritesController.favoriteSongs.length}',
                  icon: Icons.favorite,
                  iconColor: Colors.pink,
                  onTap: () {},
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => _buildStatCard(
                  context: context,
                  label: 'Playlists',
                  value: '${playlistsController.playlists.length}',
                  icon: Icons.playlist_play,
                  iconColor: Colors.indigoAccent,
                  onTap: () => playlistsController.fetchPlaylists(),
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => _buildStatCard(
                  context: context,
                  label: 'Uploaded',
                  value: '${profileController.mySongs.length}',
                  icon: Icons.cloud_upload_outlined,
                  iconColor: Colors.tealAccent,
                  onTap: () => profileController.fetchMySongs(),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedList(ProfileController profileController) {
    return Obx(() {
      if (profileController.isLoading.value && profileController.mySongs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (profileController.mySongs.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.cloud_queue, size: 48, color: Colors.grey[600]),
                const SizedBox(height: 8),
                const CustomText(
                  'You haven\'t uploaded any lyrics yet.',
                  isSecondary: true,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: profileController.mySongs.length,
        itemBuilder: (context, index) {
          final song = profileController.mySongs[index];
          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onTap: () {
                if (song.approvalStatus == 'approved') {
                  Get.toNamed(AppRoutes.songDetail, arguments: song);
                } else {
                  Get.snackbar(
                    'Song Under Review',
                    'This lyrics submission is currently pending moderator approval.',
                    backgroundColor: Colors.amber.shade900,
                    colorText: Colors.white,
                  );
                }
              },
              title: CustomText(
                song.title,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                children: [
                  CustomText(
                    song.singerName ?? 'Unknown Artist',
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  _buildApprovalStatusBadge(song.approvalStatus),
                ],
              ),
              trailing: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmDeleteSong(context, profileController, song.id, song.title),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            CustomText(
              value,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            CustomText(
              label,
              fontSize: 12,
              color: Colors.grey[400],
              isSecondary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalStatusBadge(String status) {
    Color badgeColor;
    Color textColor;
    String label;

    switch (status) {
      case 'approved':
        badgeColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green.shade400;
        label = 'Approved';
        break;
      case 'pending':
        badgeColor = Colors.amber.withOpacity(0.15);
        textColor = Colors.amber.shade400;
        label = 'Pending';
        break;
      case 'rejected':
      default:
        badgeColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red.shade400;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, AuthController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              controller.signOut();
              Get.back();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSong(BuildContext context, ProfileController controller, String songId, String title) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Song', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete your lyrics for "$title"? This cannot be undone.', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              controller.deleteUploadedSong(songId);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
