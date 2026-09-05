import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../categories/repositories/categories_repository.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../songs/repositories/songs_repository.dart';
import '../../songs/controllers/songs_controller.dart';
import '../../tags/repositories/tags_repository.dart';
import '../../raags/repositories/raags_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CategoriesRepository>(() => CategoriesRepository());
    Get.lazyPut<CategoriesController>(() => CategoriesController());
    Get.lazyPut<SongsRepository>(() => SongsRepository());
    Get.lazyPut<TagsRepository>(() => TagsRepository());
    Get.lazyPut<RaagsRepository>(() => RaagsRepository());
    Get.lazyPut<SongsController>(() => SongsController());
  }
}
