import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                'Privacy Policy',
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
                    'Welcome to Bien Casa! Your privacy is important to us. '
                    'This Privacy Policy explains how we collect, use, and protect your personal information.\n\n'
                    '1. Information We Collect\n'
                    'We collect information you provide directly to us, including personal details, property preferences, and account information.\n\n'
                    '2. How We Use Your Information\n'
                    'We use your information to provide and improve our services, personalize your experience, and communicate with you.\n\n'
                    '3. Information Sharing\n'
                    'We do not sell your personal information. We may share your information with trusted partners to provide our services.\n\n'
                    '4. Data Security\n'
                    'We implement appropriate security measures to protect your personal information.\n\n'
                    '5. Your Rights\n'
                    'You have the right to access, correct, or delete your personal information.\n\n'
                    '6. Cookies\n'
                    'We use cookies to improve your experience on our platform.\n\n'
                    '7. Third-Party Services\n'
                    'Our service may contain links to third-party websites. We are not responsible for their privacy practices.\n\n'
                    '8. Children\'s Privacy\n'
                    'Our services are not intended for children under 13 years of age.\n\n'
                    '9. Changes to Privacy Policy\n'
                    'We may update this policy from time to time. We will notify you of any significant changes.\n\n'
                    '10. Contact Us\n'
                    'If you have questions about this Privacy Policy, please contact our support team.',
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
