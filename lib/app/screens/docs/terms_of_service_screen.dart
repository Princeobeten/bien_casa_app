import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
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
                'Terms of Service',
                style: TextStyle(
                  fontSize: Get.width * 0.10,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: Get.height * 0.04),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Welcome to Bien Casa! These Terms of Service govern your use of our platform. '
                    'By using our services, you agree to these terms.\n\n'
                    '1. Acceptance of Terms\n'
                    'By accessing or using Bien Casa, you agree to be bound by these Terms.\n\n'
                    '2. User Accounts\n'
                    'You must register for an account to access certain features. You are responsible for maintaining the confidentiality of your account.\n\n'
                    '3. User Conduct\n'
                    'You agree to use our services responsibly and in compliance with all applicable laws.\n\n'
                    '4. Property Listings\n'
                    'All property listings must be accurate and comply with our guidelines.\n\n'
                    '5. Intellectual Property\n'
                    'All content on Bien Casa is protected by intellectual property rights.\n\n'
                    '6. Limitation of Liability\n'
                    'Bien Casa is not liable for any damages arising from your use of our services.\n\n'
                    '7. Modifications\n'
                    'We reserve the right to modify these terms at any time.\n\n'
                    '8. Termination\n'
                    'We may terminate or suspend your account for violations of these terms.\n\n'
                    '9. Governing Law\n'
                    'These terms are governed by the laws of Nigeria.\n\n'
                    '10. Contact Us\n'
                    'For questions about these terms, please contact our support team.',
                    style: TextStyle(
                      fontSize: Get.width * 0.04,
                      fontFamily: 'ProductSans',
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
