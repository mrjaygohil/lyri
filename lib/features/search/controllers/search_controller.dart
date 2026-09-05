import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/search_helper.dart';
import '../../songs/models/song_model.dart';
import '../../tags/models/tag_model.dart';
import '../../raags/models/raag_model.dart';

class SongSearchController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  SupabaseClient get _client => _supabaseService.client;

  final RxString query = ''.obs;
  final RxList<SongModel> searchResults = <SongModel>[].obs;
  final RxList<TagModel> tags = <TagModel>[].obs;
  final RxList<RaagModel> raags = <RaagModel>[].obs;
  final RxBool isLoading = false.obs;

  final TextEditingController searchFieldController = TextEditingController();
  List<SongModel> _allSongsCache = [];
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchTags();
    fetchRaags();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchFieldController.dispose();
    super.onClose();
  }

  Future<void> fetchTags() async {
    try {
      if (!_supabaseService.isInitialized.value) return;
      final List<dynamic> response = await _client
          .from('tags')
          .select()
          .order('name', ascending: true);
      tags.assignAll(
        response.map((json) => TagModel.fromJson(json as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      AppLogger.e('Failed fetching tags: $e');
    }
  }

  Future<void> fetchRaags() async {
    try {
      if (!_supabaseService.isInitialized.value) return;
      final List<dynamic> response = await _client
          .from('raags')
          .select()
          .order('name', ascending: true);
      raags.assignAll(
        response.map((json) => RaagModel.fromJson(json as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      AppLogger.e('Failed fetching raags: $e');
    }
  }

  void selectTag(String tagName) {
    searchFieldController.text = tagName;
    onQueryChanged(tagName);
  }

  void onQueryChanged(String val) {
    query.value = val;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      searchSongs();
    });
  }

  Future<void> searchSongs() async {
    final searchVal = query.value.trim();
    if (searchVal.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      if (!_supabaseService.isInitialized.value) return;

      if (_allSongsCache.isEmpty) {
        final List<dynamic> response = await _client
            .from('songs')
            .select('*, categories(*), song_tags(tags(*)), song_raags(raags(*))')
            .eq('status', true)
            .eq('visibility', 'public')
            .eq('approval_status', 'approved');

        _allSongsCache = response
            .map((json) => SongModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Perform local fuzzy search and scoring
      final scoredResults = <MapEntry<SongModel, int>>[];
      for (final song in _allSongsCache) {
        final score = SearchHelper.calculateSongMatchScore(song, searchVal);
        if (score > 0) {
          scoredResults.add(MapEntry(song, score));
        }
      }

      // Sort by score descending, secondary order by title
      scoredResults.sort((a, b) {
        final scoreCompare = b.value.compareTo(a.value);
        if (scoreCompare != 0) return scoreCompare;
        return a.key.title.compareTo(b.key.title);
      });

      searchResults.assignAll(scoredResults.map((entry) => entry.key).toList());
    } catch (e, stackTrace) {
      AppLogger.e('Failed searching songs: $e', stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }
}
