import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/song_model.dart';

class SongsRepository {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  SupabaseClient get _client => _supabaseService.client;

  // Fetch songs with filtering and relations
  Future<List<SongModel>> getSongs({
    String? searchQuery,
    String? categoryId,
    bool? statusFilter,
  }) async {
    try {
      if (!_supabaseService.isInitialized.value) return [];

      var query = _client
          .from(SupabaseConstants.tableSongs)
          .select('*, categories(*), song_tags(tags(*)), song_raags(raags(*))');

      // Filter by category
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      // Filter by status
      if (statusFilter != null) {
        query = query.eq('status', statusFilter);
      }

      // Filter by search query (title or singer)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,singer_name.ilike.%$searchQuery%');
      }

      final List<dynamic> response = await query.order('created_at', ascending: false);
      return response.map((json) => SongModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch songs: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Create Song and insert tag relationships
  Future<SongModel> createSong(Map<String, dynamic> songData, List<String> tagIds, List<String> raagIds) async {
    try {
      // 1. Insert song record
      final songResponse = await _client
          .from(SupabaseConstants.tableSongs)
          .insert(songData)
          .select()
          .single();
      
      final String songId = songResponse['id'] as String;

      // 2. Insert song-tag junctions
      if (tagIds.isNotEmpty) {
        final List<Map<String, dynamic>> junctionRows = tagIds
            .map((tagId) => {'song_id': songId, 'tag_id': tagId})
            .toList();

        await _client.from(SupabaseConstants.tableSongTags).insert(junctionRows);
      }

      // 2.5. Insert song-raag junctions
      if (raagIds.isNotEmpty) {
        final List<Map<String, dynamic>> junctionRows = raagIds
            .map((raagId) => {'song_id': songId, 'raag_id': raagId})
            .toList();

        await _client.from(SupabaseConstants.tableSongRaags).insert(junctionRows);
      }

      // 3. Fetch full song with relations
      final fullResponse = await _client
          .from(SupabaseConstants.tableSongs)
          .select('*, categories(*), song_tags(tags(*)), song_raags(raags(*))')
          .eq('id', songId)
          .single();

      AppLogger.i('Song created: ${fullResponse['title']}');
      return SongModel.fromJson(fullResponse);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create song: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update Song and sync tag relationships
  Future<SongModel> updateSong(String songId, Map<String, dynamic> songData, List<String> tagIds, List<String> raagIds) async {
    try {
      // 1. Update song record
      await _client
          .from(SupabaseConstants.tableSongs)
          .update(songData)
          .eq('id', songId);

      // 2. Clear old junction tags
      await _client
          .from(SupabaseConstants.tableSongTags)
          .delete()
          .eq('song_id', songId);

      // 2.5 Clear old junction raags
      await _client
          .from(SupabaseConstants.tableSongRaags)
          .delete()
          .eq('song_id', songId);

      // 3. Insert new junction tags
      if (tagIds.isNotEmpty) {
        final List<Map<String, dynamic>> junctionRows = tagIds
            .map((tagId) => {'song_id': songId, 'tag_id': tagId})
            .toList();

        await _client.from(SupabaseConstants.tableSongTags).insert(junctionRows);
      }

      // 3.5 Insert new junction raags
      if (raagIds.isNotEmpty) {
        final List<Map<String, dynamic>> junctionRows = raagIds
            .map((raagId) => {'song_id': songId, 'raag_id': raagId})
            .toList();

        await _client.from(SupabaseConstants.tableSongRaags).insert(junctionRows);
      }

      // 4. Fetch full song with relations
      final fullResponse = await _client
          .from(SupabaseConstants.tableSongs)
          .select('*, categories(*), song_tags(tags(*)), song_raags(raags(*))')
          .eq('id', songId)
          .single();

      AppLogger.i('Song updated: ${fullResponse['title']}');
      return SongModel.fromJson(fullResponse);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update song: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update Song Approval Status (Approve or Decline)
  Future<SongModel> updateSongApprovalStatus(String songId, String status, String adminUserId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.tableSongs)
          .update({
            'approval_status': status,
            'approved_by': adminUserId,
          })
          .eq('id', songId)
          .select('*, categories(*), song_tags(tags(*)), song_raags(raags(*))')
          .single();

      AppLogger.i('Song approval status updated to $status: $songId');
      return SongModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update song approval status: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Delete Song
  Future<void> deleteSong(String songId) async {
    try {
      await _client
          .from(SupabaseConstants.tableSongs)
          .delete()
          .eq('id', songId);
      AppLogger.i('Song deleted: $songId');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete song: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Bulk Create Songs
  Future<int> bulkCreateSongs(List<Map<String, dynamic>> songsData) async {
    try {
      if (songsData.isEmpty) return 0;
      await _client
          .from(SupabaseConstants.tableSongs)
          .insert(songsData);
      AppLogger.i('Successfully bulk created ${songsData.length} songs');
      return songsData.length;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to bulk create songs: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}

