import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observable variables (reactive state)
  final count = 0.obs;
  final isLoading = false.obs;
  final username = 'Guest'.obs;

  // Increment counter
  void increment() => count.value++;

  // Toggle loading state
  void toggleLoading() => isLoading.value = !isLoading.value;

  // Update username
  void updateUsername(String name) => username.value = name;
}
