import 'package:get/get.dart';
import '../../categories/repositories/categories_repository.dart';
import '../../tags/repositories/tags_repository.dart';
import '../../raags/repositories/raags_repository.dart';
import '../controllers/songs_controller.dart';
import '../repositories/songs_repository.dart';

class SongsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SongsRepository>(() => SongsRepository());
    Get.lazyPut<CategoriesRepository>(() => CategoriesRepository());
    Get.lazyPut<TagsRepository>(() => TagsRepository());
    Get.lazyPut<RaagsRepository>(() => RaagsRepository());
    Get.lazyPut<SongsController>(() => SongsController());
  }
}
