import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/authentication/bindings/auth_binding.dart';
import '../features/authentication/controllers/auth_controller.dart';
import '../features/authentication/views/login_view.dart';
import '../features/dashboard/bindings/dashboard_binding.dart';
import '../features/dashboard/views/dashboard_view.dart';
import '../features/categories/bindings/categories_binding.dart';
import '../features/categories/views/categories_view.dart';
import '../features/categories/views/category_songs_view.dart';
import '../features/tags/bindings/tags_binding.dart';
import '../features/tags/views/tags_view.dart';
import '../features/raags/bindings/raags_binding.dart';
import '../features/raags/views/raags_view.dart';
import '../features/songs/bindings/songs_binding.dart';
import '../features/songs/views/songs_list_view.dart';
import '../features/songs/views/song_editor_view.dart';
import '../features/songs/views/song_detail_view.dart';
import '../features/songs/views/song_approvals_view.dart';
import '../features/users/bindings/users_binding.dart';
import '../features/users/views/users_view.dart';
import '../features/home/bindings/home_binding.dart';
import '../features/home/views/home_layout_view.dart';
import '../features/playlists/bindings/playlists_binding.dart';
import '../features/playlists/views/playlist_detail_view.dart';
import '../features/playlists/views/playlist_lyrics_view.dart';
import '../features/search/bindings/search_binding.dart';
import '../features/search/views/search_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String songs = '/songs';
  static const String categories = '/categories';
  static const String tags = '/tags';
  static const String raags = '/raags';
  static const String users = '/users';
  static const String songEditor = '/song-editor';
  static const String songApprovals = '/song-approvals';
  
  // Mobile routes
  static const String userHome = '/user-home';
  static const String songDetail = '/song-detail';
  static const String categorySongs = '/category-songs';
  static const String playlistDetail = '/playlist-detail';
  static const String playlistLyrics = '/playlist-lyrics';
  static const String search = '/search';

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
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: songs,
      page: () => const SongsListView(),
      binding: SongsBinding(),
      transition: Transition.noTransition,
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: songApprovals,
      page: () => const SongApprovalsView(),
      binding: SongsBinding(),
      transition: Transition.noTransition,
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
      transition: Transition.noTransition,
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: tags,
      page: () => const TagsView(),
      binding: TagsBinding(),
      transition: Transition.noTransition,
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: raags,
      page: () => const RaagsView(),
      binding: RaagsBinding(),
      transition: Transition.noTransition,
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: users,
      page: () => const UsersView(),
      binding: UsersBinding(),
      transition: Transition.noTransition,
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: songEditor,
      page: () => const SongEditorView(),
      binding: SongsBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    
    // User Mobile Pages
    GetPage(
      name: userHome,
      page: () => const HomeLayoutView(),
      binding: HomeBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: songDetail,
      page: () => const SongDetailView(),
      binding: SongsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: categorySongs,
      page: () => const CategorySongsView(),
      binding: SongsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: playlistDetail,
      page: () => const PlaylistDetailView(),
      binding: PlaylistsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: playlistLyrics,
      page: () => const PlaylistLyricsView(),
      binding: PlaylistsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: search,
      page: () => const SearchView(),
      binding: SearchBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthController authController = Get.find<AuthController>();
    
    if (!authController.isAuthenticated) {
      // User is not logged in
      return const RouteSettings(name: AppRoutes.login);
    }
    
    // Allow access
    return null;
  }
}

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthController authController = Get.find<AuthController>();
    
    if (!authController.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }
    
    if (authController.profile?.role != 'admin') {
      // User is not an admin, deny access and send to user home
      return const RouteSettings(name: AppRoutes.userHome);
    }
    
    return null;
  }
}
