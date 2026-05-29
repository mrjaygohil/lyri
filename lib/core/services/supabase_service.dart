import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import '../utils/logger.dart';

class SupabaseService extends GetxService {
  final RxBool isInitialized = false.obs;
  late final SupabaseClient client;

  Future<SupabaseService> init() async {
    try {
      // if (SupabaseConstants.supabaseUrl == 'https://your-project.supabase.co' ||
      //     SupabaseConstants.supabaseAnonKey == 'your-anon-key') {
      //   AppLogger.w('Supabase is not configured yet. Please configure Supabase URL and Anon Key.');
      //   return this;
      // }

      await Supabase.initialize(
        url: SupabaseConstants.supabaseUrl,
        anonKey: SupabaseConstants.supabaseAnonKey,
        debug: kDebugMode,
      );

      client = Supabase.instance.client;
      isInitialized.value = true;
      AppLogger.i('Supabase initialized successfully.');
    } catch (e, stackTrace) {
      AppLogger.e('Supabase initialization failed: $e', stackTrace: stackTrace);
      isInitialized.value = false;
    }
    return this;
  }

  // Upload an image file (as bytes) to Supabase Storage bucket
  Future<String?> uploadImage({
    required String path,
    required Uint8List fileBytes,
    required String mimeType,
  }) async {
    if (!isInitialized.value) {
      AppLogger.w('Cannot upload: Supabase not initialized.');
      return null;
    }

    try {
      final String cleanPath = path.replaceAll(RegExp(r'[^\w\.\-\/]'), '_');
      AppLogger.i('Uploading file to ${SupabaseConstants.bucketThumbnails}/$cleanPath');

      await client.storage
          .from(SupabaseConstants.bucketThumbnails)
          .uploadBinary(
            cleanPath,
            fileBytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      // Get public URL
      final String publicUrl = client.storage
          .from(SupabaseConstants.bucketThumbnails)
          .getPublicUrl(cleanPath);

      AppLogger.i('Upload successful! Public URL: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      AppLogger.e('File upload failed: $e', stackTrace: stackTrace);
      return null;
    }
  }
}
