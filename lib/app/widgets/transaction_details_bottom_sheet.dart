import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/wallet_service.dart';
import '../data/nigerian_banks.dart';

class TransactionDetailsBottomSheet extends StatefulWidget {
  final String transactionId;
  final Map<String, dynamic>? initialData;

  const TransactionDetailsBottomSheet({
    super.key,
    required this.transactionId,
    this.initialData,
  });

  @override
  State<TransactionDetailsBottomSheet> createState() => _TransactionDetailsBottomSheetState();
}

class _TransactionDetailsBottomSheetState extends State<TransactionDetailsBottomSheet> {
  Map<String, dynamic>? _transactionData;
  bool _isLoading = true;
  String? _error;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    // Always fetch from API, don't show initial data immediately
    setState(() => _isLoading = true);
    
    try {
      final response = await WalletService.getTransactionById(widget.transactionId);
      
      if (response['data'] != null) {
        setState(() {
          _transactionData = response['data'];
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Transaction not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading transaction: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Widget _buildNairaSymbol({double size = 16, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/naira.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'successful':
      case 'completed':
      case 'success':
        return Colors.green[600]!;
      case 'pending':
        return Colors.orange[600]!;
      case 'failed':
      case 'failure':
        return Colors.red[600]!;
      default:
        return Colors.green[600]!;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'successful':
      case 'success':
        return 'Successful';
      case 'completed':
        return 'Successful';
      case 'pending':
        return 'Pending';
      case 'failed':
      case 'failure':
        return 'Failed';
      default:
        return 'Successful';
    }
  }

  bool _isCredit(Map<String, dynamic> transaction) {
    final amount = transaction['amount'];
    if (amount is num) {
      return amount > 0;
    }
    
    final direction = transaction['direction']?.toString().toLowerCase();
    final transactionType = transaction['transactionType']?.toString().toLowerCase() ?? 
                           transaction['type']?.toString().toLowerCase();
    return direction == 'credit' || transactionType == 'deposit' || transactionType == 'credit';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'pm' : 'am';
      return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _shareReceipt(Map<String, dynamic> transaction) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        barrierDismissible: false,
      );

      final image = await _screenshotController.capture();
      
      if (image == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Failed to capture receipt image',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
        return;
      }

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      Get.back();

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Transaction Receipt - Bien Casa Wallet',
      );

      Future.delayed(const Duration(seconds: 5), () {
        try {
          if (imageFile.existsSync()) {
            imageFile.deleteSync();
          }
        } catch (e) {
          print('Error cleaning up temp file: $e');
        }
      });
    } catch (e) {
      Get.back();
      print('❌ Error sharing receipt: $e');
      Get.snackbar(
        'Error',
        'Failed to share receipt: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, size: 20, color: Colors.black),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_transactionData != null)
                  GestureDetector(
                    onTap: () => _shareReceipt(_transactionData!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share, size: 16, color: Colors.black),
                          SizedBox(width: 4),
                          Text(
                            'Share Receipt',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'ProductSans',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 100), // Placeholder for alignment
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : _error != null
                    ? _buildErrorState()
                    : Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          color: Colors.grey[200],
                          child: _buildTransactionContent(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'ProductSans',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTransactionDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionContent() {
    if (_transactionData == null) return const SizedBox.shrink();

    final transaction = _transactionData!;
    final amount = double.tryParse(transaction['amount']?.toString() ?? '0')?.abs() ?? 0.0;
    final isCredit = _isCredit(transaction);
    
    // Extract all fields
    final transactionType = transaction['transactionType']?.toString() ?? 
                           transaction['type']?.toString() ?? '';
    final direction = transaction['direction']?.toString() ?? '';
    final status = transaction['status']?.toString() ?? '';
    final description = transaction['description']?.toString() ?? '';
    final narration = transaction['narration']?.toString() ?? '';
    final reference = transaction['reference']?.toString() ?? '';
    final createdAt = transaction['createdAt']?.toString() ?? '';
    final linkedEntityType = transaction['linkedEntityType']?.toString() ?? '';
    final linkedEntityId = transaction['linkedEntityId']?.toString() ?? '';
    
    // Source details
    final sourceDetails = transaction['sourceAccountDetails'];
    final sourceBankName = sourceDetails?['bankName']?.toString() ?? '';
    final sourceAccountName = sourceDetails?['accountName']?.toString() ?? '';
    final sourceAccountNumber = sourceDetails?['accountNumber']?.toString() ?? '';
    
    // Destination details
    final destinationDetails = transaction['destinationAccountDetails'];
    final destBankName = destinationDetails?['bankName']?.toString() ?? '';
    final destAccountName = destinationDetails?['accountName']?.toString() ?? '';
    final destAccountNumber = destinationDetails?['accountNumber']?.toString() ?? '';
    final destBankCode = destinationDetails?['bankCode']?.toString() ?? '';
    
    // Get bank name for initials (use source for credit, destination for debit)
    final bankName = isCredit ? sourceBankName : destBankName;
    final accountName = isCredit ? sourceAccountName : destAccountName;
    
    // Title
    String title;
    if (transaction['title'] != null) {
      title = transaction['title'];
    } else if (description.isNotEmpty) {
      title = description;
    } else if (transactionType.toLowerCase() == 'deposit' && sourceAccountName.isNotEmpty) {
      title = 'Received from $sourceAccountName';
    } else if (transactionType.toLowerCase() == 'withdrawal') {
      title = 'Withdrawal to $destAccountName';
    } else {
      title = transaction['subtitle'] ?? 'Transaction';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Transaction Overview Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Profile Icon with Bank Logo or Initials
                _buildBankIcon(bankName, accountName, isCredit),
                const SizedBox(height: 20),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ProductSans',
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildNairaSymbol(size: 32, color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      amount.toStringAsFixed(2).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ProductSans',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: _getStatusColor(status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(status),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transaction Details Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ProductSans',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Reference Number (use 'reference' field, not 'id')
                if (reference.isNotEmpty)
                  _buildDetailRowWithCopy('Reference Number', reference),
                
                // Transaction Type
                if (transactionType.isNotEmpty)
                  _buildDetailRow('Transaction Type', transactionType.toUpperCase()),
                
                // Direction
                if (direction.isNotEmpty)
                  _buildDetailRow('Direction', direction.toUpperCase()),
                
                // Status
                if (status.isNotEmpty)
                  _buildDetailRow('Status', status),
                
                // Transaction Date & Time
                if (createdAt.isNotEmpty)
                  _buildDetailRow('Date & Time', 
                    '${_formatDate(createdAt)}, ${_formatTime(createdAt)}'),
                
                // Description
                if (description.isNotEmpty)
                  _buildDetailRow('Description', description),
                
                // Narration
                if (narration.isNotEmpty)
                  _buildDetailRow('Narration', narration),
                
                // Linked Entity
                if (linkedEntityType.isNotEmpty)
                  _buildDetailRow('Linked Entity Type', linkedEntityType),
                
                if (linkedEntityId.isNotEmpty)
                  _buildDetailRow('Linked Entity ID', linkedEntityId),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Source Account Section
          if (sourceAccountName.isNotEmpty || sourceAccountNumber.isNotEmpty || sourceBankName.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Source Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (sourceAccountName.isNotEmpty)
                    _buildDetailRow('Account Name', sourceAccountName),
                  
                  if (sourceAccountNumber.isNotEmpty)
                    _buildDetailRowWithCopy('Account Number', sourceAccountNumber),
                  
                  if (sourceBankName.isNotEmpty)
                    _buildDetailRow('Bank Name', sourceBankName),
                ],
              ),
            ),
          
          if (sourceAccountName.isNotEmpty || sourceAccountNumber.isNotEmpty || sourceBankName.isNotEmpty)
            const SizedBox(height: 16),

          // Destination Account Section
          if (destAccountName.isNotEmpty || destAccountNumber.isNotEmpty || destBankName.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Destination Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (destAccountName.isNotEmpty)
                    _buildDetailRow('Account Name', destAccountName),
                  
                  if (destAccountNumber.isNotEmpty)
                    _buildDetailRowWithCopy('Account Number', destAccountNumber),
                  
                  if (destBankName.isNotEmpty)
                    _buildDetailRow('Bank Name', destBankName),
                  
                  // if (destBankCode.isNotEmpty)
                  //   _buildDetailRow('Bank Code', destBankCode),
                ],
              ),
            ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getBankInitials(String name) {
    return NigerianBanks.getBankInitials(name);
  }

  Widget _buildBankIcon(String bankName, String accountName, bool isCredit) {
    final logoUrl = NigerianBanks.getBankLogo(bankName);
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: (isCredit ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: logoUrl != null
          ? ClipOval(
              child: Image.network(
                logoUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to initials if image fails to load
                  return Center(
                    child: Text(
                      _getBankInitials(bankName.isNotEmpty ? bankName : accountName),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? Colors.green[700] : Colors.orange[700],
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: isCredit ? Colors.green[700] : Colors.orange[700],
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                _getBankInitials(bankName.isNotEmpty ? bankName : accountName),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green[700] : Colors.orange[700],
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'ProductSans',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontFamily: 'ProductSans',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithCopy(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'ProductSans',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'ProductSans',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    Get.snackbar(
                      'Copied',
                      'Transaction number copied to clipboard',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(10),
                    );
                  },
                  child: Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
