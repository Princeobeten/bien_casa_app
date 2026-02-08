import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routes/app_routes.dart';
import '../screens/home_owner/home_owner_main_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  AuthController() {
    // Initialize controller
  }

  final RxString selectedRole = ''.obs;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpControllers = List.generate(6, (index) => TextEditingController());
  final RxBool isOtpComplete = false.obs;
  final RxString userType = ''.obs;
  final RxBool isPhoneValid = false.obs;
  final RxInt currentKYCStep = 0.obs;
  final RxString selectedDocumentType = ''.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isNewPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final referralCodeController = TextEditingController();
  final RxBool isReferralCodeValid = false.obs;
  final RxBool isLoading = false.obs;
  final RxString resetToken = ''.obs;
  final RxString whatsappNumber = ''.obs;
  final RxString whatsappMessage = ''.obs;
  final RxString currentOtp = ''.obs;
  final RxString verificationType = 'phone'.obs; // 'phone' or 'email'
  final RxString verificationIdentifier = ''.obs; // phone number or email
  final RxString verificationMethod =
      'whatsapp'.obs; // 'whatsapp', 'sms', or 'email'

  // OTP Resend Timer
  final RxInt otpResendCountdown = 0.obs;
  final RxBool canResendOtp = true.obs;
  final RxBool isResendOtpLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void startOtpResendCountdown(int seconds) {
    canResendOtp.value = false;
    otpResendCountdown.value = seconds;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (otpResendCountdown.value > 0) {
        otpResendCountdown.value--;
        return true;
      } else {
        canResendOtp.value = true;
        return false;
      }
    });
  }

  int extractSecondsFromError(String errorMessage) {
    // Extract seconds from error message like "Please wait 55s before requesting another code."
    final regex = RegExp(r'(\d+)s');
    final match = regex.firstMatch(errorMessage);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '60') ?? 60;
    }
    return 60; // Default to 60 seconds if can't parse
  }

  // Smart resend OTP - calls the correct method based on verification method
  Future<void> resendOTP() async {
    if (kDebugMode) {
      print('🔄 Resending OTP via ${verificationMethod.value}');
      print('🔄 Type: ${verificationType.value}');
      print('🔄 Identifier: ${verificationIdentifier.value}');
    }

    isResendOtpLoading.value = true;
    try {
      switch (verificationMethod.value) {
        case 'email':
          await sendOTPViaEmail(verificationIdentifier.value);
          break;
        case 'sms':
          await sendOTPViaSMS();
          break;
        case 'whatsapp':
        default:
          await sendOTP();
          break;
      }
    } finally {
      isResendOtpLoading.value = false;
    }
  }

  void navigateToForgotPassword() {
    Get.toNamed(AppRoutes.FORGOT_PASSWORD);
  }

  void signIn() async {
    isLoading.value = true;

    try {
      // Format phone number to include country code if not present
      String phone = phoneController.text.trim();
      if (!phone.startsWith('234') && phone.startsWith('0')) {
        phone = '234${phone.substring(1)}';
      } else if (!phone.startsWith('234')) {
        phone = '234$phone';
      }

      final response = await ApiService.login(
        phone: phone,
        password: passwordController.text,
      );

      if (kDebugMode) {
        print('Login successful: $response');
      }

      // Store token and user data
      if (response['data'] != null) {
        final data = response['data'];
        final token = data['token'] ?? data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userData = data['user'] ?? {};

        if (token != null) {
          await StorageService.saveAuthData(
            token: token,
            userData: userData,
            refreshToken: refreshToken,
          );
          if (kDebugMode) {
            print('✅ Login data saved to storage');
          }
        }
      }

      Get.snackbar(
        'Success',
        response['message'] ?? 'Welcome back!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to user home
      _navigateToUserDashboard();
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateToUserDashboard() {
    // Navigate to user dashboard/home
    userType.value = 'User';
    Get.offAllNamed(AppRoutes.USER_HOME);
    Get.snackbar(
      'Welcome Back!',
      'Successfully signed in',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _navigateToRealtorDashboard() {
    // Navigate to realtor dashboard (for now use user home, can be updated later)
    userType.value = 'Realtor';
    Get.offAllNamed(AppRoutes.USER_HOME);
    Get.snackbar(
      'Welcome!',
      'Signed in as Realtor',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _navigateToHomeOwnerDashboard() {
    // Navigate to home owner main screen with bottom navigation
    userType.value = 'Home Owner';
    Get.offAll(() => const HomeOwnerMainScreen());
    Get.snackbar(
      'Welcome!',
      'Signed in as Home Owner',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void navigateToRestPassword() {
    Get.toNamed(AppRoutes.REST_PASSWORD);
  }

  Future<void> sendOTP() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your phone number',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Format phone number (without country code, starting with 0)
      String phone = phoneController.text.trim();
      // Remove country code if present
      if (phone.startsWith('234')) {
        phone = '0${phone.substring(3)}';
      } else if (!phone.startsWith('0')) {
        phone = '0$phone';
      }

      if (kDebugMode) {
        print('📱 Sending WhatsApp OTP to: $phone');
      }

      // Use new WhatsApp endpoint
      final response = await ApiService.sendOTPViaWhatsApp(phone: phone);

      if (kDebugMode) {
        print('📱 WhatsApp OTP response: $response');
      }

      // Set verification type and identifier for WhatsApp verification
      verificationType.value = 'phone';
      verificationMethod.value = 'whatsapp';
      // Format phone with country code for verification
      String formattedPhone = phoneController.text.trim();
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '234${formattedPhone.substring(1)}';
      } else if (!formattedPhone.startsWith('234')) {
        formattedPhone = '234$formattedPhone';
      }
      verificationIdentifier.value = formattedPhone;

      Get.snackbar(
        'Success',
        'OTP sent to your WhatsApp',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Start countdown timer (default 60 seconds)
      startOtpResendCountdown(60);

      // Navigate directly to OTP verification screen
      Get.toNamed(AppRoutes.OTP_VERIFICATION, arguments: formattedPhone);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Check if it's a rate limit error
      if (errorMessage.toLowerCase().contains('wait') &&
          errorMessage.contains('s')) {
        final seconds = extractSecondsFromError(errorMessage);
        startOtpResendCountdown(seconds);

        Get.snackbar(
          'Please Wait',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP via SMS
  Future<void> sendOTPViaSMS() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your phone number',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Format phone number with country code
      String phone = phoneController.text.trim();
      if (!phone.startsWith('234')) {
        if (phone.startsWith('0')) {
          phone = '234${phone.substring(1)}';
        } else {
          phone = '234$phone';
        }
      }

      if (kDebugMode) {
        print('Sending OTP via SMS to: $phone');
      }

      final response = await ApiService.sendOTPViaSMS(phone: phone);

      if (kDebugMode) {
        print('SMS OTP response: $response');
      }

      // Set verification type and identifier for later verification
      verificationType.value = 'phone';
      verificationMethod.value = 'sms';
      verificationIdentifier.value = phone;

      Get.snackbar(
        'Success',
        'OTP sent to your phone via SMS',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Start countdown timer (default 60 seconds)
      startOtpResendCountdown(60);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Check if it's a rate limit error
      if (errorMessage.toLowerCase().contains('wait') &&
          errorMessage.contains('s')) {
        final seconds = extractSecondsFromError(errorMessage);
        startOtpResendCountdown(seconds);

        Get.snackbar(
          'Please Wait',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP via Email
  Future<void> sendOTPViaEmail(String email) async {
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      if (kDebugMode) {
        print('Sending OTP via Email to: $email');
      }

      final response = await ApiService.sendOTPViaEmail(email: email);

      if (kDebugMode) {
        print('Email OTP response: $response');
      }

      // Set verification type and identifier for later verification
      verificationType.value = 'email';
      verificationMethod.value = 'email';
      verificationIdentifier.value = email;

      Get.snackbar(
        'Success',
        'OTP sent to your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Start countdown timer (default 60 seconds)
      startOtpResendCountdown(60);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Check if it's a rate limit error
      if (errorMessage.toLowerCase().contains('wait') &&
          errorMessage.contains('s')) {
        final seconds = extractSecondsFromError(errorMessage);
        startOtpResendCountdown(seconds);

        Get.snackbar(
          'Please Wait',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> openWhatsApp() async {
    if (whatsappNumber.value.isEmpty || whatsappMessage.value.isEmpty) {
      Get.snackbar(
        'Error',
        'WhatsApp details not available. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      // Format WhatsApp number (remove + and spaces)
      String phone = whatsappNumber.value.replaceAll(RegExp(r'[^\d]'), '');

      // Encode the message
      final encodedMessage = Uri.encodeComponent(whatsappMessage.value);

      // Try WhatsApp app URI first (works better on mobile)
      final whatsappAppUrl =
          'whatsapp://send?phone=$phone&text=$encodedMessage';
      final whatsappWebUrl = 'https://wa.me/$phone?text=$encodedMessage';

      if (kDebugMode) {
        print('Opening WhatsApp: $whatsappAppUrl');
      }

      // Try app URI first
      final appUri = Uri.parse(whatsappAppUrl);
      bool launched = false;

      if (await canLaunchUrl(appUri)) {
        launched = await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If app URI fails, try web URL
      if (!launched) {
        if (kDebugMode) {
          print('App URI failed, trying web URL: $whatsappWebUrl');
        }
        final webUri = Uri.parse(whatsappWebUrl);
        if (await canLaunchUrl(webUri)) {
          launched = await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
        }
      }

      return launched;
    } catch (e) {
      if (kDebugMode) {
        print('Open WhatsApp error: $e');
      }
      return false;
    }
  }

  Future<void> signup({
    required String firstName,
    String? middleName,
    required String lastName,
    required String password,
    String? referralCode,
  }) async {
    isLoading.value = true;

    try {
      // Format phone number with country code
      String phone = phoneController.text.trim();
      if (phone.startsWith('0')) {
        phone = '234${phone.substring(1)}';
      } else if (!phone.startsWith('234')) {
        phone = '234$phone';
      }

      if (kDebugMode) {
        print('🚀 ===== CONTROLLER SIGNUP CALL =====');
        print('🚀 Formatted Phone: $phone');
        print('🚀 First Name: $firstName');
        print(
          '🚀 Middle Name: ${middleName?.isEmpty ?? true ? "(empty)" : middleName}',
        );
        print('🚀 Last Name: $lastName');
        print('🚀 Password Length: ${password.length} characters');
        print(
          '🚀 Referral Code: ${referralCode?.isEmpty ?? true ? "(empty)" : referralCode}',
        );
        print('🚀 ===================================');
      }

      final response = await ApiService.signup(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        phone: phone,
        password: password,
        referralCode: referralCode,
      );

      if (kDebugMode) {
        print('✅ ===== SIGNUP API RESPONSE =====');
        print('✅ Response: $response');
        print('✅ =================================');
      }

      // Store token and user data
      if (response['data'] != null) {
        final data = response['data'];
        final token = data['token'] ?? data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userData = data['user'] ?? {};

        if (token != null) {
          await StorageService.saveAuthData(
            token: token,
            userData: userData,
            refreshToken: refreshToken,
          );
          if (kDebugMode) {
            print('✅ Signup data saved to storage');
          }
        }
      }

      Get.snackbar(
        'Success',
        response['message'] ?? 'Registration completed successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to user home
      Get.offAllNamed('/user-home');
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Check if error is about phone verification
      if (errorMessage.toLowerCase().contains('phone number not verified') ||
          errorMessage.toLowerCase().contains('verify your phone')) {
        Get.snackbar(
          'Verification Required',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate back to WhatsApp verification screen
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offNamed(
            AppRoutes.WHATSAPP_VERIFICATION,
            arguments: phoneController.text,
          );
        });
      } else {
        Get.snackbar(
          'Registration Failed',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void getOtpForTesting() async {
    if (phoneController.text.isEmpty) {
      return;
    }

    try {
      // Format phone number for get-otp (without country code, starting with 0)
      String phone = phoneController.text.trim();
      if (phone.startsWith('234')) {
        phone = '0${phone.substring(3)}';
      } else if (!phone.startsWith('0')) {
        phone = '0$phone';
      }

      final response = await ApiService.getOtp(phone: phone);

      if (kDebugMode) {
        print('OTP for testing: ${response['otp']}');
      }

      Get.snackbar(
        'OTP (Testing)',
        'OTP: ${response['otp']}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Get OTP error: $e');
      }
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void verifyResetOTP() async {
    final otp = otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter the complete 6-digit code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await ApiService.verifyEmailOtp(
        email: emailController.text.trim(),
        otp: otp,
      );

      if (kDebugMode) {
        print('Verify OTP response: $response');
      }

      // Store the reset token
      if (response['token'] != null) {
        resetToken.value = response['token'];
      }

      Get.snackbar(
        'Success',
        'Code verified successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to reset password screen
      Get.toNamed(AppRoutes.RESET_PASSWORD);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetPassword() async {
    if (newPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a new password',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text.length < 8) {
      Get.snackbar(
        'Error',
        'Password must be at least 8 characters',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (resetToken.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid reset session. Please try again',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await ApiService.resetPassword(
        email: emailController.text.trim(),
        token: resetToken.value,
        password: newPasswordController.text,
      );

      if (kDebugMode) {
        print('Reset password response: $response');
      }

      Get.snackbar(
        'Success',
        'Password reset successful',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear controllers
      emailController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      resetToken.value = '';
      for (var controller in otpControllers) {
        controller.clear();
      }

      // Navigate to sign in
      Get.offAllNamed(AppRoutes.SIGNIN);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to OTP text changes
    for (var controller in otpControllers) {
      controller.addListener(() => _checkOtpComplete());
    }

    // Add listener for phone validation
    phoneController.addListener(updatePhoneButtonState);
  }

  @override
  void onClose() {
    phoneController.removeListener(updatePhoneButtonState); // Remove listener
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    referralCodeController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  // Add this method to check if phone input is valid
  void updatePhoneButtonState() {
    isPhoneValid.value = phoneController.text.isNotEmpty;
    if (kDebugMode) {
      print('Phone valid: ${isPhoneValid.value}');
    }
  }

  void _checkOtpComplete() {
    isOtpComplete.value = otpControllers.every(
      (controller) => controller.text.isNotEmpty,
    );
  }

  void selectRole(String role) {
    selectedRole.value = role;
    userType.value = role;
    Get.toNamed(AppRoutes.PHONE_VERIFICATION, arguments: role);
  }

  void verifyPhoneNumber() {
    if (phoneController.text.isEmpty) return;
    // Format phone - ensure we don't add 234 if it's already there
    String phone = phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (phone.startsWith('234')) {
      // Already has country code, use as-is
    } else if (phone.startsWith('0')) {
      phone = '234${phone.substring(1)}';
    } else {
      phone = '234$phone';
    }
    Get.toNamed(
      AppRoutes.WHATSAPP_VERIFICATION,
      arguments: phone,
    );
  }

  void verifyOTP() async {
    final otp =
        otpControllers.take(6).map((controller) => controller.text).join();

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

    isLoading.value = true;

    try {
      final type = verificationType.value;
      final identifier =
          verificationIdentifier.value.isNotEmpty
              ? verificationIdentifier.value
              : phoneController.text.trim();

      if (kDebugMode) {
        print('🔐 ===== VERIFY OTP REQUEST =====');
        print('🔐 Endpoint: POST /auth/verify-otp');
        print('🔐 Verification Type: $type');
        print('🔐 Identifier: $identifier');
        print('🔐 OTP: $otp');
        print('🔐 Payload:');
        print('🔐 {');
        print('🔐   "otp": "$otp",');
        print('🔐   "identifierType": "$type",');
        print('🔐   "identifier": "$identifier"');
        print('🔐 }');
        print('🔐 ===============================');
      }

      // Use the generic verifyOtp endpoint that handles both phone and email
      final response = await ApiService.verifyOtp(
        phone: type == 'phone' ? identifier : null,
        email: type == 'email' ? identifier : null,
        otp: otp,
        identifierType: type,
      );

      if (kDebugMode) {
        print('Verify OTP response: $response');
      }

      final successMessage =
          type == 'email'
              ? 'Email verified successfully'
              : 'Phone number verified successfully';

      Get.snackbar(
        'Success',
        successMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to signup details screen to complete profile
      Get.toNamed(AppRoutes.SIGNUP_DETAILS, arguments: identifier);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void sendForgotPasswordOTP() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await ApiService.forgotPassword(
        email: emailController.text.trim(),
      );

      if (kDebugMode) {
        print('Forgot password response: $response');
      }

      Get.snackbar(
        'Success',
        'Reset code sent to your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to OTP verification screen
      Get.toNamed(AppRoutes.REST_PASSWORD);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resendForgotPasswordOTP() {
    sendForgotPasswordOTP();
  }

  void navigateToSignIn() {
    Get.toNamed(AppRoutes.SIGNIN);
  }

  // Methods for role selection in signin
  void selectRoleForSignIn(String role) {
    selectedRole.value = role;
    userType.value = role;
  }

  void navigateToHomeOwner() {
    selectRole('Home Owner');
  }

  void navigateToRealtor() {
    selectRole('Realtor');
  }

  void navigateToUser() {
    try {
      selectRole('User');
    } catch (e) {
      if (kDebugMode) {
        print('Navigation error: $e');
      }
      Get.snackbar(
        'Error',
        'Could not navigate to user registration.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void startKYCVerification() {
    currentKYCStep.value = 0;
    Get.toNamed(AppRoutes.KYC_VERIFICATION);
  }

  void selectDocumentType(String type) {
    selectedDocumentType.value = type;
  }

  void updateReferralCodeState() {
    isReferralCodeValid.value = referralCodeController.text.length >= 6;
  }

  void submitReferralCode() {
    if (isReferralCodeValid.value) {
      // TODO: Implement referral code verification logic
      Get.back(); // Close bottom sheet
      Get.snackbar(
        'Success',
        'Referral code applied successfully',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Error',
        'Please enter a valid referral code',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void uploadDocument() {
    // TODO: Implement document upload logic
    currentKYCStep.value++;
  }

  void uploadSelfie() {
    // TODO: Implement selfie upload logic
    currentKYCStep.value++;
  }

  void uploadAddressProof() {
    // TODO: Implement address proof upload logic
    currentKYCStep.value++;
    completeKYCVerification();
  }

  void completeKYCVerification() {
    // TODO: Submit all collected KYC data to backend
    Get.snackbar(
      'Success',
      'KYC verification completed successfully',
      snackPosition: SnackPosition.TOP,
    );
    Get.offAllNamed(AppRoutes.kycSuccess);
  }
}
