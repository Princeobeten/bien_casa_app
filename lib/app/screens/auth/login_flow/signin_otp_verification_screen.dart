import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class SignInOtpVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final String correctOTP = "1234"; // Simulated correct OTP

  const SignInOtpVerificationScreen({super.key, required this.phoneNumber});

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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.06,
            vertical: Get.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter\nyour OTP',
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              SizedBox(height: Get.height * 0.03),
              RichText(
                text: TextSpan(
                  text: 'Kindly enter the OTP code sent to your phone ',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'number ',
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                    TextSpan(
                      text:
                          phoneNumber.length >= 3
                              ? '***${phoneNumber.substring(phoneNumber.length - 3)}'
                              : phoneNumber,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: ' below',
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    Color borderColor = const Color(0xffF8F8F8);
                    if (controller.isOtpComplete.value) {
                      borderColor =
                          controller.otpControllers.map((c) => c.text).join() ==
                                  correctOTP
                              ? const Color(0xff29BCA2)
                              : const Color(0xffDC3545);
                    }
                    return Container(
                      width: Get.width * 0.18,
                      height: Get.width * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: borderColor, width: 2.2),
                      ),
                      child: TextField(
                        controller: controller.otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: Get.width * 0.07,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 3) {
                            FocusScope.of(context).nextFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                          controller.isOtpComplete();
                          if (controller.isOtpComplete.value) {
                            verifySignInOTP(controller);
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
              Spacer(),
              SizedBox(height: Get.width * 0.15),
              Center(
                child: GestureDetector(
                  onTap: () => controller.resendOTP(),
                  child: Column(
                    children: const [
                      Text(
                        'I didn\'t receive a code?',
                        style: TextStyle(
                          fontFamily: 'ProductSans Light',
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          fontSize: 15,
                          leadingDistribution:
                              TextLeadingDistribution.proportional,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Resend code',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ProductSans',
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Get.width * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  void verifySignInOTP(AuthController controller) {
    final otp = controller.otpControllers.map((c) => c.text).join();
    if (otp.length == 4) {
      if (otp == correctOTP) {
        // Check for correct OTP
        Get.snackbar(
          'Success',
          'OTP verification successful',
          snackPosition: SnackPosition.TOP,
        );
        // Route to user home after successful sign in
        Get.offAllNamed(AppRoutes.USER_HOME);
      } else {
        Get.snackbar(
          'Error',
          'Invalid OTP code',
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }
}
