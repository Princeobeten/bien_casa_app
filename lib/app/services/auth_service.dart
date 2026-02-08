import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Service for authentication-related operations including token refresh.
class AuthService {
  /// Attempt to refresh the access token using the stored refresh token.
  /// Returns true if refresh succeeded, false otherwise.
  static Future<bool> tryRefreshTokens() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          print('🔄 No refresh token available');
        }
        return false;
      }

      await ApiService.refreshToken(refreshToken);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('🔄 Token refresh failed: $e');
      }
      return false;
    }
  }
}
