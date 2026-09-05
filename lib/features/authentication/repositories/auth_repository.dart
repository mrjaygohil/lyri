import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/profile_model.dart';
import 'package:get/get.dart';

class AuthRepository {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  SupabaseClient get _client => _supabaseService.client;

  // Sign in with email & password
  Future<User?> signIn(String email, String password) async {
    try {
      if (!_supabaseService.isInitialized.value) {
        throw Exception('Supabase is not initialized. Please verify credentials in supabase_constants.dart');
      }

      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      AppLogger.i('Authentication successful for: $email');
      return response.user;
    } catch (e, stackTrace) {
      AppLogger.e('Sign-in failed: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get current user profile and check admin role
  Future<ProfileModel?> getUserProfile(String userId) async {
    try {
      if (!_supabaseService.isInitialized.value) return null;

      final dynamic response = await _client
          .from(SupabaseConstants.tableProfiles)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        AppLogger.w('No profile found for user $userId');
        return null;
      }

      final ProfileModel profile = ProfileModel.fromJson(response as Map<String, dynamic>);
      AppLogger.i('Profile loaded: ${profile.email} (Role: ${profile.role})');
      return profile;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to load profile: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (!_supabaseService.isInitialized.value) return;
      await _client.auth.signOut();
      AppLogger.i('User signed out successfully.');
    } catch (e, stackTrace) {
      AppLogger.e('Sign-out failed: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Reset Password
  Future<void> sendPasswordReset(String email) async {
    try {
      if (!_supabaseService.isInitialized.value) {
        throw Exception('Supabase not initialized');
      }
      await _client.auth.resetPasswordForEmail(email);
      AppLogger.i('Password reset email sent to: $email');
    } catch (e, stackTrace) {
      AppLogger.e('Password reset request failed: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign up with email & password
  Future<User?> signUp(String email, String password, String fullName) async {
    try {
      if (!_supabaseService.isInitialized.value) {
        throw Exception('Supabase not initialized');
      }
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'user'},
      );
      AppLogger.i('Sign-up successful for: $email');
      return response.user;
    } catch (e, stackTrace) {
      AppLogger.e('Sign-up failed: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign in with Google OAuth (used on Web)
  Future<bool> signInWithGoogleOAuth() async {
    try {
      if (!_supabaseService.isInitialized.value) {
        throw Exception('Supabase not initialized');
      }
      final bool res = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.toString() : null,
      );
      AppLogger.i('Google OAuth flow launched successfully.');
      return res;
    } catch (e, stackTrace) {
      AppLogger.e('Google OAuth sign-in failed: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign in with Google IdToken (used on Mobile)
  Future<User?> signInWithGoogle(String idToken, {String? accessToken}) async {
    try {
      if (!_supabaseService.isInitialized.value) {
        throw Exception('Supabase not initialized');
      }
      final AuthResponse response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      AppLogger.i('Google sign-in successful.');
      return response.user;
    } catch (e, stackTrace) {
      AppLogger.e('Google sign-in failed: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}

