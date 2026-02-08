import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class WhatsAppVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const WhatsAppVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<WhatsAppVerificationScreen> createState() =>
      _WhatsAppVerificationScreenState();
}

class _WhatsAppVerificationScreenState
    extends State<WhatsAppVerificationScreen> {
  final _isLoading = false.obs;
  final controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    
    // Automatically send OTP after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Format and set phone number
      String phone = widget.phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      controller.phoneController.text = phone;
      _sendOTP();
    });
  }

  Future<void> _sendOTP() async {
    _isLoading.value = true;

    try {
      // Send OTP via API
      controller.sendOTP();

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      if (kDebugMode) {
        print('Send OTP error: $e');
      }
    }
  }

  void _showAlternativeVerificationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Verification Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'ProductSans',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select how you\'d like to receive your verification code',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'ProductSans',
              ),
            ),
            const SizedBox(height: 24),
            
            // SMS Option
            Obx(
              () => ListTile(
                enabled: controller.canResendOtp.value,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: controller.canResendOtp.value 
                        ? Colors.blue[50] 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.sms, 
                    color: controller.canResendOtp.value 
                        ? Colors.blue 
                        : Colors.grey,
                  ),
                ),
                title: Text(
                  'SMS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ProductSans',
                    color: controller.canResendOtp.value 
                        ? Colors.black 
                        : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  controller.canResendOtp.value
                      ? 'Send code to ${widget.phoneNumber}'
                      : 'Wait ${controller.otpResendCountdown.value}s to resend',
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'ProductSans',
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios, 
                  size: 16,
                  color: controller.canResendOtp.value 
                      ? Colors.black 
                      : Colors.grey,
                ),
                onTap: controller.canResendOtp.value
                    ? () {
                        Navigator.pop(context);
                        controller.sendOTPViaSMS();
                        Get.toNamed(AppRoutes.OTP_VERIFICATION, arguments: widget.phoneNumber);
                      }
                    : null,
              ),
            ),
            
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.only(left: 18),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.06,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // WhatsApp Icon
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/WhatsApp.svg',
                    width: 100,
                    height: 100,
                  ),
                ),

                SizedBox(height: Get.height * 0.04),

                // Title
                const Text(
                  'Sending OTP...',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: Get.height * 0.02),

                Text(
                  'We\'re sending a verification code to your\nWhatsApp number',
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'ProductSans Light',
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF020202),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: Get.height * 0.04),

                // Loading indicator
                Obx(
                  () => _isLoading.value
                      ? const CircularProgressIndicator(
                          color: Color(0xFF25D366),
                        )
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: Get.height * 0.04),

                // Alternative options button
                TextButton(
                  onPressed: () => _showAlternativeVerificationOptions(),
                  child: const Text(
                    'Use SMS instead',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
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