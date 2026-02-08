import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class WelcomeController extends GetxController {
  final RxBool isCheckingAuth = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      final userData = await StorageService.getUserData();
      
      if (kDebugMode) {
        print('🔐 Checking auth status...');
        print('Is logged in: $isLoggedIn');
        if (userData != null) {
          print('User: ${userData['firstName']} ${userData['lastName']}');
        }
      }

      if (isLoggedIn && userData != null) {
        // Try to refresh token so home screen has a valid token
        await AuthService.tryRefreshTokens();

        // User is already logged in, navigate to home
        if (kDebugMode) {
          print('✅ Auto-login successful, navigating to home...');
        }

        // Small delay to show splash/welcome screen briefly
        await Future.delayed(const Duration(milliseconds: 500));

        Get.offAllNamed(AppRoutes.USER_HOME);
      } else {
        if (kDebugMode) {
          print('ℹ️ No active session, showing welcome screen');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking auth status: $e');
      }
    } finally {
      isCheckingAuth.value = false;
    }
  }

  void navigateToSignUp() {
    // Navigate directly to phone verification, skipping role selection
    Get.toNamed(AppRoutes.PHONE_VERIFICATION, arguments: 'User');
  }

  void navigateToSignIn() {
    Get.toNamed(AppRoutes.SIGNIN);
  }
}
