import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class AccountStatusService {
  static String get baseUrl => AppConstants.baseApiUrl;

  // Get account status (retries once with refreshed token on 403)
  static Future<Map<String, dynamic>> getAccountStatus() async {
    try {
      final token = await StorageService.getToken();

      if (kDebugMode) {
        print('📊 ===== GET ACCOUNT STATUS =====');
        print('📊 Endpoint: $baseUrl/auth/account-status');
      }

      var response = await http.get(
        Uri.parse('$baseUrl/auth/account-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // On 403, try refresh token once then retry
      if (response.statusCode == 403) {
        if (kDebugMode) {
          print('📊 403 received, attempting token refresh...');
        }
        final refreshed = await AuthService.tryRefreshTokens();
        if (refreshed) {
          final newToken = await StorageService.getToken();
          response = await http.get(
            Uri.parse('$baseUrl/auth/account-status'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $newToken',
            },
          );
          if (kDebugMode) {
            print('📊 Retry after refresh: ${response.statusCode}');
          }
        }
      }

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📊 Response: ${response.body}');
        print('📊 ===============================');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch account status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Account status error: $e');
      }
      rethrow;
    }
  }

  // Send email OTP
  static Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp/email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send email OTP');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Verify email OTP
  static Future<Map<String, dynamic>> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to verify email OTP');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Verify NIN
  static Future<Map<String, dynamic>> verifyNIN({
    required String nin,
    required String dateOfBirth,
  }) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/misc/verify-nin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nin': nin, 'dateOfBirth': dateOfBirth}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to verify NIN');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Send OTP via WhatsApp (for NIN resend - uses local phone format e.g. 09060047882)
  static Future<Map<String, dynamic>> sendOtpWhatsApp(String phone) async {
    try {
      final token = await StorageService.getToken();
      final phoneForWhatsApp = _toWhatsAppPhoneFormat(phone);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp/whatsapp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'phone': phoneForWhatsApp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP via WhatsApp');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Send OTP via SMS (for NIN resend - uses E.164 format e.g. 2349060047882)
  static Future<Map<String, dynamic>> sendOtpSms(String phone) async {
    try {
      final token = await StorageService.getToken();
      final phoneForSms = _toSmsPhoneFormat(phone);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp/sms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'phone': phoneForSms}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP via SMS');
      }
    } catch (e) {
      rethrow;
    }
  }

  static String _toWhatsAppPhoneFormat(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('234')) {
      return '0${digits.substring(3)}';
    }
    if (digits.startsWith('0')) {
      return digits;
    }
    if (digits.startsWith('9') && digits.length >= 10) {
      return '0$digits';
    }
    return phone;
  }

  static String _toSmsPhoneFormat(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('234')) {
      return digits;
    }
    if (digits.startsWith('0')) {
      return '234${digits.substring(1)}';
    }
    if (digits.startsWith('9') && digits.length >= 10) {
      return '234$digits';
    }
    return '234$digits';
  }

  // Confirm NIN
  static Future<Map<String, dynamic>> confirmNIN({String? otp}) async {
    try {
      final token = await StorageService.getToken();

      final payload = {
        if (otp != null && otp.isNotEmpty) 'otp': otp,
      };

      if (kDebugMode) {
        print('🔐 ===== CONFIRM NIN REQUEST =====');
        print('🔐 Endpoint: POST $baseUrl/misc/confirm-nin');
        print('🔐 Payload: $payload');
        print('🔐 ===============================');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/misc/confirm-nin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to confirm NIN');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Process virtual account (create wallet)
  static Future<Map<String, dynamic>> processVirtualAccount(
    String walletPin,
  ) async {
    try {
      final token = await StorageService.getToken();

      if (kDebugMode) {
        print('🔐 ===== PROCESS VIRTUAL ACCOUNT =====');
        print('🔐 Endpoint: $baseUrl/wallet/virtual-account/process');
        print('🔐 Method: POST');
        print('🔐 Token length: ${token?.length ?? 0}');
        print('🔐 Token starts with: ${token?.substring(0, 10)}...');
        print(
          '🔐 Headers: {"Content-Type": "application/json", "Authorization": "Bearer [TOKEN]"}',
        );
        print('🔐 Payload: {"walletPin": "$walletPin"}');
        print('🔐 Raw JSON body: ${jsonEncode({'walletPin': walletPin})}');
        print('🔐 ====================================');
      }

      final requestBody = jsonEncode({'walletPin': walletPin});
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      if (kDebugMode) {
        print('🔐 Full headers: $headers');
        print('🔐 Request body type: ${requestBody.runtimeType}');
        print('🔐 Request body length: ${requestBody.length}');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/wallet/virtual-account/process'),
        headers: headers,
        body: requestBody,
      );

      if (kDebugMode) {
        print('🔐 ===== PROCESS VIRTUAL ACCOUNT RESPONSE =====');
        print('🔐 Status Code: ${response.statusCode}');
        print('🔐 Response Headers: ${response.headers}');
        print('🔐 Response Body: ${response.body}');
        print('🔐 Response Body Length: ${response.body.length}');
        print('🔐 ============================================');
      }

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // Try to parse error response
        try {
          final error = jsonDecode(response.body);
          if (kDebugMode) {
            print('🔐 Parsed error: $error');
          }
          throw Exception(
            error['message'] ?? 'Failed to process virtual account',
          );
        } catch (parseError) {
          if (kDebugMode) {
            print('🔐 Failed to parse error response: $parseError');
          }
          throw Exception(
            'Server error (${response.statusCode}): ${response.body}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Process virtual account error: $e');
        print('❌ Error type: ${e.runtimeType}');
      }
      rethrow;
    }
  }

  // Get data fields by category
  static Future<Map<String, dynamic>> getDataFields(String categoryName) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/misc/datafields/$categoryName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch data fields');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.patch(
        Uri.parse('$baseUrl/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      rethrow;
    }
  }
}
