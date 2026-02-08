import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save authentication data
  static Future<void> saveAuthData({
    required String token,
    required Map<String, dynamic> userData,
    String? refreshToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userDataKey, jsonEncode(userData));
      await prefs.setBool(_isLoggedInKey, true);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
      
      if (kDebugMode) {
        print('✅ Auth data saved successfully');
        print('Token: ${token.substring(0, 20)}...');
        if (refreshToken != null) {
          print('Refresh token: ${refreshToken.substring(0, 20)}...');
        }
        print('User: ${userData['firstName']} ${userData['lastName']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving auth data: $e');
      }
      rethrow;
    }
  }

  // Get stored refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting refresh token: $e');
      }
      return null;
    }
  }

  // Save tokens (used after refresh)
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      
      if (kDebugMode) {
        print('✅ Tokens refreshed and saved');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving tokens: $e');
      }
      rethrow;
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token: $e');
      }
      return null;
    }
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final token = prefs.getString(_tokenKey);
      
      // User is logged in if flag is true AND token exists
      return isLoggedIn && token != null && token.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }
      return false;
    }
  }

  // Clear all auth data (logout)
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.setBool(_isLoggedInKey, false);
      
      if (kDebugMode) {
        print('✅ Auth data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing auth data: $e');
      }
      rethrow;
    }
  }

  // Update user data only
  static Future<void> updateUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(userData));
      
      if (kDebugMode) {
        print('✅ User data updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user data: $e');
      }
      rethrow;
    }
  }
}
