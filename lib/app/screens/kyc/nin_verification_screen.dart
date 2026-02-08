import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/kyc_controller.dart';
import '../../services/account_status_service.dart';

class NINVerificationScreen extends StatefulWidget {
  const NINVerificationScreen({super.key});

  @override
  State<NINVerificationScreen> createState() => _NINVerificationScreenState();
}

class _NINVerificationScreenState extends State<NINVerificationScreen> {
  final _ninController = TextEditingController();
  final _dobController = TextEditingController();
  final _otpControllers = List.generate(6, (index) => TextEditingController());
  final _isLoading = false.obs;
  final _isResendOtpLoading = false.obs;
  final _otpCooldownSeconds = 0.obs;
  Timer? _otpCooldownTimer;
  static const _otpCooldownDuration = 50;
  final _step = 1.obs; // 1: NIN + DOB input, 2: details + OTP confirmation
  final kycController = Get.find<KYCController>();

  Map<String, dynamic>? _ninDetails;
  Map<String, dynamic>? _matchPercentage;
  String _backendMessage = 'Please verify that these details match your NIN.';
  bool _consentChecked = false;

  @override
  void dispose() {
    _otpCooldownTimer?.cancel();
    _ninController.dispose();
    _dobController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startOtpCooldown() {
    _otpCooldownTimer?.cancel();
    _otpCooldownSeconds.value = _otpCooldownDuration;
    _otpCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCooldownSeconds.value <= 1) {
        timer.cancel();
        _otpCooldownSeconds.value = 0;
      } else {
        _otpCooldownSeconds.value--;
      }
    });
  }

  void _skipNINVerification() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Skip NIN Verification?',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'You can verify your NIN later from your profile settings.',
          style: TextStyle(fontFamily: 'ProductSans Light'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'ProductSans', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              print('🔄 Skip NIN verification button pressed');

              // Close dialog first
              Navigator.of(context).pop();
              print('✅ Dialog closed');

              // Wait a moment for dialog to close
              await Future.delayed(const Duration(milliseconds: 200));

              // Mark as skipped (completed) so user can move to next step
              kycController.ninSet.value = true;
              print('✅ ninSet set to true');

              // Show snackbar
              Get.snackbar(
                'Skipped',
                'You can verify your NIN later from your profile',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );

              // Close the NIN verification screen and return to home
              print('🔄 Closing NIN verification screen...');
              Navigator.of(context).pop(true);
              print('✅ NIN verification screen closed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(fontFamily: 'ProductSans', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyNIN() async {
    if (_ninController.text.trim().length != 11) {
      Get.snackbar(
        'Error',
        'NIN must be 11 digits',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final dob = _dobController.text.trim();
    if (dob.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your date of birth',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _isLoading.value = true;

    try {
      print('📤 Verifying NIN...');
      print('📤 NIN: ${_ninController.text.trim()}, DOB: $dob');

      final response = await AccountStatusService.verifyNIN(
        nin: _ninController.text.trim(),
        dateOfBirth: dob,
      );

      print('📥 Verify NIN response: $response');
      print('📥 confirmMatch: ${response['confirmedMatch']}');

      if (response['data'] != null || response['confirmedMatch'] != null) {
        final data = response['data'] as Map<String, dynamic>?;
        final mp = response['matchPercentage'];
        final matchVal =
            mp == null
                ? null
                : (mp is Map<String, dynamic>)
                ? mp
                : (mp is num)
                ? <String, dynamic>{'total': mp.toDouble()}
                : null;
        final msg =
            (response['message'] != null
                ? response['message'].toString()
                : null) ??
            'Please verify that these details match your NIN.';
        setState(() {
          _ninDetails = data ?? response;
          _matchPercentage = matchVal;
          _backendMessage = msg;
        });
        _step.value = 2;
        final total = ((matchVal?['total'] as num?) ?? 0).toDouble();
        if (total <= 50) {
          _startOtpCooldown();
        }

        Get.snackbar(
          'Success',
          response['message'] ?? 'NIN verified, please confirm your details',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error verifying NIN: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  String _maskPhoneLast4(String? phone) {
    if (phone == null || phone.isEmpty) return 'N/A';
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 4) return '****';
    return '${'*' * (digits.length - 4)}${digits.substring(digits.length - 4)}';
  }

  void _showResendOtpModal() {
    if (_otpCooldownSeconds.value > 0) {
      Get.snackbar(
        'Error',
        'Please wait ${_otpCooldownSeconds.value}s before requesting another code.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    final phone =
        (_ninDetails?['phoneNumber'] ?? _ninDetails?['phone'])
            ?.toString()
            .trim();
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Phone number not available from NIN. Please verify NIN again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final maskedPhone = _maskPhoneLast4(phone);

    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.08,
          vertical: 24,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Resend OTP',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send OTP to $maskedPhone',
              style: const TextStyle(
                fontFamily: 'ProductSans Light',
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose how you\'d like to receive it',
              style: TextStyle(
                fontFamily: 'ProductSans Light',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () =>
                  _isResendOtpLoading.value
                      ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: Colors.black),
                              SizedBox(height: 16),
                              Text(
                                'Sending OTP...',
                                style: TextStyle(
                                  fontFamily: 'ProductSans Light',
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: InkWell(
                              onTap: () => _resendOtpViaWhatsApp(phone),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/WhatsApp.svg',
                                      width: 40,
                                      height: 40,
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      'WhatsApp',
                                      style: TextStyle(
                                        fontFamily: 'ProductSans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: InkWell(
                              onTap: () => _resendOtpViaSms(phone),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F8F8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.sms_outlined,
                                        size: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      'SMS',
                                      style: TextStyle(
                                        fontFamily: 'ProductSans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
        actions: [
          const SizedBox(height: 20),
          Obx(
            () => TextButton(
              onPressed:
                  _isResendOtpLoading.value
                      ? null
                      : () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resendOtpViaWhatsApp(String phone) async {
    _isResendOtpLoading.value = true;
    try {
      await AccountStatusService.sendOtpWhatsApp(phone);
      if (Get.isDialogOpen == true) Get.back();
      _startOtpCooldown();
      for (var c in _otpControllers) {
        c.clear();
      }
      Get.snackbar(
        'Success',
        'OTP sent to your WhatsApp',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isResendOtpLoading.value = false;
    }
  }

  Future<void> _resendOtpViaSms(String phone) async {
    _isResendOtpLoading.value = true;
    try {
      await AccountStatusService.sendOtpSms(phone);
      if (Get.isDialogOpen == true) Get.back();
      _startOtpCooldown();
      for (var c in _otpControllers) {
        c.clear();
      }
      Get.snackbar(
        'Success',
        'OTP sent via SMS',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isResendOtpLoading.value = false;
    }
  }

  Future<void> _confirmNINWithConsent() async {
    _isLoading.value = true;
    try {
      print('📤 Confirming NIN (consent, no OTP)...');
      final response = await AccountStatusService.confirmNIN();
      print('📥 Confirm NIN response: $response');
      kycController.ninSet.value = true;
      await kycController.fetchAccountStatus();
      Get.snackbar(
        'Success',
        response['message'] ?? 'NIN confirmed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offNamed('/wallet-pin-setup');
    } catch (e) {
      print('❌ Error confirming NIN: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _confirmNIN() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter the complete 6-digit OTP',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _isLoading.value = true;

    try {
      print('📤 Confirming NIN with OTP...');

      final response = await AccountStatusService.confirmNIN(otp: otp);

      print('📥 Confirm NIN response: $response');

      kycController.ninSet.value = true;
      await kycController.fetchAccountStatus();

      Get.snackbar(
        'Success',
        response['message'] ?? 'NIN confirmed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offNamed('/wallet-pin-setup');
    } catch (e) {
      print('❌ Error confirming NIN: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Get.back(),
            padding: const EdgeInsets.only(left: 18),
          ),
          title: const Text(
            'NIN Verification',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontFamily: 'ProductSans',
            ),
          ),
          actions: [
            // TextButton(
            //   onPressed: _skipNINVerification,
            //   child: const Text(
            //     'Skip',
            //     style: TextStyle(
            //       color: Colors.grey,
            //       fontSize: 16,
            //       fontFamily: 'ProductSans',
            //     ),
            //   ),
            // ),
          ],
        ),
        body: SafeArea(
          child: Obx(() {
            if (_step.value == 1) return _buildNINInputView();
            return _buildNINDetailsView();
          }),
        ),
      ),
    );
  }

  Widget _buildNINInputView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.06,
        vertical: Get.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Verify your Identity',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontWeight: FontWeight.w400,
              fontSize: 40,
              height: 1.2,
              letterSpacing: 0,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Enter your 11-digit NIN and date of birth to verify your identity.',
            style: TextStyle(
              fontFamily: 'ProductSans Light',
              fontWeight: FontWeight.w300,
              fontSize: 15.0,
              height: 1.0,
              letterSpacing: 0.0,
              color: Colors.black,
            ),
          ),

          SizedBox(height: Get.height * 0.03),

          // NIN Icon/Image
          Center(
            child: Image.asset(
              'assets/image/icon 1.png',
              width: 280,
              height: 280,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    size: 120,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: Get.height * 0.04),

          // NIN Input Field
          TextField(
            controller: _ninController,
            keyboardType: TextInputType.number,
            maxLength: 11,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              hintText: 'Enter your 11-digit NIN',
              counterText: '',
              fillColor: const Color(0xFFF8F8F8),
              hintStyle: const TextStyle(
                fontFamily: 'ProductSans Light',
                fontWeight: FontWeight.w300,
                color: Color(0xFFBDBDBD),
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
              ),
            ),
          ),

          SizedBox(height: Get.height * 0.03),

          // DOB Input Field
          TextField(
            controller: _dobController,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(
                  const Duration(days: 365 * 18),
                ),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.black,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                        onSecondary: Colors.white,
                        secondary: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                _dobController.text =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              hintText: 'Tap to select date of birth',
              fillColor: const Color(0xFFF8F8F8),
              hintStyle: const TextStyle(
                fontFamily: 'ProductSans Light',
                fontWeight: FontWeight.w300,
                color: Color(0xFFBDBDBD),
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
              ),
            ),
          ),

          SizedBox(height: Get.height * 0.04),

          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: _isLoading.value ? null : _verifyNIN,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: const Color(0xFFF8F8F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child:
                    _isLoading.value
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.w400,
                            fontSize: 22,
                            letterSpacing: 0,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNINDetailsView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.06,
              vertical: Get.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Your Details',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _backendMessage,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'ProductSans Light',
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF020202),
                  ),
                ),

                const SizedBox(height: 20),

                Builder(
                  builder: (context) {
                    final mp = _matchPercentage;
                    if (mp == null) return const SizedBox.shrink();
                    final total = ((mp['total'] as num?) ?? 0).toDouble();
                    Color matchColor;
                    String matchMessage;
                    if (total < 50) {
                      matchColor = Colors.red;
                      matchMessage = 'Low match. Are these details your\'s?';
                    } else if (total == 50) {
                      matchColor = Colors.amber;
                      matchMessage = 'Moderate match. Review these details.';
                    } else {
                      matchColor = Colors.green;
                      matchMessage =
                          'Good match. Make sure these are your details.';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: matchColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: matchColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                matchMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'ProductSans',
                                  fontWeight: FontWeight.w400,
                                  color: matchColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // NIN Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_ninDetails?['photo'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildPhotoWidget(_ninDetails!['photo']),
                          ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          'NIN',
                          _ninDetails?['nin'] ?? _ninController.text,
                        ),
                        _buildDetailRow(
                          'First Name',
                          _ninDetails?['firstName'],
                        ),
                        if (_ninDetails?['middleName'] != null &&
                            _ninDetails!['middleName'].toString().isNotEmpty)
                          _buildDetailRow(
                            'Middle Name',
                            _ninDetails?['middleName'],
                          ),
                        _buildDetailRow('Last Name', _ninDetails?['lastName']),
                        if (_ninDetails?['phoneNumber'] != null ||
                            _ninDetails?['phone'] != null)
                          _buildDetailRow(
                            'Phone',
                            _maskPhoneLast4(
                              _ninDetails?['phoneNumber']?.toString() ??
                                  _ninDetails?['phone']?.toString(),
                            ),
                          ),
                        if (_ninDetails?['gender'] != null)
                          _buildDetailRow('Gender', _ninDetails?['gender']),
                        if (_ninDetails?['birthDate'] != null)
                          _buildDetailRow(
                            'Date of Birth',
                            _ninDetails?['birthDate'],
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // When match > 50%: consent checkbox + button. Else: OTP fields + Resend OTP
                Builder(
                  builder: (context) {
                    final total =
                        ((_matchPercentage?['total'] as num?) ?? 0).toDouble();
                    final useConsentFlow = total > 50;

                    if (useConsentFlow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _consentChecked,
                                  onChanged: (v) {
                                    setState(
                                      () => _consentChecked = v ?? false,
                                    );
                                  },
                                  activeColor: const Color(0xFF4CAF50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(
                                      () => _consentChecked = !_consentChecked,
                                    );
                                  },
                                  child: const Text(
                                    'I confirm that the details above are correct and belong to me.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'ProductSans Light',
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    (_isLoading.value || !_consentChecked)
                                        ? null
                                        : _confirmNINWithConsent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    _isLoading.value
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Confirm details',
                                          style: TextStyle(
                                            fontFamily: 'ProductSans',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter the 6-digit OTP sent to your NIN phone number',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'ProductSans Light',
                            fontWeight: FontWeight.w300,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return Container(
                                width: Get.width * 0.13,
                                height: Get.width * 0.15,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      228,
                                      226,
                                      226,
                                    ),
                                    width: 2.2,
                                  ),
                                ),
                                child: TextField(
                                  controller: _otpControllers[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  enabled: !_isLoading.value,
                                  style: TextStyle(
                                    fontSize: Get.width * 0.08,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                  onChanged: (value) {
                                    if (value.length == 1 && index < 5) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                    if (value.isEmpty && index > 0) {
                                      FocusScope.of(context).previousFocus();
                                    }
                                    if (index == 5 && value.isNotEmpty) {
                                      final otp =
                                          _otpControllers
                                              .map((c) => c.text)
                                              .join();
                                      if (otp.length == 6) {
                                        _confirmNIN();
                                      }
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // Bottom bar: only show Resend OTP when match <= 50%
        Builder(
          builder: (context) {
            final total =
                ((_matchPercentage?['total'] as num?) ?? 0).toDouble();
            if (total > 50) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.06,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Obx(() {
                final canResend = _otpCooldownSeconds.value == 0;
                final label =
                    canResend
                        ? 'Resend OTP'
                        : 'Resend OTP (${_otpCooldownSeconds.value}s)';
                return Center(
                  child: TextButton(
                    onPressed:
                        (_isLoading.value || !canResend)
                            ? null
                            : _showResendOtpModal,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: canResend ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'ProductSans',
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'ProductSans',
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(String photoData) {
    try {
      // Check if it's a base64 string
      if (photoData.startsWith('data:image')) {
        // Remove the data:image/jpeg;base64, or similar prefix
        final base64String = photoData.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: 120,
          width: 120,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 120, color: Colors.grey),
        );
      } else if (photoData.contains('base64')) {
        // Try to extract base64 data
        final base64String = photoData.replaceAll(
          RegExp(r'data:image/[^;]+;base64,'),
          '',
        );
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: 120,
          width: 120,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 120, color: Colors.grey),
        );
      } else {
        // Try as direct base64
        final bytes = base64Decode(photoData);
        return Image.memory(
          bytes,
          height: 120,
          width: 120,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 120, color: Colors.grey),
        );
      }
    } catch (e) {
      print('Error decoding photo: $e');
      // Fallback to network image if base64 fails
      if (photoData.startsWith('http')) {
        return Image.network(
          photoData,
          height: 120,
          width: 120,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 120, color: Colors.grey),
        );
      }
      return const Icon(Icons.person, size: 120, color: Colors.grey);
    }
  }
}
