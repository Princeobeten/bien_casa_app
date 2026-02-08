import 'package:get/get.dart';
import '../services/api/payment_service.dart';
import '../services/api/api_exception.dart';

/// PaymentController - Manages payment and wallet operations
class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();

  // Payment history
  final RxList<Map<String, dynamic>> _paymentHistory =
      <Map<String, dynamic>>[].obs;

  // Escrow transactions
  final RxList<Map<String, dynamic>> _escrowTransactions =
      <Map<String, dynamic>>[].obs;

  // Wallet transactions
  final RxList<Map<String, dynamic>> _walletTransactions =
      <Map<String, dynamic>>[].obs;

  // Balances
  final RxDouble _walletBalance = 0.0.obs;
  final RxDouble _escrowBalance = 0.0.obs;
  final RxDouble _campaignWalletBalance = 0.0.obs;

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isProcessingPayment = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<Map<String, dynamic>> get paymentHistory => _paymentHistory;
  List<Map<String, dynamic>> get escrowTransactions => _escrowTransactions;
  List<Map<String, dynamic>> get walletTransactions => _walletTransactions;
  double get walletBalance => _walletBalance.value;
  double get escrowBalance => _escrowBalance.value;
  double get campaignWalletBalance => _campaignWalletBalance.value;
  bool get isLoading => _isLoading.value;
  bool get isProcessingPayment => _isProcessingPayment.value;
  String get errorMessage => _errorMessage.value;

  // ========== Payment Operations ==========

  /// Initiate payment
  Future<Map<String, dynamic>?> initiatePayment(
    Map<String, dynamic> paymentData,
  ) async {
    try {
      _isProcessingPayment.value = true;
      _errorMessage.value = '';
      final result = await _paymentService.initiatePayment(paymentData);
      Get.snackbar(
        'Success',
        'Payment initiated',
        snackPosition: SnackPosition.TOP,
      );
      return result;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return null;
    } finally {
      _isProcessingPayment.value = false;
    }
  }

  /// Verify payment
  Future<Map<String, dynamic>?> verifyPayment(String paymentReference) async {
    try {
      _isProcessingPayment.value = true;
      _errorMessage.value = '';
      final result = await _paymentService.verifyPayment(paymentReference);
      return result;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return null;
    } finally {
      _isProcessingPayment.value = false;
    }
  }

  /// Fetch payment history
  Future<void> fetchPaymentHistory(String userId, {String? type}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final history = await _paymentService.getPaymentHistory(
        userId: userId,
        type: type,
      );
      _paymentHistory.assignAll(history);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  // ========== Escrow Operations ==========

  /// Fetch escrow balance
  Future<void> fetchEscrowBalance(String userId) async {
    try {
      _errorMessage.value = '';
      final result = await _paymentService.getEscrowBalance(userId);
      _escrowBalance.value = (result['balance'] as num?)?.toDouble() ?? 0.0;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
    }
  }

  /// Hold amount in escrow
  Future<bool> holdInEscrow(Map<String, dynamic> escrowData) async {
    try {
      _isProcessingPayment.value = true;
      _errorMessage.value = '';
      await _paymentService.holdInEscrow(escrowData);
      Get.snackbar(
        'Success',
        'Amount held in escrow',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isProcessingPayment.value = false;
    }
  }

  /// Release escrow
  Future<bool> releaseEscrow(String escrowId) async {
    try {
      _isProcessingPayment.value = true;
      _errorMessage.value = '';
      await _paymentService.releaseEscrow(escrowId);
      Get.snackbar(
        'Success',
        'Escrow released',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isProcessingPayment.value = false;
    }
  }

  /// Refund escrow
  Future<bool> refundEscrow(String escrowId) async {
    try {
      _isProcessingPayment.value = true;
      _errorMessage.value = '';
      await _paymentService.refundEscrow(escrowId);
      Get.snackbar(
        'Success',
        'Escrow refunded',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isProcessingPayment.value = false;
    }
  }

  /// Fetch escrow transactions
  Future<void> fetchEscrowTransactions(String userId, {String? purpose}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final transactions = await _paymentService.getEscrowTransactions(
        userId: userId,
        purpose: purpose,
      );
      _escrowTransactions.assignAll(transactions);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  // ========== Wallet Operations ==========

  /// Fetch wallet balance
  Future<void> fetchWalletBalance(String userId) async {
    try {
      _errorMessage.value = '';
      final result = await _paymentService.getWalletBalance(userId);
      _walletBalance.value = (result['balance'] as num?)?.toDouble() ?? 0.0;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
    }
  }

  /// Add funds to wallet
  Future<bool> addFundsToWallet(Map<String, dynamic> fundsData) async {
    try {
      _isProcessingPayment.value = true;
      _errorMessage.value = '';
      await _paymentService.addFundsToWallet(fundsData);
      Get.snackbar(
        'Success',
        'Funds added to wallet',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isProcessingPayment.value = false;
    }
  }

  /// Withdraw from wallet
  Future<bool> withdrawFromWallet(Map<String, dynamic> withdrawalData) async {
    try {
      _isProcessingPayment.value = true;
      _errorMessage.value = '';
      await _paymentService.withdrawFromWallet(withdrawalData);
      Get.snackbar(
        'Success',
        'Withdrawal initiated',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isProcessingPayment.value = false;
    }
  }

  /// Fetch wallet transactions
  Future<void> fetchWalletTransactions(String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final transactions = await _paymentService.getWalletTransactions(
        userId: userId,
      );
      _walletTransactions.assignAll(transactions);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  // ========== Campaign Wallet Operations ==========

  /// Fetch campaign wallet balance
  Future<void> fetchCampaignWalletBalance(String campaignId) async {
    try {
      _errorMessage.value = '';
      final result = await _paymentService.getCampaignWalletBalance(campaignId);
      _campaignWalletBalance.value =
          (result['balance'] as num?)?.toDouble() ?? 0.0;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
    }
  }

  /// Transfer from campaign wallet
  Future<bool> transferFromCampaignWallet(
    String campaignId,
    Map<String, dynamic> transferData,
  ) async {
    try {
      _isProcessingPayment.value = true;
      _errorMessage.value = '';
      await _paymentService.transferFromCampaignWallet(
        campaignId,
        transferData,
      );
      Get.snackbar(
        'Success',
        'Transfer completed',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isProcessingPayment.value = false;
    }
  }

  /// Refresh all balances
  Future<void> refreshBalances(String userId, {String? campaignId}) async {
    await fetchWalletBalance(userId);
    await fetchEscrowBalance(userId);
    if (campaignId != null) {
      await fetchCampaignWalletBalance(campaignId);
    }
  }
}
