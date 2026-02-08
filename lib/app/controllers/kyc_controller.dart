import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/account_status_service.dart';

class KYCController extends GetxController {
  // Account status observables
  final RxBool emailVerified = false.obs;
  final RxBool phoneVerified = false.obs;
  final RxBool ninSet = false.obs;
  final RxBool bioDataCompleted = false.obs;
  final RxBool walletCreated = false.obs;
  final RxString accountStatus = ''.obs;
  
  final RxBool isLoading = false.obs;
  
  // Cache management
  static const String _cacheKey = 'kyc_account_status_cache';
  static const String _cacheTimestampKey = 'kyc_cache_timestamp';
  static const Duration _cacheValidDuration = Duration(minutes: 3); // Cache for 3 minutes
  DateTime? _lastCacheTime;

  @override
  void onInit() {
    super.onInit();
    fetchAccountStatus();
  }

  // Fetch account status from API with caching
  Future<void> fetchAccountStatus({bool forceRefresh = false}) async {
    try {
      // Check if we have valid cached data first
      if (!forceRefresh && await _hasCachedData()) {
        await _loadFromCache();
        if (kDebugMode) {
          print('✅ KYC Status loaded from cache');
        }
        return;
      }

      isLoading.value = true;
      
      if (kDebugMode) {
        print('📊 Fetching KYC status from API...');
      }
      
      final response = await AccountStatusService.getAccountStatus();
      
      if (response['data'] != null) {
        final data = response['data'];
        
        // Update observables
        emailVerified.value = data['emailVerified'] ?? false;
        phoneVerified.value = data['phoneVerified'] ?? false;
        ninSet.value = data['ninVerified'] ?? data['ninSet'] ?? false;
        accountStatus.value = data['status'] ?? '';
        
        // Check for bioDataCompleted field from API
        if (data.containsKey('bioDataCompleted')) {
          bioDataCompleted.value = data['bioDataCompleted'] ?? false;
        } else if (data['bioData'] != null && data['bioData'] is Map) {
          final bioData = data['bioData'] as Map;
          bioDataCompleted.value = bioData.isNotEmpty;
        }
        
        // Check if wallet exists - API now returns 'wallet' as boolean
        walletCreated.value = data['wallet'] ?? data['walletCreated'] ?? false;
        
        // Cache the data
        await _cacheAccountStatus(data);

        if (kDebugMode) {
          print('✅ Account Status Loaded and Cached:');
          print('   Email Verified: ${emailVerified.value}');
          print('   Phone Verified: ${phoneVerified.value}');
          print('   NIN Verified: ${ninSet.value}');
          print('   Bio Data Completed: ${bioDataCompleted.value}');
          print('   Wallet Created: ${walletCreated.value}');
          print('   Status: ${accountStatus.value}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching account status: $e');
      }
      
      // Try to load from cache as fallback
      if (await _hasCachedData()) {
        await _loadFromCache();
        if (kDebugMode) {
          print('✅ Loaded KYC status from cache (fallback)');
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load account status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate KYC completion percentage
  int get completionPercentage {
    int completed = 0;
    int total = 3; // Only count email, NIN, and wallet
    
    if (emailVerified.value) completed++;
    if (ninSet.value) completed++;
    if (walletCreated.value) completed++;
    
    return ((completed / total) * 100).round();
  }

  // Check if KYC is fully completed (email, NIN, and wallet only)
  bool get isKYCCompleted {
    return emailVerified.value && 
           ninSet.value && 
           walletCreated.value;
  }

  // Get next incomplete step
  String get nextStep {
    if (!emailVerified.value) return 'Verify Email';
    if (!ninSet.value) return 'Verify NIN';
    if (!walletCreated.value) return 'Setup Wallet PIN';
    return 'All Complete';
  }

  Future<bool> _hasCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimestamp = prefs.getInt(_cacheTimestampKey);
      final cachedData = prefs.getString(_cacheKey);
      
      if (cacheTimestamp == null || cachedData == null) {
        return false;
      }
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
      final now = DateTime.now();
      final isValid = now.difference(cacheTime) < _cacheValidDuration;
      
      _lastCacheTime = cacheTime;
      return isValid;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking KYC cache: $e');
      }
      return false;
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDataString = prefs.getString(_cacheKey);
      
      if (cachedDataString != null) {
        final data = jsonDecode(cachedDataString);
        
        // Update observables from cache
        emailVerified.value = data['emailVerified'] ?? false;
        phoneVerified.value = data['phoneVerified'] ?? false;
        ninSet.value = data['ninVerified'] ?? data['ninSet'] ?? false;
        accountStatus.value = data['status'] ?? '';
        
        if (data.containsKey('bioDataCompleted')) {
          bioDataCompleted.value = data['bioDataCompleted'] ?? false;
        } else if (data['bioData'] != null && data['bioData'] is Map) {
          final bioData = data['bioData'] as Map;
          bioDataCompleted.value = bioData.isNotEmpty;
        }
        
        walletCreated.value = data['wallet'] ?? data['walletCreated'] ?? false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading KYC data from cache: $e');
      }
    }
  }

  Future<void> _cacheAccountStatus(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_cacheKey, jsonEncode(data));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      _lastCacheTime = DateTime.now();
      
      if (kDebugMode) {
        print('✅ KYC account status cached successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error caching KYC account status: $e');
      }
    }
  }

  // Force refresh method for pull-to-refresh
  Future<void> refreshAccountStatus() async {
    await fetchAccountStatus(forceRefresh: true);
  }
}
