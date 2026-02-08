import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_constants.dart';
import 'storage_service.dart';

/// User-friendly message when no network is available.
const String _noNetworkMessage =
    'No internet connection. Please check your network and try again.';

bool _isNetworkError(Object e) =>
    e is SocketException ||
    e is TimeoutException ||
    e is HandshakeException ||
    e is http.ClientException;

class ApiService {
  static String baseUrl = AppConstants.baseApiUrl;
  
  // Auth endpoints
  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      if (kDebugMode) {
        print('Login response: ${response.statusCode}');
        print('Login body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      if (_isNetworkError(e)) {
        throw Exception(_noNetworkMessage);
      }
      rethrow;
    }
  }

  /// Refresh access token using refresh token
  /// Returns new access and refresh tokens
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing access token...');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (kDebugMode) {
        print('Refresh token response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokenData = data['data'];
        if (tokenData != null) {
          final accessToken = tokenData['accessToken'] as String?;
          final newRefreshToken = tokenData['refreshToken'] as String?;
          if (accessToken != null && newRefreshToken != null) {
            await StorageService.saveTokens(
              accessToken: accessToken,
              refreshToken: newRefreshToken,
            );
            if (kDebugMode) {
              print('✅ Token refreshed successfully');
            }
            return data;
          }
        }
        throw Exception('Invalid refresh response');
      } else {
        final error = jsonDecode(response.body);
        final message = error['error'] ?? error['message'] ?? 'Failed to refresh token';
        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Refresh token error: $e');
      }
      if (_isNetworkError(e)) {
        throw Exception(_noNetworkMessage);
      }
      rethrow;
    }
  }

  // Signup
  static Future<Map<String, dynamic>> signup({
    required String firstName,
    String? middleName,
    required String lastName,
    required String phone,
    required String password,
    String? referralCode,
  }) async {
    try {
      final body = {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'password': password,
      };
      
      if (middleName != null && middleName.isNotEmpty) {
        body['middleName'] = middleName;
      }
      
      if (referralCode != null && referralCode.isNotEmpty) {
        body['referralCode'] = referralCode;
      }

      if (kDebugMode) {
        print('📤 ===== API SIGNUP REQUEST =====');
        print('📤 Endpoint: $baseUrl/auth/signup');
        print('📤 Method: POST');
        print('📤 Headers: {"Content-Type": "application/json"}');
        print('📤 Payload: ${jsonEncode(body).replaceAll('"password":"$password"', '"password":"***hidden***"')}');
        print('📤 ================================');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('📥 ===== API SIGNUP RESPONSE =====');
        print('📥 Status Code: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');
        print('📥 =================================');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Signup failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Signup error: $e');
      }
      if (_isNetworkError(e)) {
        throw Exception(_noNetworkMessage);
      }
      rethrow;
    }
  }

  // Send OTP via WhatsApp
  static Future<Map<String, dynamic>> sendOtpWhatsApp({
    required String phone,
  }) async {
    try {
      if (kDebugMode) {
        print('Sending WhatsApp OTP to: $phone');
        print('URL: $baseUrl/auth/send-otp/whatsapp');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp/whatsapp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
        }),
      );

      if (kDebugMode) {
        print('Send WhatsApp OTP response: ${response.statusCode}');
        print('Send WhatsApp OTP body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Failed to send OTP (${response.statusCode})');
        } catch (e) {
          throw Exception('Failed to send OTP: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Send WhatsApp OTP error: $e');
      }
      rethrow;
    }
  }

  // Verify WhatsApp OTP
  static Future<Map<String, dynamic>> verifyOtpWhatsApp({
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp/whatsapp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
        }),
      );

      if (kDebugMode) {
        print('Verify WhatsApp OTP response: ${response.statusCode}');
        print('Verify WhatsApp OTP body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Verify WhatsApp OTP error: $e');
      }
      rethrow;
    }
  }

  // Send OTP via WhatsApp (New endpoint)
  static Future<Map<String, dynamic>> sendOTPViaWhatsApp({
    required String phone,
  }) async {
    try {
      if (kDebugMode) {
        print('📱 Sending OTP via WhatsApp to: $phone');
        print('📱 Endpoint: $baseUrl/auth/send-otp/whatsapp');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp/whatsapp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
        }),
      );

      if (kDebugMode) {
        print('📱 WhatsApp OTP response: ${response.statusCode}');
        print('📱 WhatsApp OTP body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ WhatsApp OTP sent successfully');
        }
        return result;
      } else {
        final error = jsonDecode(response.body);
        if (kDebugMode) {
          print('❌ WhatsApp OTP failed: ${error['message']}');
        }
        throw Exception(error['message'] ?? 'Failed to send OTP via WhatsApp');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Send WhatsApp OTP error: $e');
      }
      rethrow;
    }
  }

  // Get OTP (for testing/development - deprecated, use sendOTPViaWhatsApp)
  static Future<Map<String, dynamic>> getOtp({
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/get-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
        }),
      );

      if (kDebugMode) {
        print('Get OTP response: ${response.statusCode}');
        print('Get OTP body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get OTP error: $e');
      }
      rethrow;
    }
  }

  // Send OTP via SMS
  static Future<Map<String, dynamic>> sendOTPViaSMS({
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp/sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
        }),
      );

      if (kDebugMode) {
        print('Send OTP SMS response: ${response.statusCode}');
        print('Send OTP SMS body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP via SMS');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Send OTP SMS error: $e');
      }
      rethrow;
    }
  }

  // Send OTP via Email
  static Future<Map<String, dynamic>> sendOTPViaEmail({
    required String email,
  }) async {
    try {
      if (kDebugMode) {
        print('📧 Sending OTP to email: $email');
        print('📧 Endpoint: $baseUrl/auth/send-otp/email');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (kDebugMode) {
        print('📧 Send OTP Email response: ${response.statusCode}');
        print('📧 Send OTP Email body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ Email OTP sent successfully');
        }
        return result;
      } else {
        final error = jsonDecode(response.body);
        if (kDebugMode) {
          print('❌ Email OTP failed: ${error['message']}');
        }
        throw Exception(error['message'] ?? 'Failed to send OTP via email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Send OTP Email error: $e');
      }
      rethrow;
    }
  }

  // Forgot password - send OTP to email
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (kDebugMode) {
        print('Forgot password response: ${response.statusCode}');
        print('Forgot password body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Forgot password error: $e');
      }
      rethrow;
    }
  }

  // Verify email OTP
  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (kDebugMode) {
        print('Verify OTP response: ${response.statusCode}');
        print('Verify OTP body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Verify OTP error: $e');
      }
      rethrow;
    }
  }

  // Reset password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'token': token,
          'password': password,
        }),
      );

      if (kDebugMode) {
        print('Reset password response: ${response.statusCode}');
        print('Reset password body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Reset password error: $e');
      }
      rethrow;
    }
  }

  // Send OTP to phone (for signup/verification)
  static Future<Map<String, dynamic>> sendOtp({
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
        }),
      );

      if (kDebugMode) {
        print('Send OTP response: ${response.statusCode}');
        print('Send OTP body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Send OTP error: $e');
      }
      rethrow;
    }
  }

  // Verify phone OTP
  static Future<Map<String, dynamic>> verifyOtp({
    String? phone,
    String? email,
    required String otp,
    String? identifierType, // 'phone' or 'email'
  }) async {
    try {
      // Determine identifier type if not provided
      final type = identifierType ?? (email != null ? 'email' : 'phone');
      final identifier = email ?? phone;

      if (identifier == null) {
        throw Exception('Either phone or email must be provided');
      }

      final body = {
        'otp': otp,
        'identifierType': type,
        'identifier': identifier,
      };

      if (kDebugMode) {
        print('📤 ===== API VERIFY OTP REQUEST =====');
        print('📤 Endpoint: $baseUrl/auth/verify-otp');
        print('📤 Method: POST');
        print('📤 Headers: {"Content-Type": "application/json"}');
        print('📤 Payload: ${jsonEncode(body)}');
        print('📤 ===================================');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('📥 ===== API VERIFY OTP RESPONSE =====');
        print('📥 Status Code: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');
        print('📥 ====================================');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Verify OTP error: $e');
      }
      rethrow;
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Get profile response: ${response.statusCode}');
        print('Get profile body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get profile error: $e');
      }
      rethrow;
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    String? firstName,
    String? middleName,
    String? lastName,
    String? phone,
    String? email,
    String? gender,
    String? profilePhoto,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (firstName != null && firstName.isNotEmpty) body['firstName'] = firstName;
      if (middleName != null && middleName.isNotEmpty) body['middleName'] = middleName;
      if (lastName != null && lastName.isNotEmpty) body['lastName'] = lastName;
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (gender != null && gender.isNotEmpty) body['gender'] = gender;
      if (profilePhoto != null && profilePhoto.isNotEmpty) body['profilePhoto'] = profilePhoto;

      if (kDebugMode) {
        print('📤 Updating profile with data: $body');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('Update profile response: ${response.statusCode}');
        print('Update profile body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? error['errors']?[0]?['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      rethrow;
    }
  }

  // Delete user account
  static Future<Map<String, dynamic>> deleteUserAccount({
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Delete account response: ${response.statusCode}');
        print('Delete account body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Delete account error: $e');
      }
      rethrow;
    }
  }

  // Set wallet PIN
  static Future<Map<String, dynamic>> setWalletPin({
    required String token,
    required String pin,
  }) async {
    try {
      if (kDebugMode) {
        print('🔐 Setting wallet PIN');
        print('🔐 Endpoint: $baseUrl/wallet/set-pin');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/wallet/set-pin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pin': pin,
        }),
      );

      if (kDebugMode) {
        print('🔐 Set wallet PIN response: ${response.statusCode}');
        print('🔐 Set wallet PIN body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ Wallet PIN set successfully');
        }
        return result;
      } else {
        final error = jsonDecode(response.body);
        if (kDebugMode) {
          print('❌ Set wallet PIN failed: ${error['message']}');
        }
        throw Exception(error['message'] ?? 'Failed to set wallet PIN');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Set wallet PIN error: $e');
      }
      rethrow;
    }
  }
}
