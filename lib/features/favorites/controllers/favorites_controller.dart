import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../songs/models/song_model.dart';

class FavoritesController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  SupabaseClient get _client => _supabaseService.client;

  final RxList<SongModel> favoriteSongs = <SongModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      isLoading.value = true;
      if (!_supabaseService.isInitialized.value) return;

      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      final List<dynamic> response = await _client
          .from('favorites')
          .select('songs(*, categories(*), song_tags(tags(*)))')
          .eq('user_id', currentUser.id);

      final List<SongModel> songs = [];
      for (var item in response) {
        if (item['songs'] != null) {
          songs.add(SongModel.fromJson(item['songs'] as Map<String, dynamic>));
        }
      }

      favoriteSongs.value = songs;
    } catch (e, stackTrace) {
      AppLogger.e('Failed fetching favorites: $e', stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  bool isFavorite(String songId) {
    return favoriteSongs.any((s) => s.id == songId);
  }

  Future<void> toggleFavorite(SongModel song) async {
    try {
      if (!_supabaseService.isInitialized.value) return;

      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        Get.snackbar(
          'Authentication Required',
          'Please login to save favorite songs.',
          backgroundColor: Colors.amber.shade900,
          colorText: Colors.white,
        );
        return;
      }

      final alreadyFav = isFavorite(song.id);
      if (alreadyFav) {
        // Remove favorite
        await _client
            .from('favorites')
            .delete()
            .eq('user_id', currentUser.id)
            .eq('song_id', song.id);
        
        favoriteSongs.removeWhere((s) => s.id == song.id);
        Get.snackbar(
          'Removed from Favorites',
          '${song.title} has been removed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      } else {
        // Add favorite
        await _client.from('favorites').insert({
          'user_id': currentUser.id,
          'song_id': song.id,
        });

        favoriteSongs.add(song);
        Get.snackbar(
          'Added to Favorites',
          '${song.title} has been added.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.indigo,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed toggling favorite status: $e', stackTrace: stackTrace);
    }
  }
}
