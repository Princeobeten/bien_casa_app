import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/wallet_service.dart';

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedDestination = 'quinance';
  final double _availableBalance = 18500.00;
  bool _showAddBankSheet = false;

  // Fee calculation
  Map<String, dynamic>? _feeData;
  bool _feeLoading = false;
  String? _feeError;
  Timer? _feeDebounce;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    _feeDebounce?.cancel();
    final text = _amountController.text.replaceAll(',', '');
    final amount = num.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() {
        _feeData = null;
        _feeError = null;
      });
      return;
    }
    _feeDebounce = Timer(const Duration(milliseconds: 500), () => _fetchFee(amount));
  }

  Future<void> _fetchFee(num amount) async {
    if (!mounted) return;
    setState(() {
      _feeLoading = true;
      _feeError = null;
    });
    try {
      final response = await WalletService.calculateFee(amount);
      if (!mounted) return;
      setState(() {
        _feeData = response['data'] as Map<String, dynamic>?;
        _feeLoading = false;
        _feeError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _feeData = null;
        _feeLoading = false;
        _feeError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  String _formatNaira(num value) {
    final n = value is int ? value.toDouble() : value;
    return '₦${n.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}';
  }

  Widget _buildFeeRow(String label, dynamic value, {bool isTotal = false}) {
    final num n = value is int ? value.toDouble() : (value as num);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontFamily: 'ProductSans',
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            _formatNaira(n),
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'ProductSans',
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _feeDebounce?.cancel();
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance
                Row(
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'ProductSans',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.remove_red_eye,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'NGN${_availableBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ProductSans',
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/wallet-add-funds'),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        label: const Text('Add Funds'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 20,
                        ),
                        label: const Text('Withdraw'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Wallet Active Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your wallet is now active',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You can now process and manage all transactions within the Bien Casa app in your wallet area with ease, powered by Quinance.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontFamily: 'ProductSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Activities Header (placeholder)
                const Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ProductSans',
                  ),
                ),
                const SizedBox(height: 100), // Space for bottom sheet
              ],
            ),
          ),

          // Withdraw Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child:
                  _showAddBankSheet
                      ? _buildAddBankSheet()
                      : _buildWithdrawSheet(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawSheet() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Withdraw Funds',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transfer money from your Bien Casa wallet to your bank account anytime. Quick, secure, & hassle-free.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 24),

          // Amount Input
          const Text(
            'Amount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'ProductSans',
            ),
            decoration: InputDecoration(
              hintText: 'NGN10,000',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 24),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
          ),
          // Fee breakdown
          if (_feeLoading) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Calculating fee...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'ProductSans',
                  ),
                ),
              ],
            ),
          ],
          if (_feeError != null && !_feeLoading) ...[
            const SizedBox(height: 16),
            Text(
              _feeError!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[700],
                fontFamily: 'ProductSans',
              ),
            ),
          ],
          if (_feeData != null && !_feeLoading) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fee breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeeRow('Amount', _feeData!['amount']),
                  if (_feeData!['breakdown'] != null) ...[
                    _buildFeeRow(
                      'Percentage fee (0.5% cap ₦1,000)',
                      (_feeData!['breakdown'] as Map)['percentageFee'],
                    ),
                    _buildFeeRow(
                      'Tiered fee',
                      (_feeData!['breakdown'] as Map)['tieredFee'],
                    ),
                  ],
                  const Divider(height: 20),
                  _buildFeeRow(
                    'Total to debit',
                    _feeData!['totalAmount'],
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Withdrawal Destination
          const Text(
            'Choose a withdrawal destination',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Quinance Wallet
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDestination = 'quinance';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          _selectedDestination == 'quinance'
                              ? const Color(0xFFE8E8FF)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _selectedDestination == 'quinance'
                                ? const Color(0xFF6366F1)
                                : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Quinance Wallet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Add Bank
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDestination = 'bank';
                      _showAddBankSheet = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Add bank',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'ProductSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_amountController.text.isNotEmpty) {
                  _confirmWithdrawal();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBankSheet() {
    final TextEditingController accountNumberController = TextEditingController(
      text: '7030588525',
    );
    final TextEditingController accountNameController = TextEditingController(
      text: 'Victor Charles Ama',
    );
    String selectedBank = 'Opay';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  setState(() {
                    _showAddBankSheet = false;
                  });
                },
              ),
              const Text(
                'Add a Bank Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ProductSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Link your bank account to withdraw funds securely from your Bien Casa wallet. Your details are safe and encrypted.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 24),

          // Bank Name
          const Text(
            'Bank Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedBank,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            items:
                ['Opay', 'First Bank', 'GTBank', 'Access Bank', 'Zenith Bank']
                    .map(
                      (bank) =>
                          DropdownMenuItem(value: bank, child: Text(bank)),
                    )
                    .toList(),
            onChanged: (value) {
              selectedBank = value!;
            },
          ),
          const SizedBox(height: 20),

          // Account Number
          const Text(
            'Account Number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: accountNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Account Name
          const Text(
            'Account Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: accountNameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ensure the name on your bank matches your profile to avoid delays.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Success',
                  'Bank account added successfully',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xff020202),
                  colorText: Colors.white,
                );
                setState(() {
                  _showAddBankSheet = false;
                  _selectedDestination = 'bank';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmWithdrawal() {
    Get.snackbar(
      'Success',
      'Withdrawal processed successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xff020202),
      colorText: Colors.white,
    );
    Get.back();
  }
}
