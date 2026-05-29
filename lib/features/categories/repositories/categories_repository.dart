import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/category_model.dart';

class CategoriesRepository {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  SupabaseClient get _client => _supabaseService.client;

  // Fetch all categories ordered by name
  Future<List<CategoryModel>> getCategories() async {
    try {
      if (!_supabaseService.isInitialized.value) return [];

      final List<dynamic> response = await _client
          .from(SupabaseConstants.tableCategories)
          .select()
          .order('name', ascending: true);

      return response.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch categories: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Create Category
  Future<CategoryModel> createCategory({required String name, String? image, bool status = true}) async {
    try {
      final response = await _client
          .from(SupabaseConstants.tableCategories)
          .insert({
            'name': name,
            if (image != null) 'image': image,
            'status': status,
          })
          .select()
          .single();

      AppLogger.i('Category created: $name');
      return CategoryModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create category: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update Category
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    String? image,
    required bool status,
  }) async {
    try {
      final response = await _client
          .from(SupabaseConstants.tableCategories)
          .update({
            'name': name,
            if (image != null) 'image': image,
            'status': status,
          })
          .eq('id', id)
          .select()
          .single();

      AppLogger.i('Category updated: $name');
      return CategoryModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update category: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Delete Category
  Future<void> deleteCategory(String id) async {
    try {
      await _client
          .from(SupabaseConstants.tableCategories)
          .delete()
          .eq('id', id);
      AppLogger.i('Category deleted: $id');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete category: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
