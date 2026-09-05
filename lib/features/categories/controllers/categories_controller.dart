import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/error_handler.dart';
import '../models/category_model.dart';
import '../repositories/categories_repository.dart';

class CategoriesController extends GetxController {
  final CategoriesRepository _categoriesRepository = Get.find<CategoriesRepository>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  // Selected file details for upload
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxString selectedImageName = ''.obs;
  final RxString selectedMimeType = 'image/jpeg'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final list = await _categoriesRepository.getCategories();
      categories.assignAll(list);
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pick category image from local file system on web
  Future<void> pickCategoryImage() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        selectedImageBytes.value = result.files.first.bytes;
        selectedImageName.value = result.files.first.name;
        // Basic MIME type extraction
        final ext = result.files.first.extension?.toLowerCase() ?? 'jpg';
        selectedMimeType.value = ext == 'png' ? 'image/png' : 'image/jpeg';
        
        AppLogger.i('Image picked: ${selectedImageName.value} (${selectedImageBytes.value!.length} bytes)');
      }
    } catch (e) {
      AppLogger.e('Failed to pick image: $e');
    }
  }

  void clearSelectedImage() {
    selectedImageBytes.value = null;
    selectedImageName.value = '';
  }

  Future<void> addCategory(String name, bool status) async {
    if (name.trim().isEmpty) return;
    
    final nameTrimmed = name.trim();
    final exists = categories.any((cat) => cat.name.trim().toLowerCase() == nameTrimmed.toLowerCase());
    if (exists) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        'Category with this name already exists.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      String? imageUrl;
      if (selectedImageBytes.value != null) {
        isUploading.value = true;
        final String path = 'categories/${DateTime.now().millisecondsSinceEpoch}_${selectedImageName.value}';
        imageUrl = await _supabaseService.uploadImage(
          path: path,
          fileBytes: selectedImageBytes.value!,
          mimeType: selectedMimeType.value,
        );
        isUploading.value = false;
      }

      final newCat = await _categoriesRepository.createCategory(
        name: name.trim(),
        image: imageUrl,
        status: status,
      );
      
      categories.add(newCat);
      categories.sort((a, b) => a.name.compareTo(b.name));
      clearSelectedImage();
      Get.back(); // close dialog
      Get.snackbar(LocaleKeys.success.tr, 'Category added successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  Future<void> editCategory({
    required String id,
    required String name,
    required bool status,
    String? existingImageUrl,
  }) async {
    if (name.trim().isEmpty) return;

    final nameTrimmed = name.trim();
    final exists = categories.any((cat) => cat.id != id && cat.name.trim().toLowerCase() == nameTrimmed.toLowerCase());
    if (exists) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        'Category with this name already exists.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      String? imageUrl = existingImageUrl;
      if (selectedImageBytes.value != null) {
        isUploading.value = true;
        final String path = 'categories/${DateTime.now().millisecondsSinceEpoch}_${selectedImageName.value}';
        imageUrl = await _supabaseService.uploadImage(
          path: path,
          fileBytes: selectedImageBytes.value!,
          mimeType: selectedMimeType.value,
        );
        isUploading.value = false;
      }

      final updated = await _categoriesRepository.updateCategory(
        id: id,
        name: name.trim(),
        image: imageUrl,
        status: status,
      );

      final index = categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        categories[index] = updated;
        categories.sort((a, b) => a.name.compareTo(b.name));
      }
      clearSelectedImage();
      Get.back(); // close dialog
      Get.snackbar(LocaleKeys.success.tr, 'Category updated successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      await _categoriesRepository.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      Get.snackbar(LocaleKeys.success.tr, 'Category deleted successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
