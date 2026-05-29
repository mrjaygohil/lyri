import 'package:get/get.dart';
import '../controllers/categories_controller.dart';
import '../repositories/categories_repository.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesRepository>(() => CategoriesRepository());
    Get.lazyPut<CategoriesController>(() => CategoriesController());
  }
}
