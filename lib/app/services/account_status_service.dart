import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_constants.dart';
import 'dio_client.dart';
import 'storage_service.dart';

class AccountStatusService {
  static String get baseUrl => AppConstants.baseApiUrl;

  static Future<Map<String, dynamic>> _handleResponse(
      Future<Map<String, dynamic>> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Account status error: $e');
      }
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      throw Exception(message ?? e.message ?? 'Request failed');
    }
  }

  // Get account status (Dio interceptor handles 401/403 → refresh → retry)
  static Future<Map<String, dynamic>> getAccountStatus() async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('📊 ===== GET ACCOUNT STATUS =====');
        print('📊 Endpoint: $baseUrl/auth/account-status');
      }
      final data = await DioClient.get('auth/account-status');
      if (kDebugMode) {
        print('📊 Response: $data');
        print('📊 ===============================');
      }
      return data;
    });
  }

  // Send email OTP
  static Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    return _handleResponse(() => DioClient.post(
          'auth/send-otp/email',
          data: {'email': email},
        ));
  }

  // Verify email OTP
  static Future<Map<String, dynamic>> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    return _handleResponse(() => DioClient.post(
          'auth/verify-email-otp',
          data: {'email': email, 'otp': otp},
        ));
  }

  // Verify NIN
  static Future<Map<String, dynamic>> verifyNIN({
    required String nin,
    required String dateOfBirth,
  }) async {
    return _handleResponse(() => DioClient.post(
          'misc/verify-nin',
          data: {'nin': nin, 'dateOfBirth': dateOfBirth},
        ));
  }

  // Send OTP via WhatsApp (for NIN resend - uses local phone format e.g. 09060047882)
  static Future<Map<String, dynamic>> sendOtpWhatsApp(String phone) async {
    final phoneForWhatsApp = _toWhatsAppPhoneFormat(phone);
    return _handleResponse(() => DioClient.post(
          'auth/send-otp/whatsapp',
          data: {'phone': phoneForWhatsApp},
        ));
  }

  // Send OTP via SMS (for NIN resend - uses E.164 format e.g. 2349060047882)
  static Future<Map<String, dynamic>> sendOtpSms(String phone) async {
    final phoneForSms = _toSmsPhoneFormat(phone);
    return _handleResponse(() => DioClient.post(
          'auth/send-otp/sms',
          data: {'phone': phoneForSms},
        ));
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
    return _handleResponse(() async {
      final payload = <String, dynamic>{
        if (otp != null && otp.isNotEmpty) 'otp': otp,
      };
      if (kDebugMode) {
        print('🔐 ===== CONFIRM NIN REQUEST =====');
        print('🔐 Endpoint: POST $baseUrl/misc/confirm-nin');
        print('🔐 Payload: $payload');
        print('🔐 ===============================');
      }
      return DioClient.post('misc/confirm-nin', data: payload);
    });
  }

  // Process virtual account (create wallet)
  static Future<Map<String, dynamic>> processVirtualAccount(
    String walletPin,
  ) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        final token = await StorageService.getToken();
        print('🔐 ===== PROCESS VIRTUAL ACCOUNT =====');
        print('🔐 Endpoint: $baseUrl/wallet/virtual-account/process');
        print('🔐 Token length: ${token?.length ?? 0}');
        print('🔐 ====================================');
      }
      final result = await DioClient.post(
        'wallet/virtual-account/process',
        data: {'walletPin': walletPin},
      );
      if (kDebugMode) {
        print('🔐 Response: $result');
      }
      return result;
    });
  }

  // Get data fields by category
  static Future<Map<String, dynamic>> getDataFields(String categoryName) async {
    return _handleResponse(() =>
        DioClient.get('misc/datafields/$categoryName'));
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    return _handleResponse(() => DioClient.patch('user/update', data: data));
  }
}
