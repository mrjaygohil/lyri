import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../authentication/models/profile_model.dart';

class UsersRepository {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  SupabaseClient get _client => _supabaseService.client;

  // Fetch all user profiles ordered by created_at descending
  Future<List<ProfileModel>> getUsers() async {
    try {
      if (!_supabaseService.isInitialized.value) return [];

      final List<dynamic> response = await _client
          .from(SupabaseConstants.tableProfiles)
          .select()
          .order('created_at', ascending: false);

      return response.map((json) => ProfileModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch user profiles: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update user role (e.g. set to 'banned' or 'admin' or 'user')
  Future<ProfileModel> updateUserRole(String userId, String role) async {
    try {
      final response = await _client
          .from(SupabaseConstants.tableProfiles)
          .update({'role': role})
          .eq('id', userId)
          .select()
          .single();

      AppLogger.i('User role updated: User ID $userId to role $role');
      return ProfileModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update user role: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Delete user profile
  Future<void> deleteUser(String userId) async {
    try {
      await _client
          .from(SupabaseConstants.tableProfiles)
          .delete()
          .eq('id', userId);
      AppLogger.i('User profile deleted: $userId');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete user profile: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
