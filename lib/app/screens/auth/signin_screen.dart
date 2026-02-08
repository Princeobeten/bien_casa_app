import 'package:bien_casa/app/routes/app_routes.dart';
import 'package:bien_casa/app/screens/docs/privacy_policy_screen.dart';
import 'package:bien_casa/app/screens/docs/terms_of_service_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  final RxBool isEmailInput = false.obs;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => Get.to(() => const TermsOfServiceScreen());
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => Get.to(() => const PrivacyPolicyScreen());
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _checkInputType(String value) {
    // Check if input contains @ symbol (email indicator)
    if (value.contains('@')) {
      isEmailInput.value = true;
    } else {
      isEmailInput.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return GestureDetector(
      onTap:
          () =>
              FocusScope.of(
                context,
              ).unfocus(), // Dismiss keyboard when tapping outside
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
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
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
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
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: Get.height * 0.01),

                    Text(
                      'to continue, kindly enter your phone number or\nemail address associated with your account',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'ProductSans Light',
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF020202),
                      ),
                    ),

                    SizedBox(height: Get.height * 0.06),

                    // Phone Number or Email Field
                    Obx(
                      () => TextFormField(
                        controller: controller.phoneController,
                        keyboardType: isEmailInput.value 
                            ? TextInputType.emailAddress 
                            : TextInputType.phone,
                        onChanged: _checkInputType,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number or email is required';
                          }
                          
                          // Check if it's an email
                          if (value.contains('@')) {
                            // Email validation
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                          } else {
                            // Phone number validation
                            String cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');
                            if (cleanedValue.length < 10) {
                              return 'Phone number must be at least 10 digits';
                            }
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: isEmailInput.value ? 20 : 0,
                          ),
                          hintText: 'Phone number or Email',
                          hintStyle: TextStyle(
                            fontFamily: 'ProductSans Light',
                            fontWeight: FontWeight.w300,
                            color: Color(0xFFBDBDBD),
                          ),
                          filled: true,
                          fillColor: Color(0xFFF8F8F8),
                          prefixIcon: isEmailInput.value
                              ? Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFFBDBDBD),
                                )
                              : Container(
                                  padding: EdgeInsets.all(12),
                                  color: Color(0xFFF8F8F8),
                                  child: Image.asset(
                                    'assets/icons/nigeria_flag.png',
                                    width: 44,
                                    height: 28,
                                  ),
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: Get.height * 0.02),

                    // Password Field
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          filled: true,
                          fillColor: Color(0xFFF8F8F8),
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            fontFamily: 'ProductSans Light',
                            fontWeight: FontWeight.w300,
                            color: Color(0xFFBDBDBD),
                          ),
                          // prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.togglePasswordVisibility,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.navigateToForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFF020202),
                            fontFamily: 'ProductSans Light',
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            height: 1,
                            leadingDistribution:
                                TextLeadingDistribution.proportional,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: Get.height * 0.06),
                    // Sign In Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : () {
                                    // Dismiss keyboard
                                    FocusScope.of(context).unfocus();

                                    // Validate form before proceeding
                                    if (formKey.currentState!.validate()) {
                                      controller.signIn();
                                    }
                                  },
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
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: Get.width * 0.055,
                                      fontFamily: 'ProductSans',
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Don\'t have an account? ',
                                style: TextStyle(
                                  color: Color(0xFF020202),
                                  fontFamily: 'ProductSans Light',
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16,
                                  height: 1,
                                  leadingDistribution:
                                      TextLeadingDistribution.even,
                                  letterSpacing: 0,
                                ),
                              ),
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () => Get.toNamed(AppRoutes.SIGNUP),
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Color(0xFF020202),
                                      fontFamily: 'ProductSans-Black',
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 16,
                                      height: 1,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 75),

                    // Terms and Privacy
                    Text.rich(
                      TextSpan(
                        text: 'By using Bien Casa you agree to our ',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'ProductSans Light',
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          leadingDistribution:
                              TextLeadingDistribution.proportional,
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
                            recognizer: _termsRecognizer,
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
                            recognizer: _privacyRecognizer,
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
          ),
        ),
      ),
    );
  }
}
