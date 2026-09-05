import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/utils/error_handler.dart';
import '../../authentication/models/profile_model.dart';
import '../repositories/users_repository.dart';

class UsersController extends GetxController {
  final UsersRepository _usersRepository = Get.find<UsersRepository>();

  final RxList<ProfileModel> users = <ProfileModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final list = await _usersRepository.getUsers();
      users.assignAll(list);
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

  // Ban or unban user (by changing their role to 'banned' or 'user')
  Future<void> toggleUserBan(ProfileModel profile) async {
    final isBanned = profile.role == 'banned';
    final targetRole = isBanned ? 'user' : 'banned';
    final successMessage = isBanned ? 'User unbanned successfully.' : 'User banned successfully.';

    try {
      isLoading.value = true;
      final updated = await _usersRepository.updateUserRole(profile.id, targetRole);
      final index = users.indexWhere((u) => u.id == profile.id);
      if (index != -1) {
        users[index] = updated;
      }
      Get.snackbar(LocaleKeys.success.tr, successMessage,
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

  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      await _usersRepository.deleteUser(userId);
      users.removeWhere((u) => u.id == userId);
      Get.snackbar(LocaleKeys.success.tr, 'User deleted successfully.',
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
