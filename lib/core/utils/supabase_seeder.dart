import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../constants/supabase_constants.dart';
import '../services/supabase_service.dart';
import 'logger.dart';

class SupabaseSeeder {
  static final SupabaseService _supabaseService = Get.find<SupabaseService>();

  /// Seed Raags into Supabase `raags` table from `assets/seeder/raags.json`
  static Future<int> seedRaags() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/seeder/raags.json');
      final List<dynamic> raagsList = jsonDecode(jsonString) as List<dynamic>;

      final List<Map<String, String>> dataToInsert = raagsList
          .map((item) => {'name': item.toString().trim()})
          .where((item) => item['name']!.isNotEmpty)
          .toList();

      if (dataToInsert.isEmpty) return 0;

      final client = _supabaseService.client;
      await client
          .from(SupabaseConstants.tableRaags)
          .upsert(dataToInsert, onConflict: 'name');

      AppLogger.i('Successfully seeded ${dataToInsert.length} raags into Supabase.');
      return dataToInsert.length;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to seed raags: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Seed Tags into Supabase `tags` table from `assets/seeder/tags.json`
  static Future<int> seedTags() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/seeder/tags.json');
      final List<dynamic> tagsList = jsonDecode(jsonString) as List<dynamic>;

      final List<Map<String, String>> dataToInsert = tagsList
          .map((item) => {'name': item.toString().trim()})
          .where((item) => item['name']!.isNotEmpty)
          .toList();

      if (dataToInsert.isEmpty) return 0;

      final client = _supabaseService.client;
      await client
          .from(SupabaseConstants.tableTags)
          .upsert(dataToInsert, onConflict: 'name');

      AppLogger.i('Successfully seeded ${dataToInsert.length} tags into Supabase.');
      return dataToInsert.length;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to seed tags: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Seed both Raags and Tags in a single operation
  static Future<Map<String, int>> seedAll() async {
    final raagsCount = await seedRaags();
    final tagsCount = await seedTags();
    return {
      'raags': raagsCount,
      'tags': tagsCount,
    };
  }
}
