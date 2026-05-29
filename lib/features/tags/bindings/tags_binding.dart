import 'package:get/get.dart';
import '../controllers/tags_controller.dart';
import '../repositories/tags_repository.dart';

class TagsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TagsRepository>(() => TagsRepository());
    Get.lazyPut<TagsController>(() => TagsController());
  }
}
