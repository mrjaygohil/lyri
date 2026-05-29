import 'package:get/get.dart';
import '../controllers/users_controller.dart';
import '../repositories/users_repository.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsersRepository>(() => UsersRepository());
    Get.lazyPut<UsersController>(() => UsersController());
  }
}
