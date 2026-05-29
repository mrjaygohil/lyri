import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/authentication/bindings/auth_binding.dart';
import '../features/authentication/controllers/auth_controller.dart';
import '../features/authentication/views/login_view.dart';
import '../features/dashboard/bindings/dashboard_binding.dart';
import '../features/dashboard/views/dashboard_view.dart';
import '../features/categories/bindings/categories_binding.dart';
import '../features/categories/views/categories_view.dart';
import '../features/tags/bindings/tags_binding.dart';
import '../features/tags/views/tags_view.dart';
import '../features/songs/bindings/songs_binding.dart';
import '../features/songs/views/songs_list_view.dart';
import '../features/songs/views/song_editor_view.dart';
import '../features/users/bindings/users_binding.dart';
import '../features/users/views/users_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String songs = '/songs';
  static const String categories = '/categories';
  static const String tags = '/tags';
  static const String users = '/users';
  static const String songEditor = '/song-editor';

  static final List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: songs,
      page: () => const SongsListView(),
      binding: SongsBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: tags,
      page: () => const TagsView(),
      binding: TagsBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: users,
      page: () => const UsersView(),
      binding: UsersBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: songEditor,
      page: () => const SongEditorView(),
      binding: SongsBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthController authController = Get.find<AuthController>();
    
    if (!authController.isAuthenticated) {
      // User is not logged in or is not an admin
      return const RouteSettings(name: AppRoutes.login);
    }
    
    // Allow access
    return null;
  }
}
