import 'package:get/get.dart';

class AppModeController extends GetxController {
  static AppModeController get instance => Get.find<AppModeController>();
  
  final RxBool _isHomeOwnerMode = false.obs;
  
  bool get isHomeOwnerMode => _isHomeOwnerMode.value;
  
  void setHomeOwnerMode(bool value) {
    _isHomeOwnerMode.value = value;
    update();
  }
  
  void toggleMode() {
    _isHomeOwnerMode.value = !_isHomeOwnerMode.value;
    update();
  }
  
  void switchToUserMode() {
    print('AppModeController: Switching to user mode');
    _isHomeOwnerMode.value = false;
    print('AppModeController: isHomeOwnerMode = ${_isHomeOwnerMode.value}');
    update();
  }
  
  void switchToHomeOwnerMode() {
    print('AppModeController: Switching to home owner mode');
    _isHomeOwnerMode.value = true;
    print('AppModeController: isHomeOwnerMode = ${_isHomeOwnerMode.value}');
    update();
  }
}