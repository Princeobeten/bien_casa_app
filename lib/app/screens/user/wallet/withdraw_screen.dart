import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../services/wallet_service.dart';
import '../../../services/biometric_service.dart';
import '../../../data/nigerian_banks.dart';
import 'withdrawal_status_screen.dart';

const Color _accentColor = Color(0xFF1ABC9C);

class WithdrawScreen extends StatefulWidget {
  final double? availableBalance;

  const WithdrawScreen({super.key, this.availableBalance});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();
  final _bankSearchController = TextEditingController();

  String? _selectedBankCode;
  String? _selectedBankName;
  String? _validatedAccountName;
  bool _isProcessing = false;
  bool _isValidatingAccount = false;
  List<Map<String, dynamic>> _banks = [];
  List<Map<String, dynamic>> _filteredBanks = [];

  // Fee calculation
  Map<String, dynamic>? _feeData;
  bool _feeLoading = false;
  String? _feeError;
  Timer? _feeDebounce;

  @override
  void initState() {
    super.initState();
    _loadBanks();
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
        _feeLoading = false;
      });
      return;
    }
    setState(() {
      _feeData = null;
      _feeLoading = true;
      _feeError = null;
    });
    _feeDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _fetchFee(amount),
    );
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
      final rawData = response['data'];
      Map<String, dynamic>? feeData;
      if (rawData is Map<String, dynamic>) {
        feeData = Map<String, dynamic>.from(rawData);
        final fee = _readFeeFromResponse(feeData);
        if (fee != null) feeData['fee'] = fee;
      }
      setState(() {
        _feeData = feeData;
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

  num? _readFeeFromResponse(Map<String, dynamic> data) {
    if (data['fee'] != null) return _safeNum(data['fee']);
    if (data['feeAmount'] != null) return _safeNum(data['feeAmount']);
    final breakdown = data['breakdown'];
    if (breakdown is Map<String, dynamic>) {
      if (breakdown['totalFee'] != null) return _safeNum(breakdown['totalFee']);
      if (breakdown['fee'] != null) return _safeNum(breakdown['fee']);
    }
    return null;
  }

  void _ensureFeeForReview() {
    final text = _amountController.text.replaceAll(',', '');
    final amount = num.tryParse(text);
    if (amount != null && amount > 0 && _feeData == null && !_feeLoading) {
      _fetchFee(amount);
    }
  }

  Future<void> _loadBanks() async {
    try {
      final response = await WalletService.getBanks();
      if (response['data'] != null && response['data'] is List) {
        final banksList = List<Map<String, dynamic>>.from(response['data']);
        if (banksList.isNotEmpty) {
          setState(() {
            _banks = banksList;
            _filteredBanks = banksList;
          });
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading banks: $e');
    }
    setState(() {
      _banks = List<Map<String, dynamic>>.from(NigerianBanks.banks);
      _filteredBanks = _banks;
    });
  }

  Future<void> _validateAccount() async {
    if (_selectedBankCode == null || _accountNumberController.text.isEmpty)
      return;

    setState(() => _isValidatingAccount = true);

    try {
      final response = await WalletService.validateAccountName(
        accountNumber: _accountNumberController.text,
        bankCode: _selectedBankCode!,
      );

      final isSuccess =
          response['status'] == true || response['success'] == true;
      final accountName = response['name'] ?? '';

      if (isSuccess && accountName.isNotEmpty) {
        setState(() => _validatedAccountName = accountName);
      }
    } catch (e) {
      if (kDebugMode) print('Validation error: $e');
    } finally {
      setState(() => _isValidatingAccount = false);
    }
  }

  void _filterBanks(String query) {
    if (query.isEmpty) {
      setState(() => _filteredBanks = _banks);
    } else {
      setState(() {
        _filteredBanks =
            _banks.where((bank) {
              final bankName =
                  (bank['bname'] ?? bank['name'] ?? '')
                      .toString()
                      .toLowerCase();
              return bankName.contains(query.toLowerCase());
            }).toList();
      });
    }
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
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
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _currentStep = 2);
      _ensureFeeForReview();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Get.back();
    }
  }

  Future<void> _processWithdraw() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate())
      return;
    if (_selectedBankCode == null || _selectedBankCode!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a bank',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final cleanAmount = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(cleanAmount);

    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Invalid amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    _showPaymentConfirmationSheet(amount);
  }

  void _showPaymentConfirmationSheet(double amount) {
    final pinController = TextEditingController();
    final submittingNotifier = ValueNotifier<bool>(false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => FutureBuilder<bool>(
            future: () async {
              final canUse = await BiometricService.canCheckBiometrics();
              final enabled = await BiometricService.isBiometricEnabled();
              return canUse && enabled;
            }(),
            builder: (context, snapshot) {
              final showBiometric = snapshot.data == true;
              return StatefulBuilder(
                builder: (context, setModalState) {
                  return _buildPinSheetContent(
                    amount: amount,
                    pinController: pinController,
                    showBiometric: showBiometric,
                    setModalState: setModalState,
                    submittingNotifier: submittingNotifier,
                  );
                },
              );
            },
          ),
    );
  }

  bool _biometricSheetProcessing = false;

  Widget _buildPinSheetContent({
    required double amount,
    required TextEditingController pinController,
    required bool showBiometric,
    required void Function(void Function()) setModalState,
    required ValueNotifier<bool> submittingNotifier,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: submittingNotifier,
      builder: (context, isSubmitting, _) {
        if (isSubmitting) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: _accentColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Processing withdrawal…',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ProductSans',
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    const Text(
                      'Confirm Withdrawal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '₦${_formatCurrency(amount.toStringAsFixed(2))}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ProductSans',
                ),
              ),
              const SizedBox(height: 24),
              if (showBiometric) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _biometricSheetProcessing
                              ? null
                              : () => _useBiometricToWithdraw(
                                amount,
                                setModalState,
                                submittingNotifier,
                              ),
                      icon:
                          _biometricSheetProcessing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.fingerprint, size: 24),
                      label: Text(
                        _biometricSheetProcessing
                            ? 'Verifying…'
                            : 'Use Biometric',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _accentColor,
                        side: const BorderSide(color: _accentColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Or enter your PIN',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: 'ProductSans',
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // PIN Input Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              index < pinController.text.length
                                  ? _accentColor
                                  : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          index < pinController.text.length ? '•' : '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 12),
              // Numeric Keypad (compact)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.0,
                  children: [
                    ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) {
                      return _buildPinButton(
                        label: num.toString(),
                        onTap: () {
                          if (pinController.text.length < 4) {
                            setModalState(() {
                              pinController.text += num.toString();
                            });
                            if (pinController.text.length == 4) {
                              submittingNotifier.value = true;
                              _submitWithdrawal(
                                amount,
                                pinController.text,
                                submittingNotifier,
                              );
                            }
                          }
                        },
                      );
                    }),
                    _buildPinButton(
                      label: '0',
                      onTap: () {
                        if (pinController.text.length < 4) {
                          setModalState(() {
                            pinController.text += '0';
                          });
                          if (pinController.text.length == 4) {
                            submittingNotifier.value = true;
                            _submitWithdrawal(
                              amount,
                              pinController.text,
                              submittingNotifier,
                            );
                          }
                        }
                      },
                    ),
                    _buildPinButton(
                      label: '⌫',
                      icon: Icons.backspace_outlined,
                      onTap: () {
                        if (pinController.text.isNotEmpty) {
                          setModalState(() {
                            pinController.text = pinController.text.substring(
                              0,
                              pinController.text.length - 1,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinButton({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child:
              icon != null
                  ? Icon(icon, size: 22, color: Colors.grey[700])
                  : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                    ),
                  ),
        ),
      ),
    );
  }

  Future<void> _useBiometricToWithdraw(
    double amount,
    void Function(void Function()) setModalState,
    ValueNotifier<bool> submittingNotifier,
  ) async {
    setModalState(() => _biometricSheetProcessing = true);
    try {
      final authenticated = await BiometricService.authenticateWithBiometric(
        reason: 'Verify your identity to approve this withdrawal',
      );
      if (!authenticated) {
        setModalState(() => _biometricSheetProcessing = false);
        Get.snackbar(
          'Cancelled',
          'Biometric is required to continue',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      final valid = await BiometricService.verifyBiometricForTransaction();
      if (!valid) {
        setModalState(() => _biometricSheetProcessing = false);
        Get.snackbar(
          'Verification failed',
          'Please try again or use your PIN',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      submittingNotifier.value = true;
      await _submitWithdrawal(amount, '', submittingNotifier);
      setModalState(() => _biometricSheetProcessing = false);
    } catch (e) {
      setModalState(() => _biometricSheetProcessing = false);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitWithdrawal(
    double amount,
    String pin,
    ValueNotifier<bool> submittingNotifier,
  ) async {
    setState(() => _isProcessing = true);

    try {
      final response = await WalletService.transferToExternal(
        accountNumber: _accountNumberController.text,
        bankCode: _selectedBankCode!,
        amount: amount,
        narration:
            _narrationController.text.isNotEmpty
                ? _narrationController.text
                : 'Withdrawal to external account',
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);
      submittingNotifier.value = false;
      Get.back();

      final statusStr =
          (response['data'] is Map ? (response['data'] as Map)['status'] : null)
              as String?;
      final message =
          (response['message'] as String?) ??
          (response['data'] is Map
              ? (response['data'] as Map)['message'] as String?
              : null) ??
          'Withdrawal initiated successfully';
      final ref =
          response['data'] is Map
              ? (response['data'] as Map)['reference'] as String?
              : null;

      WithdrawalStatus status = WithdrawalStatus.success;
      if (statusStr != null) {
        switch (statusStr.toLowerCase()) {
          case 'pending':
            status = WithdrawalStatus.pending;
            break;
          case 'failed':
            status = WithdrawalStatus.failed;
            break;
          default:
            status = WithdrawalStatus.success;
        }
      }

      Get.to(
        () => WithdrawalStatusScreen(
          status: status,
          message: message,
          amount: amount,
          reference: ref,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      submittingNotifier.value = false;
      Get.back();

      Get.to(
        () => WithdrawalStatusScreen(
          status: WithdrawalStatus.failed,
          message: e.toString().replaceAll('Exception: ', ''),
          amount: amount,
        ),
      );
    }
  }

  Widget _buildNairaSymbol({double size = 16, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/naira.svg',
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final cleanValue = value.replaceAll(',', '');
    final amount = double.tryParse(cleanValue);
    if (amount == null) return value;
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatNairaNum(num value) {
    return '₦${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  num _safeNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is int) return value.toDouble();
    final n = num.tryParse(value.toString());
    return n ?? 0;
  }

  @override
  void dispose() {
    _feeDebounce?.cancel();
    _amountController.removeListener(_onAmountChanged);
    _accountNumberController.dispose();
    _amountController.dispose();
    _narrationController.dispose();
    _bankSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: _goToPreviousStep,
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 24,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Transfer To Bank Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontFamily: 'ProductSans',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentStep == 0) _buildRecipientStep(),
            if (_currentStep == 1) _buildAmountStep(),
            if (_currentStep == 2) _buildReviewStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientStep() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recipient Account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'ProductSans',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Account Number Input
          TextFormField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              hintText: 'Enter account number',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                fontFamily: 'ProductSans',
                fontSize: 14,
              ),
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[100]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[100]!, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            onChanged: (_) {
              setState(() => _validatedAccountName = null);
              if (_accountNumberController.text.length == 10 &&
                  _selectedBankCode != null) {
                _validateAccount();
              }
            },
          ),
          const SizedBox(height: 20),
          // Bank Selection
          GestureDetector(
            onTap: () => _showBankPicker(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Row(
                children: [
                  if (_selectedBankName != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildBankLogoWidget(_selectedBankName!),
                    ),
                  Expanded(
                    child: Text(
                      _selectedBankName ?? 'Select Bank',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w400,
                        color:
                            _selectedBankName != null
                                ? Colors.black
                                : Colors.grey,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Validated Account Name or Loading State
          if (_isValidatingAccount)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[600]!,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Validating account...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ],
              ),
            )
          else if (_validatedAccountName != null &&
              _validatedAccountName!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 20, color: _accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validatedAccountName!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _accentColor,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          // Next Button - Disabled until validated
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_validatedAccountName != null &&
                          _validatedAccountName!.isNotEmpty)
                      ? _goToNextStep
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountStep() {
    // When amount step is visible with an amount but no fee yet, trigger fee fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentStep != 1) return;
      final amount = num.tryParse(_amountController.text.replaceAll(',', ''));
      if (amount != null && amount > 0 && _feeData == null && !_feeLoading) {
        _fetchFee(amount);
      }
    });
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank Info Section (no background, just content)
          Row(
            children: [
              _buildBankLogoWidget(_selectedBankName ?? ''),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _validatedAccountName ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'ProductSans',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_accountNumberController.text} ${_selectedBankName ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ProductSans',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Amount Section with white background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ProductSans',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // Amount Input Field
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    _CurrencyInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '100.00-5,000,000.00',
                    hintStyle: TextStyle(
                      color: Colors.grey[300],
                      fontFamily: 'ProductSans',
                      fontSize: 14,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildNairaSymbol(size: 18, color: Colors.black),
                    ),
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[100]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[100]!,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Amount required';
                    final amount = double.tryParse(value.replaceAll(',', ''));
                    if (amount == null || amount <= 0)
                      return 'Enter a valid amount';
                    if (widget.availableBalance != null &&
                        amount > widget.availableBalance!)
                      return 'Insufficient balance';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quick Amount Buttons
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.8,
                  children: [
                    _buildQuickAmountButton('500'),
                    _buildQuickAmountButton('1,000'),
                    _buildQuickAmountButton('2,000'),
                    _buildQuickAmountButton('5,000'),
                    _buildQuickAmountButton('9,999'),
                    _buildQuickAmountButton('10,000'),
                  ],
                ),

                // Fee (single line below suggested amounts)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fee',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    if (_feeLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accentColor,
                        ),
                      )
                    else if (_feeError != null)
                      Text(
                        _feeError!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red[700],
                          fontFamily: 'ProductSans',
                        ),
                      )
                    else if (_feeData != null)
                      Text(
                        _formatNairaNum(_safeNum(_feeData!['fee'])),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _accentColor,
                          fontFamily: 'ProductSans',
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Remark Section with white background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remark',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ProductSans',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // Remark Input
                TextFormField(
                  controller: _narrationController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "What's this for? (Optional)",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'ProductSans',
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[100]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[100]!,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Category Buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildCategoryButton('Purchase', 'purchase'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCategoryButton('Personal', 'personal'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildCategoryButton('POS', 'pos')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCategoryButton('Loan', 'loan')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCategoryButton('Food', 'food')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirm Button - disabled until fee is calculated
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_feeData != null && !_feeLoading && _feeError == null)
                      ? _goToNextStep
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return GestureDetector(
      onTap: () {
        final cleanAmount = amount.replaceAll(',', '');
        final parsed = num.tryParse(cleanAmount);
        final formatted = _formatCurrency(cleanAmount);
        _amountController.text = formatted;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'ProductSans',
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String label, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _narrationController.text = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'ProductSans',
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reminder Section
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Reminder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'ProductSans',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please verify all transfer information carefully before proceeding. Note that completed transfers are final and cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'ProductSans',
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Transaction Details Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'ProductSans',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _formatNairaNum(
                    _safeNum(_amountController.text.replaceAll(',', '')) +
                        (_feeData != null ? _safeNum(_feeData!['fee']) : 0),
                  ),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ProductSans',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildReviewRow('Name', _validatedAccountName ?? ''),
              const SizedBox(height: 12),
              _buildReviewRow('Account No.', _accountNumberController.text),
              const SizedBox(height: 12),
              _buildReviewRow('Bank', _selectedBankName ?? ''),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  Row(
                    children: [
                      _buildNairaSymbol(size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        _formatCurrency(_amountController.text),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_feeLoading) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fee',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ],
              if (_feeData != null && !_feeLoading) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fee',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    Text(
                      _formatNairaNum(_safeNum(_feeData!['fee'])),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentStep = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Recheck',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'ProductSans',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _isProcessing ? null : _processWithdraw,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child:
                        _isProcessing
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'ProductSans',
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontFamily: 'ProductSans',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            fontFamily: 'ProductSans',
          ),
        ),
      ],
    );
  }

  Widget _buildBankLogoWidget(String bankName) {
    final logoUrl = NigerianBanks.getBankLogo(bankName);

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          logoUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  NigerianBanks.getBankInitials(bankName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _accentColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          NigerianBanks.getBankInitials(bankName),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showBankPicker() {
    _bankSearchController.clear();
    _filteredBanks = _banks;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Select Bank',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'ProductSans',
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _bankSearchController,
                            onChanged: (value) {
                              setModalState(() {
                                _filterBanks(value);
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search Bank Name',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontFamily: 'ProductSans',
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child:
                              _filteredBanks.isEmpty
                                  ? Center(
                                    child: Text(
                                      'No banks found',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontFamily: 'ProductSans',
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    itemCount: _filteredBanks.length,
                                    itemBuilder: (context, index) {
                                      final bank = _filteredBanks[index];
                                      final bankCode =
                                          bank['code']?.toString() ?? '';
                                      final bankName =
                                          (bank['bname'] ??
                                                  bank['name'] ??
                                                  'Unknown Bank')
                                              .toString();

                                      return ListTile(
                                        onTap: () {
                                          setState(() {
                                            _selectedBankCode = bankCode;
                                            _selectedBankName = bankName;
                                            _validatedAccountName = null;
                                          });
                                          if (_accountNumberController
                                                  .text
                                                  .length ==
                                              10) {
                                            _validateAccount();
                                          }
                                          Get.back();
                                        },
                                        leading: _buildBankLogoWidget(bankName),
                                        title: Text(
                                          bankName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'ProductSans',
                                          ),
                                        ),
                                        trailing:
                                            _selectedBankCode == bankCode
                                                ? const Icon(
                                                  Icons.check,
                                                  color: _accentColor,
                                                )
                                                : null,
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll(',', '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final parts = text.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final formatted = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    final result = formatted + decimalPart;

    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
