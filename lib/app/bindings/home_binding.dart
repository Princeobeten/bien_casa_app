import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // Inject HomeController when this binding is called
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
