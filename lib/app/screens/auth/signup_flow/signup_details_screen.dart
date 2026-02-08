import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class SignupDetailsScreen extends StatefulWidget {
  const SignupDetailsScreen({super.key});

  @override
  State<SignupDetailsScreen> createState() => _SignupDetailsScreenState();
}

class _SignupDetailsScreenState extends State<SignupDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isPasswordHidden = true.obs;

  @override
  void initState() {
    super.initState();
    // Pre-populate referral code if it was entered in phone verification screen
    final controller = Get.find<AuthController>();
    if (controller.referralCodeController.text.isNotEmpty) {
      _referralCodeController.text = controller.referralCodeController.text;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _referralCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<AuthController>();
      
      print('📝 ===== SIGNUP REGISTRATION PAYLOAD =====');
      print('📝 First Name: ${_firstNameController.text.trim()}');
      print('📝 Middle Name: ${_middleNameController.text.trim().isEmpty ? "(empty)" : _middleNameController.text.trim()}');
      print('📝 Last Name: ${_lastNameController.text.trim()}');
      print('📝 Phone: ${controller.phoneController.text}');
      print('📝 Password: ${"*" * _passwordController.text.length} (${_passwordController.text.length} characters)');
      print('📝 Referral Code: ${_referralCodeController.text.trim().isEmpty ? "(empty)" : _referralCodeController.text.trim()}');
      print('📝 ');
      print('📝 Expected API Payload:');
      print('📝 {');
      print('📝   "firstName": "${_firstNameController.text.trim()}",');
      if (_middleNameController.text.trim().isNotEmpty) {
        print('📝   "middleName": "${_middleNameController.text.trim()}",');
      }
      print('📝   "lastName": "${_lastNameController.text.trim()}",');
      print('📝   "phone": "${controller.phoneController.text}",');
      print('📝   "password": "***hidden***",');
      if (_referralCodeController.text.trim().isNotEmpty) {
        print('📝   "referralCode": "${_referralCodeController.text.trim()}"');
      }
      print('📝 }');
      print('📝 ========================================');
      
      // Call the signup method in controller
      await controller.signup(
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        password: _passwordController.text,
        referralCode: _referralCodeController.text.trim(),
      );
    } else {
      print('❌ Form validation failed');
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
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.06,
              vertical: Get.height * 0.02,
            ),
            child: Form(
              key: _formKey,
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
                    const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: Get.height * 0.01),

                    const Text(
                      'to continue, kindly provide your details below',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'ProductSans Light',
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF020202),
                      ),
                    ),

                    SizedBox(height: Get.height * 0.04),

                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'First Name *',
                        labelStyle: const TextStyle(
                          fontFamily: 'ProductSans',
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: Get.height * 0.02),

                    // Middle Name
                    TextFormField(
                      controller: _middleNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Middle Name (Optional)',
                        labelStyle: const TextStyle(
                          fontFamily: 'ProductSans',
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),

                    SizedBox(height: Get.height * 0.02),

                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Last Name *',
                        labelStyle: const TextStyle(
                          fontFamily: 'ProductSans',
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: Get.height * 0.02),

                    // Phone Number (Read-only)
                    TextFormField(
                      controller: TextEditingController(
                        text: Get.find<AuthController>().phoneController.text,
                      ),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Phone Number *',
                        labelStyle: const TextStyle(
                          fontFamily: 'ProductSans',
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xff29BCA2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xff29BCA2)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: const Icon(
                          Icons.check_circle,
                          color: Color(0xff29BCA2),
                        ),
                      ),
                    ),

                    SizedBox(height: Get.height * 0.02),

                    // Referral Code
                    TextFormField(
                      controller: _referralCodeController,
                      textCapitalization: TextCapitalization.characters,
                      readOnly: Get.find<AuthController>().isReferralCodeValid.value,
                      decoration: InputDecoration(
                        labelText: 'Referral Code (Optional)',
                        labelStyle: const TextStyle(
                          fontFamily: 'ProductSans',
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Get.find<AuthController>().isReferralCodeValid.value
                                ? const Color(0xff29BCA2)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Get.find<AuthController>().isReferralCodeValid.value
                                ? const Color(0xff29BCA2)
                                : Colors.black,
                          ),
                        ),
                        suffixIcon: Get.find<AuthController>().isReferralCodeValid.value
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xff29BCA2),
                              )
                            : null,
                      ),
                    ),

                    SizedBox(height: Get.height * 0.02),

                    // Password
                    Obx(
                      () => TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          labelStyle: const TextStyle(
                            fontFamily: 'ProductSans',
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              _isPasswordHidden.value = !_isPasswordHidden.value;
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                            return 'Password must contain at least one letter and one number';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: Get.height * 0.04),

                    // Submit Button
                    Obx(
                      () {
                        final controller = Get.find<AuthController>();
                        return SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value 
                                ? null 
                                : _submitRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Complete Registration',
                                    style: TextStyle(
                                      fontSize: Get.width * 0.055,
                                      fontFamily: 'ProductSans',
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
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
