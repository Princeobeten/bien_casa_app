import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final isSmallScreen = Get.height < 600;

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
              // Logo
              Container(
                padding: EdgeInsets.symmetric(vertical: Get.width * 0.02),
                child: Image.asset(
                  'assets/image/logo_black.png',
                  width: 50,
                  height: 50.2,
                ),
              ),

              SizedBox(height: Get.height * 0.04),

              // Title
              Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: Get.width * 0.10,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: Get.height * 0.02),

              Text(
                'Enter your email address to receive a password reset code',
                style: TextStyle(
                  fontSize: Get.width * 0.045,
                  fontFamily: 'ProductSans',
                  color: Colors.black54,
                ),
              ),

              SizedBox(height: Get.height * 0.06),

              // Email Field
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  filled: true,
                  fillColor: Color(0xFFF8F8F8),
                  hintText: 'Email address',
                  hintStyle: TextStyle(
                    fontFamily: 'ProductSans Light',
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFBDBDBD),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFF8F8F8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFF8F8F8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFF8F8F8)),
                  ),
                ),
              ),

              Spacer(),

              // Send OTP Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : controller.sendForgotPasswordOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child:
                        controller.isLoading.value
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Send Reset Code',
                              style: TextStyle(
                                fontSize: Get.width * 0.055,
                                fontFamily: 'ProductSans',
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),

              SizedBox(height: Get.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
