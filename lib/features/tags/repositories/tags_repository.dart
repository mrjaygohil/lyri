import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/tag_model.dart';

class TagsRepository {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  SupabaseClient get _client => _supabaseService.client;

  // Fetch all tags ordered by name
  Future<List<TagModel>> getTags() async {
    try {
      if (!_supabaseService.isInitialized.value) return [];
      
      final List<dynamic> response = await _client
          .from(SupabaseConstants.tableTags)
          .select()
          .order('name', ascending: true);

      return response.map((json) => TagModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch tags: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Create Tag
  Future<TagModel> createTag(String name) async {
    try {
      final response = await _client
          .from(SupabaseConstants.tableTags)
          .insert({'name': name})
          .select()
          .single();

      AppLogger.i('Tag created: $name');
      return TagModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create tag: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update Tag
  Future<TagModel> updateTag(String id, String name) async {
    try {
      final response = await _client
          .from(SupabaseConstants.tableTags)
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();

      AppLogger.i('Tag updated: $name');
      return TagModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update tag: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Delete Tag
  Future<void> deleteTag(String id) async {
    try {
      await _client
          .from(SupabaseConstants.tableTags)
          .delete()
          .eq('id', id);
      AppLogger.i('Tag deleted: $id');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete tag: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
