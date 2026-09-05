import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../categories/models/category_model.dart';
import '../../songs/models/song_model.dart';

class HomeController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  SupabaseClient get _client => _supabaseService.client;

  final RxInt tabIndex = 0.obs;

  // Data reactive lists
  final RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;
  final RxList<SongModel> trendingSongs = <SongModel>[].obs;
  final RxList<SongModel> recentSongs = <SongModel>[].obs;
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  void changeTab(int index) {
    tabIndex.value = index;
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      if (!_supabaseService.isInitialized.value) return;

      // 1. Fetch featured categories (active ones, limit to 6 for the slider)
      final List<dynamic> catResponse = await _client
          .from('categories')
          .select()
          .eq('status', true)
          .order('name', ascending: true)
          .limit(6);
      
      featuredCategories.value = catResponse
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // 2. Fetch trending songs (approved public songs sorted by views_count descending)
      final List<dynamic> trendResponse = await _client
          .from('songs')
          .select('*, categories(*), song_tags(tags(*)), song_raags(raags(*))')
          .eq('status', true)
          .eq('visibility', 'public')
          .eq('approval_status', 'approved')
          .order('views_count', ascending: false)
          .limit(6);

      trendingSongs.value = trendResponse
          .map((json) => SongModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // 3. Fetch recently added songs (approved public songs sorted by created_at descending)
      final List<dynamic> recentResponse = await _client
          .from('songs')
          .select('*, categories(*), song_tags(tags(*)), song_raags(raags(*))')
          .eq('status', true)
          .eq('visibility', 'public')
          .eq('approval_status', 'approved')
          .order('created_at', ascending: false)
          .limit(6);

      recentSongs.value = recentResponse
          .map((json) => SongModel.fromJson(json as Map<String, dynamic>))
          .toList();

    } catch (e, stackTrace) {
      AppLogger.e('Failed loading user home dashboard data: $e', stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }
}
