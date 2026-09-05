import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/utils/error_handler.dart';
import '../models/tag_model.dart';
import '../repositories/tags_repository.dart';

import '../../../core/utils/supabase_seeder.dart';

class TagsController extends GetxController {
  final TagsRepository _tagsRepository = Get.find<TagsRepository>();

  final RxList<TagModel> tags = <TagModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTags();
  }

  Future<void> seedInitialTags() async {
    try {
      isLoading.value = true;
      final count = await SupabaseSeeder.seedTags();
      await loadTags();
      Get.snackbar(
        LocaleKeys.success.tr,
        'Seeded $count tags successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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


  Future<void> loadTags() async {
    try {
      isLoading.value = true;
      final list = await _tagsRepository.getTags();
      tags.assignAll(list);
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

  Future<void> addTag(String name) async {
    if (name.trim().isEmpty) return;
    
    final nameTrimmed = name.trim();
    final exists = tags.any((tag) => tag.name.trim().toLowerCase() == nameTrimmed.toLowerCase());
    if (exists) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        'Tag with this name already exists.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final newTag = await _tagsRepository.createTag(nameTrimmed);
      tags.add(newTag);
      tags.sort((a, b) => a.name.compareTo(b.name));
      Get.back(); // close dialog
      Get.snackbar(LocaleKeys.success.tr, 'Tag added successfully.',
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

  Future<void> editTag(String id, String name) async {
    if (name.trim().isEmpty) return;
    
    final nameTrimmed = name.trim();
    final exists = tags.any((tag) => tag.id != id && tag.name.trim().toLowerCase() == nameTrimmed.toLowerCase());
    if (exists) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        'Tag with this name already exists.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final updated = await _tagsRepository.updateTag(id, nameTrimmed);
      final index = tags.indexWhere((t) => t.id == id);
      if (index != -1) {
        tags[index] = updated;
        tags.sort((a, b) => a.name.compareTo(b.name));
      }
      Get.back(); // close dialog
      Get.snackbar(LocaleKeys.success.tr, 'Tag updated successfully.',
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

  Future<void> deleteTag(String id) async {
    try {
      isLoading.value = true;
      await _tagsRepository.deleteTag(id);
      tags.removeWhere((t) => t.id == id);
      Get.snackbar(LocaleKeys.success.tr, 'Tag deleted successfully.',
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
