import 'package:get/get.dart';
import '../controllers/raags_controller.dart';
import '../repositories/raags_repository.dart';

class RaagsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaagsRepository>(() => RaagsRepository());
    Get.lazyPut<RaagsController>(() => RaagsController());
  }
}
