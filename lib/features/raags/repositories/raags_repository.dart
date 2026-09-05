import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/raag_model.dart';

class RaagsRepository {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  SupabaseClient get _client => _supabaseService.client;

  // Fetch all raags ordered by name
  Future<List<RaagModel>> getRaags() async {
    try {
      if (!_supabaseService.isInitialized.value) return [];
      
      final List<dynamic> response = await _client
          .from(SupabaseConstants.tableRaags)
          .select()
          .order('name', ascending: true);

      return response.map((json) => RaagModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch raags: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Create Raag
  Future<RaagModel> createRaag(String name) async {
    try {
      final response = await _client
          .from(SupabaseConstants.tableRaags)
          .insert({'name': name})
          .select()
          .single();

      AppLogger.i('Raag created: $name');
      return RaagModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create raag: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update Raag
  Future<RaagModel> updateRaag(String id, String name) async {
    try {
      final response = await _client
          .from(SupabaseConstants.tableRaags)
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();

      AppLogger.i('Raag updated: $name');
      return RaagModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update raag: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Delete Raag
  Future<void> deleteRaag(String id) async {
    try {
      await _client
          .from(SupabaseConstants.tableRaags)
          .delete()
          .eq('id', id);
      AppLogger.i('Raag deleted: $id');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete raag: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
