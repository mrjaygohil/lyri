import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../../routes/app_routes.dart';
import '../models/profile_model.dart';
import '../repositories/auth_repository.dart';
import '../../../core/utils/error_handler.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final Rxn<User> rxUser = Rxn<User>();
  final Rxn<ProfileModel> rxProfile = Rxn<ProfileModel>();
  final RxBool isLoading = false.obs;
  
  StreamSubscription<AuthState>? _authSubscription;

  User? get user => rxUser.value;
  ProfileModel? get profile => rxProfile.value;
  bool get isAuthenticated => user != null && profile != null && !profile!.isBanned;

  @override
  void onInit() {
    super.onInit();
    _checkInitialSession();
    _listenToAuthChanges();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  void _checkInitialSession() async {
    if (!_supabaseService.isInitialized.value) return;

    try {
      final Session? session = _supabaseService.client.auth.currentSession;
      if (session != null && session.user != null) {
        rxUser.value = session.user;
        await _loadProfileAndNavigate(session.user!.id);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to restore session: $e', stackTrace: stackTrace);
    }
  }

  void _listenToAuthChanges() {
    if (!_supabaseService.isInitialized.value) return;

    _authSubscription = _supabaseService.client.auth.onAuthStateChange.listen((AuthState data) async {
      final Session? session = data.session;
      AppLogger.i('Auth event received: ${data.event}');

      if (session != null && session.user != null) {
        rxUser.value = session.user;
        // User logged in or session refreshed
        if (rxProfile.value == null || rxProfile.value!.id != session.user!.id) {
          await _loadProfileAndNavigate(session.user!.id);
        }
      } else {
        // User logged out
        rxUser.value = null;
        rxProfile.value = null;
        if (Get.currentRoute != AppRoutes.login) {
          Get.offAllNamed(AppRoutes.login);
        }
      }
    });
  }

  Future<void> _loadProfileAndNavigate(String userId) async {
    try {
      isLoading.value = true;
      final ProfileModel? userProfile = await _authRepository.getUserProfile(userId);
      
      if (userProfile == null) {
        throw Exception('User profile not found. Access denied.');
      }

      if (userProfile.isBanned) {
        Get.snackbar(
          LocaleKeys.errorOccurred.tr,
          'Access Denied: Your account has been suspended.',
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          colorText: Colors.white,
        );
        await signOut();
        return;
      }

      rxProfile.value = userProfile;
      isLoading.value = false;

      // Navigate based on role if currently on login or root
      if (Get.currentRoute == AppRoutes.login || Get.currentRoute == '/' || Get.currentRoute.isEmpty) {
        if (userProfile.role == 'admin') {
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          Get.offAllNamed(AppRoutes.userHome);
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed loading profile: $e', stackTrace: stackTrace);
      isLoading.value = false;
      await signOut();
    }
  }

  // Sign In Action
  Future<void> login(String email, String password) async {
    if (!_supabaseService.isInitialized.value) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        'Supabase is not configured yet. Check supabase_constants.dart',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authRepository.signIn(email, password);
      // Auth listener will handle loading profile and navigation
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Sign Up Action
  Future<void> register(String email, String password, String fullName) async {
    if (!_supabaseService.isInitialized.value) return;

    try {
      isLoading.value = true;
      await _authRepository.signUp(email, password, fullName);
      isLoading.value = false;
      
      Get.snackbar(
        LocaleKeys.success.tr,
        'Account created successfully. You can now log in.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Google Sign In Action
  Future<void> loginWithGoogle() async {
    if (!_supabaseService.isInitialized.value) return;

    try {
      isLoading.value = true;
      if (kIsWeb) {
        if (SupabaseConstants.googleWebClientId.isNotEmpty) {
          // In-page Google Sign In Popup on Web using Web Client ID
          final GoogleSignIn googleSignIn = GoogleSignIn(
            clientId: SupabaseConstants.googleWebClientId,
            scopes: ['email', 'profile'],
          );
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            isLoading.value = false;
            return;
          }
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final String? idToken = googleAuth.idToken;
          if (idToken == null) {
            throw Exception('Google sign-in succeeded but returned no identity token.');
          }
          await _authRepository.signInWithGoogle(idToken, accessToken: googleAuth.accessToken);
        } else {
          // Supabase OAuth redirect flow
          await _authRepository.signInWithGoogleOAuth();
        }
        isLoading.value = false;
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          isLoading.value = false;
          return; // User cancelled
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken == null) {
          throw Exception('Google sign-in succeeded but returned no identity token.');
        }

        await _authRepository.signInWithGoogle(idToken, accessToken: googleAuth.accessToken);
      }
    } catch (e) {
      isLoading.value = false;
      String errorMsg = ErrorHandler.formatError(e);
      if (errorMsg.contains('provider is not enabled') || e.toString().contains('provider is not enabled')) {
        errorMsg = 'Google login is not enabled in your Supabase Dashboard.\nPlease enable Google Provider under Authentication > Providers in Supabase.';
      }
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        errorMsg,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    }
  }

  // Reset password
  Future<void> sendForgotPasswordEmail(String email) async {
    try {
      isLoading.value = true;
      await _authRepository.sendPasswordReset(email);
      isLoading.value = false;
      Get.snackbar(
        LocaleKeys.success.tr,
        'Password reset link sent to your email.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  // Sign Out Action
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authRepository.signOut();
      rxUser.value = null;
      rxProfile.value = null;
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      isLoading.value = false;
      AppLogger.e('Error during logout: $e');
    }
  }
}
