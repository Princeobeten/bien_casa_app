import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class UserProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  /// True until first profile load (cache or API) is done. Used for skeleton on profile screen.
  final RxBool isInitialLoading = true.obs;
  final RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;
  final Rx<String?> authToken = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadCachedDataAndFetch();
  }

  Future<void> _loadCachedDataAndFetch() async {
    // Load cached data first for instant display
    final cachedData = await StorageService.getUserData();
    if (cachedData != null && cachedData.isNotEmpty) {
      userProfile.value = cachedData;
      isInitialLoading.value = false; // Show cached content immediately
      if (kDebugMode) {
        print('✅ Loaded cached profile data');
      }
    }

    // Then load token and fetch fresh data
    authToken.value = await StorageService.getToken();
    if (authToken.value != null) {
      await fetchUserProfile();
    } else {
      isInitialLoading.value = false;
    }
  }

  Future<void> fetchUserProfile() async {
    if (authToken.value == null) {
      isInitialLoading.value = false;
      if (kDebugMode) {
        print('⚠️ No auth token available');
      }
      return;
    }

    isLoading.value = true;

    try {
      final response = await ApiService.getUserProfile(token: authToken.value!);

      if (kDebugMode) {
        print('User profile fetched: $response');
      }

      if (response['data'] != null) {
        userProfile.value = response['data'];
        // Update stored user data
        await StorageService.updateUserData(response['data']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fetch profile error: $e');
      }
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isInitialLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? middleName,
    String? lastName,
    String? phone,
    String? email,
    String? gender,
    String? profilePhoto,
  }) async {
    if (authToken.value == null) {
      Get.snackbar(
        'Error',
        'Not authenticated',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await ApiService.updateUserProfile(
        token: authToken.value!,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        phone: phone,
        email: email,
        gender: gender,
        profilePhoto: profilePhoto,
      );

      if (kDebugMode) {
        print('Profile updated: $response');
      }

      Get.snackbar(
        'Success',
        response['message'] ?? 'Profile updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh profile data
      await fetchUserProfile();
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    if (authToken.value == null) {
      Get.snackbar(
        'Error',
        'Not authenticated',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await ApiService.deleteUserAccount(token: authToken.value!);

      if (kDebugMode) {
        print('Account deleted: $response');
      }

      Get.snackbar(
        'Success',
        response['message'] ?? 'Account deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear stored auth data
      await StorageService.clearAuthData();

      // Navigate to welcome screen
      Get.offAllNamed('/welcome');
    } catch (e) {
      if (kDebugMode) {
        print('Delete account error: $e');
      }
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String get firstName => userProfile['firstName']?.toString() ?? 'User';
  String get middleName => userProfile['middleName']?.toString() ?? '';
  String get lastName => userProfile['lastName']?.toString() ?? '';
  String get fullName {
    final parts = [firstName, middleName, lastName]
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'User' : parts.join(' ');
  }
  String get email => userProfile['email']?.toString() ?? '';
  String get phone => userProfile['phone']?.toString() ?? '';
  String get profilePhoto => userProfile['profilePhoto']?.toString() ?? '';
}
