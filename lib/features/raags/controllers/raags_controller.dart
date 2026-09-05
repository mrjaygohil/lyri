import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/utils/error_handler.dart';
import '../models/raag_model.dart';
import '../repositories/raags_repository.dart';

import '../../../core/utils/supabase_seeder.dart';

class RaagsController extends GetxController {
  final RaagsRepository _raagsRepository = Get.find<RaagsRepository>();

  final RxList<RaagModel> raags = <RaagModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRaags();
  }

  Future<void> seedInitialRaags() async {
    try {
      isLoading.value = true;
      final count = await SupabaseSeeder.seedRaags();
      await loadRaags();
      Get.snackbar(
        LocaleKeys.success.tr,
        'Seeded $count raags successfully.',
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


  Future<void> loadRaags() async {
    try {
      isLoading.value = true;
      final list = await _raagsRepository.getRaags();
      raags.assignAll(list);
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

  Future<void> addRaag(String name) async {
    if (name.trim().isEmpty) return;
    
    final nameTrimmed = name.trim();
    final exists = raags.any((r) => r.name.trim().toLowerCase() == nameTrimmed.toLowerCase());
    if (exists) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        'Raag with this name already exists.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final newRaag = await _raagsRepository.createRaag(nameTrimmed);
      raags.add(newRaag);
      raags.sort((a, b) => a.name.compareTo(b.name));
      Get.back(); // close dialog
      Get.snackbar(LocaleKeys.success.tr, 'Raag added successfully.',
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

  Future<void> editRaag(String id, String name) async {
    if (name.trim().isEmpty) return;
    
    final nameTrimmed = name.trim();
    final exists = raags.any((r) => r.id != id && r.name.trim().toLowerCase() == nameTrimmed.toLowerCase());
    if (exists) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        'Raag with this name already exists.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final updated = await _raagsRepository.updateRaag(id, nameTrimmed);
      final index = raags.indexWhere((r) => r.id == id);
      if (index != -1) {
        raags[index] = updated;
        raags.sort((a, b) => a.name.compareTo(b.name));
      }
      Get.back(); // close dialog
      Get.snackbar(LocaleKeys.success.tr, 'Raag updated successfully.',
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

  Future<void> deleteRaag(String id) async {
    try {
      isLoading.value = true;
      await _raagsRepository.deleteRaag(id);
      raags.removeWhere((r) => r.id == id);
      Get.snackbar(LocaleKeys.success.tr, 'Raag deleted successfully.',
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
