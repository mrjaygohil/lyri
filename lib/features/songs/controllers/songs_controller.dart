import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../categories/models/category_model.dart';
import '../../categories/repositories/categories_repository.dart';
import '../../tags/models/tag_model.dart';
import '../../tags/repositories/tags_repository.dart';
import '../models/song_model.dart';
import '../repositories/songs_repository.dart';

class SongsController extends GetxController {
  final SongsRepository _songsRepository = Get.find<SongsRepository>();
  final CategoriesRepository _categoriesRepository = Get.find<CategoriesRepository>();
  final TagsRepository _tagsRepository = Get.find<TagsRepository>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxList<SongModel> songs = <SongModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<TagModel> tags = <TagModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  // Search & Filter State
  final RxString searchQuery = ''.obs;
  final RxnString selectedCategoryFilter = RxnString();
  final RxnBool selectedStatusFilter = RxnBool();

  // Song Image Selection
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxString selectedImageName = ''.obs;
  final RxString selectedMimeType = 'image/jpeg'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDependencies();
    loadSongs();
    
    // Debounce search query by 500ms
    debounce(searchQuery, (_) => loadSongs(), time: const Duration(milliseconds: 500));
  }

  Future<void> loadDependencies() async {
    try {
      final results = await Future.wait([
        _categoriesRepository.getCategories(),
        _tagsRepository.getTags(),
      ]);
      
      // Filter out inactive categories for selection, but keep all for safety
      categories.assignAll(results[0] as List<CategoryModel>);
      tags.assignAll(results[1] as List<TagModel>);
    } catch (e) {
      AppLogger.e('Failed to load dependencies for SongsController: $e');
    }
  }

  Future<void> loadSongs() async {
    try {
      isLoading.value = true;
      final list = await _songsRepository.getSongs(
        searchQuery: searchQuery.value,
        categoryId: selectedCategoryFilter.value,
        statusFilter: selectedStatusFilter.value,
      );
      songs.assignAll(list);
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pick song image
  Future<void> pickSongImage() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        selectedImageBytes.value = result.files.first.bytes;
        selectedImageName.value = result.files.first.name;
        
        final ext = result.files.first.extension?.toLowerCase() ?? 'jpg';
        selectedMimeType.value = ext == 'png' ? 'image/png' : 'image/jpeg';
        
        AppLogger.i('Song image picked: ${selectedImageName.value}');
      }
    } catch (e) {
      AppLogger.e('Failed to pick song image: $e');
    }
  }

  void clearSelectedImage() {
    selectedImageBytes.value = null;
    selectedImageName.value = '';
  }

  Future<void> deleteSong(String songId) async {
    try {
      isLoading.value = true;
      await _songsRepository.deleteSong(songId);
      songs.removeWhere((s) => s.id == songId);
      Get.snackbar(LocaleKeys.success.tr, 'Song deleted successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create Song Action
  Future<void> saveSong({
    required String title,
    required String lyrics,
    String? singerName,
    String? albumName,
    String? language,
    String? categoryId,
    required List<String> tagIds,
    required bool status,
    SongModel? existingSong,
  }) async {
    if (title.trim().isEmpty || lyrics.trim().isEmpty) {
      Get.snackbar(LocaleKeys.errorOccurred.tr, 'Title and lyrics are required.',
          backgroundColor: Colors.amber.shade900, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final isEdit = existingSong != null;

      String? imageUrl = isEdit ? existingSong.thumbnail : null;
      if (selectedImageBytes.value != null) {
        isUploading.value = true;
        final String path = 'songs/${DateTime.now().millisecondsSinceEpoch}_${selectedImageName.value}';
        imageUrl = await _supabaseService.uploadImage(
          path: path,
          fileBytes: selectedImageBytes.value!,
          mimeType: selectedMimeType.value,
        );
        isUploading.value = false;
      }

      final Map<String, dynamic> songData = {
        'title': title.trim(),
        'lyrics': lyrics.trim(),
        'singer_name': singerName?.trim(),
        'album_name': albumName?.trim(),
        'language': language?.trim(),
        'category_id': categoryId,
        'thumbnail': imageUrl,
        'status': status,
      };

      if (isEdit) {
        final updated = await _songsRepository.updateSong(existingSong.id, songData, tagIds);
        final index = songs.indexWhere((s) => s.id == existingSong.id);
        if (index != -1) {
          songs[index] = updated;
        }
        Get.back(); // return to list view
        Get.snackbar(LocaleKeys.success.tr, 'Song updated successfully.',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final newSong = await _songsRepository.createSong(songData, tagIds);
        songs.insert(0, newSong);
        Get.back(); // return to list view
        Get.snackbar(LocaleKeys.success.tr, 'Song added successfully.',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
      clearSelectedImage();
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  // Filter setters
  void setCategoryFilter(String? catId) {
    selectedCategoryFilter.value = catId;
    loadSongs();
  }

  void setStatusFilter(bool? status) {
    selectedStatusFilter.value = status;
    loadSongs();
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedCategoryFilter.value = null;
    selectedStatusFilter.value = null;
    loadSongs();
  }
}
