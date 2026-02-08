import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../services/wallet_service.dart';
import '../../../data/nigerian_banks.dart';

const Color _primaryColor = Color(0xFF26306A);

class WithdrawModal extends StatefulWidget {
  final double? availableBalance;

  const WithdrawModal({
    super.key,
    this.availableBalance,
  });

  @override
  State<WithdrawModal> createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<WithdrawModal> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();

  String? _selectedBankCode;
  String? _validatedAccountName;
  bool _isValidatingAccount = false;
  bool _isProcessing = false;
  List<Map<String, dynamic>> _banks = [];

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    try {
      // Fetch banks from backend
      final response = await WalletService.getBanks();
      
      if (kDebugMode) {
        print('💰 Banks response: $response');
      }
      
      if (response['data'] != null && response['data'] is List) {
        final banksList = List<Map<String, dynamic>>.from(response['data']);
        if (banksList.isNotEmpty) {
          if (kDebugMode) {
            print('💰 Loaded ${banksList.length} banks from backend');
          }
          setState(() {
            _banks = banksList;
          });
          return;
        }
      }
      
      if (kDebugMode) {
        print('💰 Backend banks response invalid, using local fallback');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading banks from backend: $e');
      }
    }
    
    // Fallback to local banks data
    if (kDebugMode) {
      print('💰 Using local banks data (${NigerianBanks.banks.length} banks)');
    }
    setState(() {
      _banks = List<Map<String, dynamic>>.from(NigerianBanks.banks);
    });
  }

  Future<void> _validateAccount() async {
    if (_selectedBankCode == null || _accountNumberController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a bank and enter account number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isValidatingAccount = true);

    try {
      final response = await WalletService.validateAccountName(
        accountNumber: _accountNumberController.text,
        bankCode: _selectedBankCode!,
      );

      if (kDebugMode) {
        print('💰 Validate response: $response');
      }

      // Check for success in response
      final isSuccess = response['status'] == true || response['success'] == true;
      final accountName = response['name'] ?? 
                         response['data']?['accountName'] ?? 
                         response['data']?['account_name'] ?? '';

      if (isSuccess && accountName.isNotEmpty) {
        setState(() {
          _validatedAccountName = accountName;
          _isValidatingAccount = false;
        });

        Get.snackbar(
          'Success',
          'Account validated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        setState(() => _isValidatingAccount = false);
        Get.snackbar(
          'Error',
          'Account validation failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      setState(() => _isValidatingAccount = false);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _processWithdraw() async {
    if (!_formKey.currentState!.validate()) return;
    if (_validatedAccountName == null || _validatedAccountName!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please validate account first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);

      await WalletService.transferToExternal(
        accountNumber: _accountNumberController.text,
        bankCode: _selectedBankCode!,
        amount: amount,
        narration: _narrationController.text.isNotEmpty
            ? _narrationController.text
            : 'Withdrawal to external account',
      );

      setState(() => _isProcessing = false);

      Get.snackbar(
        'Success',
        'Withdrawal initiated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    _narrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, size: 20, color: Colors.white),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Withdraw Funds',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Available Balance
                    if (widget.availableBalance != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                fontSize: 12,
                                color: _primaryColor,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildNairaSymbol(size: 20, color: _primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  widget.availableBalance!
                                      .toStringAsFixed(2)
                                      .replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => '${m[1]},',
                                      ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Bank Selection
                    Text(
                      'Select Bank',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: _banks.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                'Loading banks...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'ProductSans',
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedBankCode,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              hint: const Text(
                                'Choose a bank',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'ProductSans',
                                  color: Colors.grey,
                                ),
                              ),
                              items: _banks.map((bank) {
                                final logoUrl = bank['logo'];
                                final bankCode = bank['code']?.toString() ?? '';
                                final bankName = (bank['bname'] ?? bank['name'] ?? 'Unknown Bank').toString();
                                
                                // Skip banks with missing code
                                if (bankCode.isEmpty) return null;
                                
                                return DropdownMenuItem<String>(
                                  value: bankCode,
                                  child: SizedBox(
                                    width: Get.width * 0.7,
                                    child: Row(
                                      children: [
                                        // Bank Logo
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: _primaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: logoUrl != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Image.network(
                                                    logoUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Center(
                                                        child: Text(
                                                          NigerianBanks.getBankInitials(bankName),
                                                          style: const TextStyle(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: _primaryColor,
                                                            fontFamily: 'ProductSans',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Center(
                                                  child: Text(
                                                    NigerianBanks.getBankInitials(bankName),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: _primaryColor,
                                                      fontFamily: 'ProductSans',
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            bankName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'ProductSans',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).whereType<DropdownMenuItem<String>>().toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBankCode = value;
                                  _validatedAccountName = null;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a bank';
                                }
                                return null;
                              },
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Account Number
                    Text(
                      'Account Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _accountNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter account number',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontFamily: 'ProductSans',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _primaryColor.withValues(alpha: 0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _primaryColor.withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: _primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Account number required';
                              }
                              if (value.length < 10) {
                                return 'Invalid account number';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              setState(() => _validatedAccountName = null);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isValidatingAccount ? null : _validateAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: Colors.grey[400],
                          ),
                          child: _isValidatingAccount
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Validate',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                        ),
                      ],
                    ),

                    // Validated Account Name
                    if (_validatedAccountName != null && _validatedAccountName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _validatedAccountName!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[700],
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Amount
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'ProductSans',
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _buildNairaSymbol(size: 18, color: _primaryColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: _primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Amount required';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount';
                        }
                        if (widget.availableBalance != null &&
                            amount > widget.availableBalance!) {
                          return 'Insufficient balance';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Narration (Optional)
                    Text(
                      'Narration (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _narrationController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add a note (optional)',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'ProductSans',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: _primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Withdraw Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processWithdraw,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Withdraw',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'ProductSans',
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
