import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../controllers/auth_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with CodeAutoFill {
  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void codeUpdated() {
    final controller = Get.find<AuthController>();
    if (code != null && code!.length >= 6) {
      // Auto-fill the OTP fields (first 6 digits)
      for (int i = 0; i < 6; i++) {
        controller.otpControllers[i].text = code![i];
      }
      // Auto-verify
      controller.verifyOTP();
    }
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
          padding: EdgeInsets.only(left: 18),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.06,
                vertical: Get.height * 0.02,
              ),
              child: SizedBox(
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
                          TextSpan(
                            text: 'sent to your number ',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: 'WhatsApp',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                          TextSpan(
                            text: ' number',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
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
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.grey.withValues(alpha: 0.3),
                            //     blurRadius: 2,
                            //     spreadRadius: 0.1,
                            //     offset: Offset(0, 2),
                            //   ),
                            // ],
                          ),
                          child: TextField(
                            controller: controller.otpControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            enabled: !controller.isLoading.value,
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
                              // Auto-verify when all 6 digits are entered
                              if (index == 5 && value.isNotEmpty) {
                                final otp =
                                    controller.otpControllers
                                        .take(6)
                                        .map((c) => c.text)
                                        .join();
                                if (otp.length == 6) {
                                  controller.verifyOTP();
                                }
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    SizedBox(height: Get.height * 0.04),
                    Center(
                      child: Obx(() {
                        final canResend = controller.canResendOtp.value;
                        final resendLoading =
                            controller.isResendOtpLoading.value;
                        return GestureDetector(
                          onTap:
                              (canResend && !resendLoading)
                                  ? () {
                                    for (int i = 0; i < 6; i++) {
                                      controller.otpControllers[i].clear();
                                    }
                                    controller.resendOTP();
                                  }
                                  : null,
                          child: Column(
                            children: [
                              const Text(
                                'I didn\'t receive a code?',
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (resendLoading)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Text(
                                  canResend
                                      ? 'Resend code'
                                      : 'Resend in ${controller.otpResendCountdown.value}s',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'ProductSans',
                                    fontSize: 17,
                                    color:
                                        canResend ? Colors.black : Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: Get.height * 0.02),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (!controller.isLoading.value) return const SizedBox.shrink();
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
    );
  }
}
