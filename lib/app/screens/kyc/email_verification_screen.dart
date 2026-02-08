import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/kyc_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/account_status_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _emailController = TextEditingController();
  final _otpControllers = List.generate(6, (index) => TextEditingController());
  final _isLoading = false.obs;
  final _otpSent = false.obs;
  final _formKey = GlobalKey<FormState>();
  final kycController = Get.find<KYCController>();

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _skipEmailVerification() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Skip Email Verification?',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'You can verify your email later from your profile settings.',
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
              print('🔄 Skip email verification button pressed');

              // Close dialog first
              Navigator.of(context).pop();
              print('✅ Dialog closed');

              // Wait a moment for dialog to close
              await Future.delayed(const Duration(milliseconds: 200));

              // Mark as skipped (completed) so user can move to next step
              kycController.emailVerified.value = true;
              print('✅ emailVerified set to true');

              // Show snackbar
              Get.snackbar(
                'Skipped',
                'You can verify your email later from your profile',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );

              // Close the email verification screen and return to home
              print('🔄 Closing email verification screen...');
              Navigator.of(context).pop(true);
              print('✅ Email verification screen closed');
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

  Future<void> _sendOTP({bool isResend = false}) async {
    if (!isResend && (_formKey.currentState == null || !_formKey.currentState!.validate())) {
      return;
    }

    _isLoading.value = true;

    try {
      print('📤 Sending email OTP...');
      print('📤 Email: ${_emailController.text.trim()}');

      final response = await AccountStatusService.sendEmailOTP(
        _emailController.text.trim(),
      );

      print('📥 Send OTP response: $response');

      Get.snackbar(
        'Success',
        response['message'] ?? 'OTP sent to your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _otpSent.value = true;
    } catch (e) {
      print('❌ Error sending OTP: $e');
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

  Future<void> _verifyOTP() async {
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
      print('📤 Verifying email OTP...');
      print('📤 Payload: {email: ${_emailController.text.trim()}, otp: $otp}');

      final response = await AccountStatusService.verifyEmailOTP(
        email: _emailController.text.trim(),
        otp: otp,
      );

      print('📥 Verify OTP response: $response');

      // Update KYC status
      kycController.emailVerified.value = true;
      await kycController.fetchAccountStatus();

      Get.snackbar(
        'Success',
        response['message'] ?? 'Email verified successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to user home
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.USER_HOME);
    } catch (e) {
      print('❌ Error verifying OTP: $e');
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
            'Email Verification',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: 'ProductSans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: _skipEmailVerification,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Get.width * 0.06,
                  vertical: Get.height * 0.02,
                ),
                child: Obx(
                  () => _otpSent.value ? _buildOTPView() : _buildEmailView(),
                ),
              ),
              Obx(() {
                if (!_isLoading.value) return const SizedBox.shrink();
                return Positioned.fill(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.85),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading…',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Verify\nYour Email',
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
            'Enter your email address to receive a verification code',
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

          // Email Icon/Image
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 120,
                color: Colors.grey,
              ),
            ),
          ),

          SizedBox(height: Get.height * 0.04),

          // Email Input Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              hintText: 'Enter your email address',
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          SizedBox(height: Get.height * 0.04),

          // Send OTP Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: _isLoading.value ? null : _sendOTP,
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
                            color: Colors.white,
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

  Widget _buildOTPView() {
    return SizedBox(
      height: Get.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter\nyour OTP',
            style: TextStyle(
              fontSize: Get.width * 0.10,
              fontFamily: 'ProductSans',
              fontWeight: FontWeight.w400,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          SizedBox(height: Get.height * 0.03),
          RichText(
            text: TextSpan(
              text: 'Kindly enter the 6-digit OTP code ',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: Get.width * 0.04,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
              children: [
                const TextSpan(
                  text: 'sent to your email ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: _emailController.text,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Spacer(),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return Container(
                  width: Get.width * 0.12,
                  height: Get.width * 0.14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 232, 230, 230),
                      width: 2.2,
                    ),
                  ),
                  child: TextField(
                    controller: _otpControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    enabled: !_isLoading.value,
                    style: TextStyle(
                      fontSize: Get.width * 0.06,
                      fontWeight: FontWeight.w500,
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
                        final otp = _otpControllers.map((c) => c.text).join();
                        if (otp.length == 6) {
                          _verifyOTP();
                        }
                      }
                    },
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: Get.height * 0.01),
          Center(
            child: TextButton(
              onPressed: () {
                _otpSent.value = false;
                for (var controller in _otpControllers) {
                  controller.clear();
                }
              },
              child: const Text(
                'Change email',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'ProductSans',
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                const Text(
                  'I didn\'t receive a code?',
                  style: TextStyle(fontFamily: 'ProductSans', fontSize: 15),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _isLoading.value
                      ? null
                      : () {
                          for (var controller in _otpControllers) {
                            controller.clear();
                          }
                          _sendOTP(isResend: true);
                        },
                  child: const Text(
                    'Resend code',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'ProductSans',
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Get.height * 0.02),
        ],
      ),
    );
  }
}
