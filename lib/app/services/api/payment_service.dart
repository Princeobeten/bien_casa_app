import 'api_client.dart';
import 'api_config.dart';

/// PaymentService - Payment and escrow operations
class PaymentService {
  final ApiClient _apiClient;

  PaymentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ========== Payment Operations ==========

  /// Initiate payment
  Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> paymentData) async {
    final response = await _apiClient.post(
      '${ApiConfig.payments}/initiate',
      body: paymentData,
    );
    return response['data'];
  }

  /// Verify payment
  Future<Map<String, dynamic>> verifyPayment(String paymentReference) async {
    final response = await _apiClient.get(
      '${ApiConfig.payments}/verify/$paymentReference',
    );
    return response['data'];
  }

  /// Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory({
    String? userId,
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (userId != null) queryParams['userId'] = userId;
    if (type != null) queryParams['type'] = type;

    final response = await _apiClient.get(
      ApiConfig.payments,
      queryParams: queryParams,
    );

    return List<Map<String, dynamic>>.from(response['data']);
  }

  // ========== Escrow Operations ==========

  /// Get escrow balance
  Future<Map<String, dynamic>> getEscrowBalance(String userId) async {
    final response = await _apiClient.get(
      '${ApiConfig.escrow}/balance',
      queryParams: {'userId': userId},
    );
    return response['data'];
  }

  /// Hold amount in escrow
  Future<Map<String, dynamic>> holdInEscrow(Map<String, dynamic> escrowData) async {
    final response = await _apiClient.post(
      '${ApiConfig.escrow}/hold',
      body: escrowData,
    );
    return response['data'];
  }

  /// Release escrow
  Future<Map<String, dynamic>> releaseEscrow(String escrowId) async {
    final response = await _apiClient.post(
      '${ApiConfig.escrow}/release/$escrowId',
    );
    return response['data'];
  }

  /// Refund escrow
  Future<Map<String, dynamic>> refundEscrow(String escrowId) async {
    final response = await _apiClient.post(
      '${ApiConfig.escrow}/refund/$escrowId',
    );
    return response['data'];
  }

  /// Get escrow transactions
  Future<List<Map<String, dynamic>>> getEscrowTransactions({
    String? userId,
    String? purpose,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (userId != null) queryParams['userId'] = userId;
    if (purpose != null) queryParams['purpose'] = purpose;

    final response = await _apiClient.get(
      ApiConfig.escrow,
      queryParams: queryParams,
    );

    return List<Map<String, dynamic>>.from(response['data']);
  }

  // ========== Wallet Operations ==========

  /// Get wallet balance
  Future<Map<String, dynamic>> getWalletBalance(String userId) async {
    final response = await _apiClient.get(
      '${ApiConfig.wallet}/balance',
      queryParams: {'userId': userId},
    );
    return response['data'];
  }

  /// Add funds to wallet
  Future<Map<String, dynamic>> addFundsToWallet(Map<String, dynamic> fundsData) async {
    final response = await _apiClient.post(
      '${ApiConfig.wallet}/add-funds',
      body: fundsData,
    );
    return response['data'];
  }

  /// Withdraw from wallet
  Future<Map<String, dynamic>> withdrawFromWallet(Map<String, dynamic> withdrawalData) async {
    final response = await _apiClient.post(
      '${ApiConfig.wallet}/withdraw',
      body: withdrawalData,
    );
    return response['data'];
  }

  /// Get wallet transactions
  Future<List<Map<String, dynamic>>> getWalletTransactions({
    String? userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (userId != null) queryParams['userId'] = userId;

    final response = await _apiClient.get(
      ApiConfig.wallet,
      queryParams: queryParams,
    );

    return List<Map<String, dynamic>>.from(response['data']);
  }

  // ========== Campaign Wallet Operations ==========

  /// Get campaign wallet balance
  Future<Map<String, dynamic>> getCampaignWalletBalance(String campaignId) async {
    final response = await _apiClient.get(
      '${ApiConfig.wallet}/campaign/$campaignId/balance',
    );
    return response['data'];
  }

  /// Transfer from campaign wallet
  Future<Map<String, dynamic>> transferFromCampaignWallet(
    String campaignId,
    Map<String, dynamic> transferData,
  ) async {
    final response = await _apiClient.post(
      '${ApiConfig.wallet}/campaign/$campaignId/transfer',
      body: transferData,
    );
    return response['data'];
  }
}
