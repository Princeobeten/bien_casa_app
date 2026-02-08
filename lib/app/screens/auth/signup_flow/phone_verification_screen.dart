import 'package:bien_casa/app/screens/docs/privacy_policy_screen.dart';
import 'package:bien_casa/app/screens/docs/terms_of_service_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class PhoneVerificationScreen extends StatelessWidget {
  final String userType;

  const PhoneVerificationScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 380;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: isSmallScreen ? 40 : 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
          padding: EdgeInsets.only(left: 18),
          iconSize: isSmallScreen ? 18 : 24,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              // Logo
              Container(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
                child: Image.asset(
                  'assets/image/logo_black.png',
                  width: 50,
                  height: 50.2,
                ),
              ),

              SizedBox(
                height:
                    isSmallScreen ? screenHeight * 0.01 : screenHeight * 0.02,
              ),

              // Title
              Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),

              SizedBox(height: isSmallScreen ? 14 : 15),

              // Subtitle
              Text.rich(
                TextSpan(
                  text: 'to continue, kindly enter an active ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'ProductSans',
                    color: Colors.black,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Whatsapp',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                        color: Colors.green[700],
                        height: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: '\nphone number for the best experience',
                    ),
                  ],
                ),
              ),

              SizedBox(
                height:
                    isSmallScreen ? screenHeight * 0.04 : screenHeight * 0.07,
              ),

              // Phone Number Input
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical:
                      isSmallScreen
                          ? screenHeight * 0.012
                          : screenHeight * 0.016,
                ),
                decoration: BoxDecoration(
                  color: Color(0xffF8F8F8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    // Country Code with WhatsApp Icon
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : 8,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/WhatsApp.svg',
                            width: 38,
                            height: 38,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+234',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'ProductSans',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 5 : 10),
                    // Phone Number TextField
                    Expanded(
                      child: TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'ProductSans',
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter WhatsApp number',
                          hintStyle: TextStyle(
                            color: Colors.black26,
                            fontSize: 18,
                            fontFamily: 'ProductSans',
                          ),
                          contentPadding:
                              isSmallScreen
                                  ? EdgeInsets.symmetric(vertical: 8)
                                  : null,
                        ),
                        onChanged: (_) => controller.updatePhoneButtonState(),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height:
                    isSmallScreen ? screenHeight * 0.02 : screenHeight * 0.03,
              ),

              // Referral Code
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25.0),
                      ),
                    ),
                    builder:
                        (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 20,
                            right: 20,
                            top: 20,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enter Referral Code',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'ProductSans',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xffF8F8F8),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextField(
                                  controller: controller.referralCodeController,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'ProductSans',
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter your referral code',
                                    hintStyle: TextStyle(
                                      color: Colors.black26,
                                      fontSize: 18,
                                      fontFamily: 'ProductSans',
                                    ),
                                  ),
                                  onChanged:
                                      (_) =>
                                          controller.updateReferralCodeState(),
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: Obx(
                                  () => ElevatedButton(
                                    onPressed:
                                        controller.isReferralCodeValid.value
                                            ? () =>
                                                controller.submitReferralCode()
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      disabledBackgroundColor: Color(
                                        0xffF8F8F8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'ProductSans',
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                  );
                },
                child: Obx(
                  () => Row(
                    children: [
                      Text(
                        controller.isReferralCodeValid.value
                            ? 'Referral code applied'
                            : 'Have a referral code?',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'ProductSans',
                          color:
                              controller.isReferralCodeValid.value
                                  ? Color(0xff29BCA2)
                                  : Colors.black,
                        ),
                      ),
                      if (controller.isReferralCodeValid.value) ...[
                        SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: Color(0xff29BCA2),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Continue Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 60 : 70,
                  child: ElevatedButton(
                    onPressed:
                        controller.isPhoneValid.value
                            ? () => controller.verifyPhoneNumber()
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Color(0xffF8F8F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 22,
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Sign In Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Have an account? ',
                    style: TextStyle(
                      fontSize:
                          isSmallScreen
                              ? screenWidth * 0.035
                              : screenWidth * 0.04,
                      fontFamily: 'ProductSans',
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.navigateToSignIn(),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize:
                            isSmallScreen
                                ? screenWidth * 0.035
                                : screenWidth * 0.04,
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 35),

              Text.rich(
                TextSpan(
                  text: 'By using Bien Casa you agree to our ',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'ProductSans Light',
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.normal,
                    leadingDistribution: TextLeadingDistribution.proportional,
                    letterSpacing: 0,
                  ),
                  children: [
                    TextSpan(
                      text: 'Term of Service',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 15,
                        leadingDistribution:
                            TextLeadingDistribution.proportional,
                        letterSpacing: 0,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap =
                                () =>
                                    Get.to(() => const TermsOfServiceScreen()),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 15,
                        leadingDistribution:
                            TextLeadingDistribution.proportional,
                        letterSpacing: 0,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap =
                                () => Get.to(() => const PrivacyPolicyScreen()),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
