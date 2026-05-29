import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../songs/models/song_model.dart';

class DashboardController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  SupabaseClient get _client => _supabaseService.client;

  final RxInt totalSongs = 0.obs;
  final RxInt totalCategories = 0.obs;
  final RxInt totalTags = 0.obs;
  final RxInt totalUsers = 0.obs;
  
  final RxList<SongModel> recentSongs = <SongModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    if (!_supabaseService.isInitialized.value) return;

    try {
      isLoading.value = true;
      AppLogger.i('Loading Dashboard metrics data...');

      // Get table counts in parallel
      final results = await Future.wait([
        _getTableCount(SupabaseConstants.tableSongs),
        _getTableCount(SupabaseConstants.tableCategories),
        _getTableCount(SupabaseConstants.tableTags),
        _getTableCount(SupabaseConstants.tableProfiles),
        _loadRecentSongs(),
      ]);

      totalSongs.value = results[0] as int;
      totalCategories.value = results[1] as int;
      totalTags.value = results[2] as int;
      totalUsers.value = results[3] as int;
      recentSongs.assignAll(results[4] as List<SongModel>);

      AppLogger.i('Dashboard data loaded successfully.');
    } catch (e, stackTrace) {
      AppLogger.e('Error loading dashboard data: $e', stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> _getTableCount(String table) async {
    try {
      final response = await _client.from(table).select('id');
      return response.length;
    } catch (e) {
      AppLogger.e('Failed to get count for $table: $e');
      return 0;
    }
  }

  Future<List<SongModel>> _loadRecentSongs() async {
    try {
      final List<dynamic> response = await _client
          .from(SupabaseConstants.tableSongs)
          .select('*, categories(*)')
          .order('created_at', ascending: false)
          .limit(5);

      return response.map((json) => SongModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.e('Failed to load recent songs: $e');
      return [];
    }
  }
}
