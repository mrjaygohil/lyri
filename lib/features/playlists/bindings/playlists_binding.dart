import 'package:get/get.dart';
import '../controllers/playlists_controller.dart';

class PlaylistsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlaylistsController>(() => PlaylistsController());
  }
}
