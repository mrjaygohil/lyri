import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/playlist_model.dart';

class PlaylistsController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  SupabaseClient get _client => _supabaseService.client;

  final RxList<PlaylistModel> playlists = <PlaylistModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    try {
      isLoading.value = true;
      if (!_supabaseService.isInitialized.value) return;

      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      // Select playlists and their related songs
      final List<dynamic> response = await _client
          .from('playlists')
          .select('*, playlist_songs(*, songs(*, categories(*))))')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      playlists.value = response
          .map((json) => PlaylistModel.fromJson(json as Map<String, dynamic>))
          .toList();

    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch playlists: $e', stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPlaylist({
    required String title,
    String? description,
    String? coverImage,
    String visibility = 'public',
  }) async {
    try {
      if (!_supabaseService.isInitialized.value) return;

      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      final playlistData = {
        'user_id': currentUser.id,
        'title': title,
        'description': description,
        'cover_image': coverImage,
        'visibility': visibility,
      };

      await _client.from('playlists').insert(playlistData);
      await fetchPlaylists();
      
      Get.snackbar(
        'Success',
        'Playlist "$title" created successfully.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create playlist: $e', stackTrace: stackTrace);
      Get.snackbar(
        'Error',
        'Failed to create playlist: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      if (!_supabaseService.isInitialized.value) return;

      // 1. Get max order_no in the playlist
      final List<dynamic> orders = await _client
          .from('playlist_songs')
          .select('order_no')
          .eq('playlist_id', playlistId)
          .order('order_no', ascending: false)
          .limit(1);

      int nextOrder = 0;
      if (orders.isNotEmpty) {
        nextOrder = (orders.first['order_no'] as int) + 1;
      }

      // 2. Insert playlist_song junction
      await _client.from('playlist_songs').insert({
        'playlist_id': playlistId,
        'song_id': songId,
        'order_no': nextOrder,
      });

      // 3. Refresh playlists list
      await fetchPlaylists();

      Get.snackbar(
        'Added to Playlist',
        'Song has been added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.indigo,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed adding song to playlist: $e', stackTrace: stackTrace);
      Get.snackbar(
        'Error',
        'Song already exists in this playlist.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      if (!_supabaseService.isInitialized.value) return;

      await _client
          .from('playlist_songs')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);

      await fetchPlaylists();

      Get.snackbar(
        'Removed from Playlist',
        'Song removed from playlist.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed removing song from playlist: $e', stackTrace: stackTrace);
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      if (!_supabaseService.isInitialized.value) return;

      await _client.from('playlists').delete().eq('id', playlistId);
      await fetchPlaylists();

      Get.snackbar(
        'Success',
        'Playlist deleted successfully.',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed deleting playlist: $e', stackTrace: stackTrace);
    }
  }

  // Update song ordering inside a playlist
  Future<void> updatePlaylistSongsOrder(String playlistId, List<String> songIds) async {
    try {
      if (!_supabaseService.isInitialized.value) return;

      final List<Future> updates = [];
      for (int i = 0; i < songIds.length; i++) {
        updates.add(
          _client
              .from('playlist_songs')
              .update({'order_no': i})
              .eq('playlist_id', playlistId)
              .eq('song_id', songIds[i])
        );
      }
      await Future.wait(updates);
      await fetchPlaylists();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update playlist songs order: $e', stackTrace: stackTrace);
    }
  }
}
