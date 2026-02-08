import 'package:get/get.dart';
import '../controllers/user_home_controller.dart';
import '../controllers/lease/favourite_controller.dart';

class UserHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserHomeController>(
      () => UserHomeController(),
      fenix: true, // Keep the controller instance alive
    );
    Get.lazyPut<FavouriteController>(
      () => FavouriteController(),
      fenix: true, // Keep the controller instance alive for favorites
    );
  }
}
