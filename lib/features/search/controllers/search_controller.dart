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
  final RxSet<String> selectedTags = <String>{}.obs;
  final RxSet<String> selectedRaags = <String>{}.obs;

  final RxList<SongModel> displayedSongs = <SongModel>[].obs;
  final RxList<TagModel> tags = <TagModel>[].obs;
  final RxList<RaagModel> raags = <RaagModel>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  final int pageSize = 20;
  int _currentPage = 1;

  final TextEditingController searchFieldController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<SongModel> _allSongsCache = [];
  List<SongModel> _filteredSongs = [];
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchTags();
    fetchRaags();
    searchSongs(); // Load initial songs
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _debounceTimer?.cancel();
    searchFieldController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadNextPage();
    }
  }

  int get totalSongsCount => _filteredSongs.length;

  bool get hasActiveFilters =>
      query.value.trim().isNotEmpty || selectedTags.isNotEmpty || selectedRaags.isNotEmpty;

  void toggleTag(String tagName) {
    if (selectedTags.contains(tagName)) {
      selectedTags.remove(tagName);
    } else {
      selectedTags.add(tagName);
    }
    searchSongs();
  }

  void toggleRaag(String raagName) {
    if (selectedRaags.contains(raagName)) {
      selectedRaags.remove(raagName);
    } else {
      selectedRaags.add(raagName);
    }
    searchSongs();
  }

  void clearAllFilters() {
    selectedTags.clear();
    selectedRaags.clear();
    searchFieldController.clear();
    query.value = '';
    searchSongs();
  }

  void clearSearchText() {
    searchFieldController.clear();
    onQueryChanged('');
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

  void onQueryChanged(String val) {
    query.value = val;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      searchSongs();
    });
  }

  Future<void> searchSongs() async {
    try {
      isLoading.value = true;
      if (!_supabaseService.isInitialized.value) return;

      if (_allSongsCache.isEmpty) {
        final List<dynamic> response = await _client
            .from('songs')
            .select('*, categories(*), song_tags(tags(*)), song_raags(raags(*))')
            .eq('status', true)
            .eq('visibility', 'public')
            .eq('approval_status', 'approved')
            .order('title', ascending: true);

        _allSongsCache = response
            .map((json) => SongModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      final searchVal = query.value.trim();
      final isFiltering = searchVal.isNotEmpty || selectedTags.isNotEmpty || selectedRaags.isNotEmpty;

      if (!isFiltering) {
        _filteredSongs = List.from(_allSongsCache);
      } else {
        final scoredResults = <MapEntry<SongModel, int>>[];

        for (final song in _allSongsCache) {
          // 1. Text Query Filter
          int score = 1;
          if (searchVal.isNotEmpty) {
            score = SearchHelper.calculateSongMatchScore(song, searchVal);
            if (score <= 0) continue;
          }

          // 2. Tags Filter (Song must match selected tags)
          if (selectedTags.isNotEmpty) {
            final songTagNames = song.tags?.map((t) => t.name.toLowerCase()).toSet() ?? {};
            final matchesTag = selectedTags.any((st) => songTagNames.contains(st.toLowerCase()));
            if (!matchesTag) continue;
          }

          // 3. Raags Filter (Song must match selected raags)
          if (selectedRaags.isNotEmpty) {
            final songRaagNames = song.raags?.map((r) => r.name.toLowerCase()).toSet() ?? {};
            final matchesRaag = selectedRaags.any((sr) => songRaagNames.contains(sr.toLowerCase()));
            if (!matchesRaag) continue;
          }

          scoredResults.add(MapEntry(song, score));
        }

        // Sort by text match score if text query is active, otherwise sort by title
        if (searchVal.isNotEmpty) {
          scoredResults.sort((a, b) {
            final scoreCompare = b.value.compareTo(a.value);
            if (scoreCompare != 0) return scoreCompare;
            return a.key.title.compareTo(b.key.title);
          });
        }

        _filteredSongs = scoredResults.map((entry) => entry.key).toList();
      }

      // Reset pagination for infinite scroll
      _currentPage = 1;
      final initialBatch = _filteredSongs.take(pageSize).toList();
      displayedSongs.assignAll(initialBatch);
      hasMore.value = displayedSongs.length < _filteredSongs.length;
    } catch (e, stackTrace) {
      AppLogger.e('Failed searching songs: $e', stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  void loadNextPage() {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    final startIndex = _currentPage * pageSize;
    if (startIndex < _filteredSongs.length) {
      final nextEndIndex = (startIndex + pageSize).clamp(0, _filteredSongs.length);
      final nextBatch = _filteredSongs.sublist(startIndex, nextEndIndex);
      displayedSongs.addAll(nextBatch);
      _currentPage++;
      hasMore.value = displayedSongs.length < _filteredSongs.length;
    } else {
      hasMore.value = false;
    }
    isLoadingMore.value = false;
  }

  Future<void> refreshSongs() async {
    _allSongsCache.clear();
    await searchSongs();
  }
}
