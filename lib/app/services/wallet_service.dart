import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../config/app_constants.dart';
import 'dio_client.dart';

class WalletService {
  static String get baseUrl => AppConstants.baseApiUrl;

  static Future<Map<String, dynamic>> _handleResponse(
      Future<Map<String, dynamic>> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Wallet error: $e');
        print('❌ Response statusCode: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      throw Exception(message ?? e.message ?? 'Request failed');
    }
  }

  // Get all user wallets
  static Future<Map<String, dynamic>> getUserWallets() async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== GET USER WALLETS =====');
        print('💰 Endpoint: $baseUrl/wallet/wallet');
      }
      final data = await DioClient.get('wallet/wallet');
      if (kDebugMode) {
        print('💰 Response: $data');
        print('💰 ==============================');
      }
      return data;
    });
  }

  // Get wallet by ID
  static Future<Map<String, dynamic>> getWalletById(int walletId) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== GET WALLET BY ID =====');
        print('💰 Endpoint: $baseUrl/wallet/wallet/$walletId');
      }
      final data = await DioClient.get('wallet/wallet/$walletId');
      if (kDebugMode) {
        print('💰 Response: $data');
        print('💰 ==============================');
      }
      return data;
    });
  }

  // Get wallet balance with details
  static Future<Map<String, dynamic>> getWalletBalance({
    required int walletId,
    bool includeDetails = true,
  }) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== GET WALLET BALANCE =====');
        print('💰 Endpoint: $baseUrl/wallet/wallet/$walletId/balance');
      }
      final data = await DioClient.get(
        'wallet/wallet/$walletId/balance',
        queryParameters: {'includeDetails': includeDetails},
      );
      if (kDebugMode) {
        print('💰 Response: $data');
        print('💰 ================================');
      }
      return data;
    });
  }

  // Get user transactions
  static Future<Map<String, dynamic>> getUserTransactions({
    String? type,
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    return _handleResponse(() async {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;

      if (kDebugMode) {
        print('💰 ===== GET USER TRANSACTIONS =====');
        print('💰 Endpoint: $baseUrl/wallet/transactions');
      }
      final data = await DioClient.get(
        'wallet/transactions',
        queryParameters: queryParams,
      );
      if (kDebugMode) {
        print('💰 Response: $data');
        print('💰 ===================================');
      }
      return data;
    });
  }

  // Get transaction by ID
  static Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== GET TRANSACTION BY ID =====');
        print('💰 Endpoint: $baseUrl/wallet/transactions/$transactionId');
      }
      final data = await DioClient.get('wallet/transactions/$transactionId');
      if (kDebugMode) {
        print('💰 Response: $data');
        print('💰 ===================================');
      }
      return data;
    });
  }

  // Get available banks
  static Future<Map<String, dynamic>> getBanks() async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== GET BANKS =====');
        print('💰 Endpoint: $baseUrl/wallet/banks');
      }
      final data = await DioClient.get('wallet/banks');
      if (kDebugMode) {
        print('💰 Response: $data');
        print('💰 ========================');
      }
      return data;
    });
  }

  // Validate account name
  static Future<Map<String, dynamic>> validateAccountName({
    required String accountNumber,
    required String bankCode,
  }) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== VALIDATE ACCOUNT NAME =====');
        print('💰 Endpoint: $baseUrl/wallet/validate-account-name');
        print('💰 Account: $accountNumber, Bank: $bankCode');
      }
      final data = await DioClient.post(
        'wallet/validate-account-name',
        data: {'accountNumber': accountNumber, 'bankCode': bankCode},
      );
      if (kDebugMode) {
        print('💰 Response: $data');
        print('💰 ====================================');
      }
      return data;
    });
  }

  // Transfer to external account
  // Auth: provide either pin (4 digits) OR biometric (deviceId, signature, nonce, timestamp), not both.
  static Future<Map<String, dynamic>> transferToExternal({
    required String accountNumber,
    required String accountName,
    required String bankCode,
    required String bankName,
    required double amount,
    required String narration,
    String? idempotencyKey,
    String? pin,
    bool biometric = false,
    String? deviceId,
    String? signature,
    String? nonce,
    int? timestamp,
  }) async {
    const _uuid = Uuid();
    final idemKey = idempotencyKey ?? _uuid.v4();

    final body = <String, dynamic>{
      'idempotencyKey': idemKey,
      'amount': amount,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'bankCode': bankCode,
      'bankName': bankName,
      'narration': narration,
    };

    if (pin != null && pin.isNotEmpty) {
      body['pin'] = pin;
    } else if (biometric &&
        deviceId != null &&
        signature != null &&
        nonce != null &&
        timestamp != null) {
      body['biometric'] = true;
      body['deviceId'] = deviceId;
      body['signature'] = signature;
      body['nonce'] = nonce;
      body['timestamp'] = timestamp;
    }

    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== TRANSFER TO EXTERNAL =====');
        print('💰 Endpoint: $baseUrl/wallet/transfer-to-external');
        print('💰 Payload: $body');
      }
      final data = await DioClient.post(
        'wallet/transfer-to-external',
        data: body,
      );
      if (kDebugMode) {
        print('💰 Response: $data');
        print('💰 ===================================');
      }
      return data;
    });
  }

  /// POST /wallet/calculate-fee — Calculate transaction fee for a given amount
  static Future<Map<String, dynamic>> calculateFee(num amount) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== CALCULATE FEE =====');
        print('💰 Endpoint: $baseUrl/wallet/calculate-fee Amount: $amount');
      }
      final data = await DioClient.post(
        'wallet/calculate-fee',
        data: {'amount': amount},
      );
      if (kDebugMode) print('💰 Calculate fee response: $data');
      return data;
    });
  }

  // --- Biometric APIs ---

  /// GET /wallet/biometric/check/{deviceId}
  static Future<Map<String, dynamic>> checkBiometric(String deviceId) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== CHECK BIOMETRIC =====');
        print('💰 Endpoint: $baseUrl/wallet/biometric/check/$deviceId');
      }
      final data = await DioClient.get('wallet/biometric/check/$deviceId');
      if (kDebugMode) print('💰 Biometric check: $data');
      return data;
    });
  }

  /// POST /wallet/biometric/enable
  static Future<Map<String, dynamic>> enableBiometric({
    required String deviceId,
    required String publicKey,
  }) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== ENABLE BIOMETRIC =====');
        print('💰 Endpoint: $baseUrl/wallet/biometric/enable');
      }
      final data = await DioClient.post(
        'wallet/biometric/enable',
        data: {'deviceId': deviceId, 'publicKey': publicKey},
      );
      if (kDebugMode) print('💰 Biometric enable: $data');
      return data;
    });
  }

  /// GET /wallet/biometric/challenge/{deviceId}
  static Future<Map<String, dynamic>> getBiometricChallenge(String deviceId) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('📤 GET CHALLENGE Endpoint: $baseUrl/wallet/biometric/challenge/$deviceId');
      }
      final data = await DioClient.get('wallet/biometric/challenge/$deviceId');
      if (kDebugMode) print('📥 GET CHALLENGE Response: $data');
      return data;
    });
  }

  /// POST /wallet/biometric/disable
  static Future<Map<String, dynamic>> disableBiometric({
    required String deviceId,
    required String publicKey,
    required String signature,
  }) async {
    return _handleResponse(() async {
      final payload = {
        'deviceId': deviceId,
        'publicKey': publicKey,
        'signature': signature,
      };
      if (kDebugMode) {
        print('📤 POST DISABLE Endpoint: $baseUrl/wallet/biometric/disable');
        print('📤 POST DISABLE Payload: deviceId=$deviceId publicKeyLength=${publicKey.length} signatureLength=${signature.length}');
      }
      final data = await DioClient.post(
        'wallet/biometric/disable',
        data: payload,
      );
      if (kDebugMode) print('📥 POST DISABLE Response: $data');
      return data;
    });
  }

  /// POST /wallet/biometrictest/verify — verify signature for transaction
  static Future<Map<String, dynamic>> verifyBiometric({
    required String deviceId,
    required String signature,
  }) async {
    return _handleResponse(() async {
      if (kDebugMode) {
        print('💰 ===== VERIFY BIOMETRIC =====');
        print('💰 Endpoint: $baseUrl/wallet/biometrictest/verify');
      }
      final data = await DioClient.post(
        'wallet/biometrictest/verify',
        data: {'deviceId': deviceId, 'signature': signature},
      );
      if (kDebugMode) print('💰 Biometric verify: $data');
      return data;
    });
  }
}
