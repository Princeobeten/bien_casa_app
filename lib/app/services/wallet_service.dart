import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import 'storage_service.dart';

class WalletService {
  static String get baseUrl => AppConstants.baseApiUrl;

  // Get all user wallets
  static Future<Map<String, dynamic>> getUserWallets() async {
    try {
      final token = await StorageService.getToken();

      if (kDebugMode) {
        print('💰 ===== GET USER WALLETS =====');
        print('💰 Endpoint: $baseUrl/wallet/wallet');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/wallet/wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('💰 Status Code: ${response.statusCode}');
        print('💰 Response: ${response.body}');
        print('💰 ==============================');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch wallets');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get wallets error: $e');
      }
      rethrow;
    }
  }

  // Get wallet by ID
  static Future<Map<String, dynamic>> getWalletById(int walletId) async {
    try {
      final token = await StorageService.getToken();

      if (kDebugMode) {
        print('💰 ===== GET WALLET BY ID =====');
        print('💰 Endpoint: $baseUrl/wallet/wallet/$walletId');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/wallet/wallet/$walletId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('💰 Status Code: ${response.statusCode}');
        print('💰 Response: ${response.body}');
        print('💰 ==============================');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch wallet');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get wallet error: $e');
      }
      rethrow;
    }
  }

  // Get wallet balance with details
  static Future<Map<String, dynamic>> getWalletBalance({
    required int walletId,
    bool includeDetails = true,
  }) async {
    try {
      final token = await StorageService.getToken();

      final uri = Uri.parse('$baseUrl/wallet/wallet/$walletId/balance')
          .replace(queryParameters: {'includeDetails': includeDetails.toString()});

      if (kDebugMode) {
        print('💰 ===== GET WALLET BALANCE =====');
        print('💰 Endpoint: $uri');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('💰 Status Code: ${response.statusCode}');
        print('💰 Response: ${response.body}');
        print('💰 ================================');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch balance');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get balance error: $e');
      }
      rethrow;
    }
  }

  // Get user transactions
  static Future<Map<String, dynamic>> getUserTransactions({
    String? type,
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await StorageService.getToken();

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/wallet/transactions')
          .replace(queryParameters: queryParams);

      if (kDebugMode) {
        print('💰 ===== GET USER TRANSACTIONS =====');
        print('💰 Endpoint: $uri');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('💰 Status Code: ${response.statusCode}');
        print('💰 Response: ${response.body}');
        print('💰 ===================================');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch transactions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get transactions error: $e');
      }
      rethrow;
    }
  }

  // Get transaction by ID
  static Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    try {
      final token = await StorageService.getToken();

      if (kDebugMode) {
        print('💰 ===== GET TRANSACTION BY ID =====');
        print('💰 Endpoint: $baseUrl/wallet/transactions/$transactionId');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/wallet/transactions/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('💰 Status Code: ${response.statusCode}');
        print('💰 Response: ${response.body}');
        print('💰 ===================================');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch transaction');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get transaction error: $e');
      }
      rethrow;
    }
  }

  // Get available banks
  static Future<Map<String, dynamic>> getBanks() async {
    try {
      final token = await StorageService.getToken();

      if (kDebugMode) {
        print('💰 ===== GET BANKS =====');
        print('💰 Endpoint: $baseUrl/wallet/banks');
        print('💰 Token: ${token?.substring(0, 20)}...');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/wallet/banks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('💰 Status Code: ${response.statusCode}');
        print('💰 Response Body: ${response.body}');
        print('💰 Response Length: ${response.body.length}');
        print('💰 ========================');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (kDebugMode) {
          print('💰 Decoded response: $decoded');
        }
        return decoded;
      } else {
        if (kDebugMode) {
          print('❌ Error status code: ${response.statusCode}');
        }
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Failed to fetch banks');
        } catch (e) {
          throw Exception('Failed to fetch banks: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get banks error: $e');
      }
      rethrow;
    }
  }

  // Validate account name
  static Future<Map<String, dynamic>> validateAccountName({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final token = await StorageService.getToken();

      if (kDebugMode) {
        print('💰 ===== VALIDATE ACCOUNT NAME =====');
        print('💰 Endpoint: $baseUrl/wallet/validate-account-name');
        print('💰 Account: $accountNumber, Bank: $bankCode');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/wallet/validate-account-name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'accountNumber': accountNumber,
          'bankCode': bankCode,
        }),
      );

      if (kDebugMode) {
        print('💰 Status Code: ${response.statusCode}');
        print('💰 Response: ${response.body}');
        print('💰 ====================================');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to validate account');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Validate account error: $e');
      }
      rethrow;
    }
  }

  // Transfer to external account
  static Future<Map<String, dynamic>> transferToExternal({
    required String accountNumber,
    required String bankCode,
    required double amount,
    required String narration,
  }) async {
    try {
      final token = await StorageService.getToken();

      if (kDebugMode) {
        print('💰 ===== TRANSFER TO EXTERNAL =====');
        print('💰 Endpoint: $baseUrl/wallet/transfer-to-external');
        print('💰 Amount: $amount, Account: $accountNumber');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/wallet/transfer-to-external'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'accountNumber': accountNumber,
          'bankCode': bankCode,
          'amount': amount,
          'narration': narration,
        }),
      );

      if (kDebugMode) {
        print('💰 Status Code: ${response.statusCode}');
        print('💰 Response: ${response.body}');
        print('💰 ===================================');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Transfer failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Transfer error: $e');
      }
      rethrow;
    }
  }

  /// POST /wallet/calculate-fee — Calculate transaction fee for a given amount
  static Future<Map<String, dynamic>> calculateFee(num amount) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/calculate-fee'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amount}),
      );
      if (kDebugMode) {
        print('💰 Calculate fee: ${response.statusCode} ${response.body}');
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to calculate fee');
    } catch (e) {
      if (kDebugMode) print('❌ Calculate fee error: $e');
      rethrow;
    }
  }

  // --- Biometric APIs ---

  /// GET /wallet/biometric/check/{deviceId}
  static Future<Map<String, dynamic>> checkBiometric(String deviceId) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/biometric/check/$deviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (kDebugMode) {
        print('💰 Biometric check: ${response.statusCode} ${response.body}');
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to check biometric');
    } catch (e) {
      if (kDebugMode) print('❌ Check biometric error: $e');
      rethrow;
    }
  }

  /// POST /wallet/biometric/enable
  static Future<Map<String, dynamic>> enableBiometric({
    required String deviceId,
    required String publicKey,
  }) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/biometric/enable'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'deviceId': deviceId, 'publicKey': publicKey}),
      );
      if (kDebugMode) {
        print('💰 Biometric enable: ${response.statusCode} ${response.body}');
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to enable biometric');
    } catch (e) {
      if (kDebugMode) print('❌ Enable biometric error: $e');
      rethrow;
    }
  }

  /// GET /wallet/biometric/challenge/{deviceId}
  static Future<Map<String, dynamic>> getBiometricChallenge(String deviceId) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/biometric/challenge/$deviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (kDebugMode) {
        print('💰 Biometric challenge: ${response.statusCode} ${response.body}');
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to get challenge');
    } catch (e) {
      if (kDebugMode) print('❌ Get challenge error: $e');
      rethrow;
    }
  }

  /// POST /wallet/biometric/disable
  static Future<Map<String, dynamic>> disableBiometric({
    required String deviceId,
    required String publicKey,
    required String signature,
  }) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/biometric/disable'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'deviceId': deviceId,
          'publicKey': publicKey,
          'signature': signature,
        }),
      );
      if (kDebugMode) {
        print('💰 Biometric disable: ${response.statusCode} ${response.body}');
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to disable biometric');
    } catch (e) {
      if (kDebugMode) print('❌ Disable biometric error: $e');
      rethrow;
    }
  }

  /// POST /wallet/biometrictest/verify — verify signature for transaction
  static Future<Map<String, dynamic>> verifyBiometric({
    required String deviceId,
    required String signature,
  }) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/biometrictest/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'deviceId': deviceId, 'signature': signature}),
      );
      if (kDebugMode) {
        print('💰 Biometric verify: ${response.statusCode} ${response.body}');
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Biometric verification failed');
    } catch (e) {
      if (kDebugMode) print('❌ Verify biometric error: $e');
      rethrow;
    }
  }
}
