import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../songs/models/song_model.dart';

class ProfileController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  SupabaseClient get _client => _supabaseService.client;

  final RxList<SongModel> mySongs = <SongModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMySongs();
  }

  Future<void> fetchMySongs() async {
    try {
      isLoading.value = true;
      if (!_supabaseService.isInitialized.value) return;

      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      final List<dynamic> response = await _client
          .from('songs')
          .select('*, categories(*), song_tags(tags(*))')
          .eq('created_by', currentUser.id)
          .order('created_at', ascending: false);

      mySongs.value = response
          .map((json) => SongModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch user uploaded songs: $e', stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUploadedSong(String songId) async {
    try {
      if (!_supabaseService.isInitialized.value) return;
      await _client.from('songs').delete().eq('id', songId);
      mySongs.removeWhere((s) => s.id == songId);
    } catch (e, stackTrace) {
      AppLogger.e('Failed deleting user song: $e', stackTrace: stackTrace);
    }
  }
}
