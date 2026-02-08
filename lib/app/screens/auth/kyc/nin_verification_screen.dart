import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../services/kyc_service.dart';

class NINVerificationScreen extends StatefulWidget {
  const NINVerificationScreen({super.key});

  @override
  State<NINVerificationScreen> createState() => _NINVerificationScreenState();
}

class _NINVerificationScreenState extends State<NINVerificationScreen> {
  final _ninController = TextEditingController();
  final _isLoading = false.obs;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _ninController.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      isButtonEnabled = _ninController.text.length == 11;
    });
  }

  @override
  void dispose() {
    _ninController.dispose();
    super.dispose();
  }

  void _submitNIN() async {
    if (_ninController.text.length == 11) {
      _isLoading.value = true;

      try {
        // Simulate API call delay
        await Future.delayed(const Duration(seconds: 2));

        // Print NIN information to terminal
        print('═══════════════════════════════════════════════════════');
        print('KYC VERIFICATION - NIN SUBMISSION');
        print('═══════════════════════════════════════════════════════');
        print('NIN: ${_ninController.text.trim()}');
        print('Timestamp: ${DateTime.now()}');
        print('═══════════════════════════════════════════════════════');

        // TODO: Send NIN to backend for verification

        // Save NIN to local storage
        await KYCService().saveNIN(_ninController.text.trim());

        _isLoading.value = false;

        // Navigate to KYC success screen
        Get.offAllNamed(AppRoutes.kycSuccess);
      } catch (e) {
        _isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to verify NIN. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _showNINCheckMethods() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.06,
          vertical: Get.height * 0.03,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: Get.width * 0.035,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    height: 1.5,
                  ),
                  children: const [
                    TextSpan(
                      text:
                          'To check your National Identification Number (NIN) using the USSD code, you can dial ',
                    ),
                    TextSpan(
                      text: '*346#',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ' on your phone. You can also check your NIN using the ',
                    ),
                    TextSpan(
                      text: 'NIMC mobile app',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ', the '),
                    TextSpan(
                      text: 'NIMC website',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ', or the '),
                    TextSpan(
                      text: 'NIN Status Portal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              SizedBox(height: Get.height * 0.03),
              Text(
                'Steps to check your NIN using the USSD code',
                style: TextStyle(
                  fontSize: Get.width * 0.045,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '• Dial *346#\n• Select "NIN Retrieval" by typing "1"\n• Follow the steps displayed on your screen\n• Provide the required inputs',
                  style: TextStyle(
                    fontSize: Get.width * 0.035,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.03),
              Text(
                'Other ways to check your NIN',
                style: TextStyle(
                  fontSize: Get.width * 0.045,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '• Visit any NIMC office\n• Download the NIMC mobile app and follow the instructions\n• Visit the NIN Status Portal by visiting https://nin.mtn.ng/nin/status\n• Visit MTN\'s corporate website https://mtn.ng/\n• Use the myMTNApp\n• Use Zigi',
                  style: TextStyle(
                    fontSize: Get.width * 0.035,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.04),
              Text(
                'The NIN is an 11-digit number that is randomly assigned to an individual when they enroll into the National Identity Database (NIDB).',
                style: TextStyle(
                  fontSize: Get.width * 0.035,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
              SizedBox(height: Get.height * 0.03),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Ok',
                    style: TextStyle(
                      fontSize: Get.width * 0.045,
                      fontFamily: 'ProductSans',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.06,
                vertical: Get.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Verify\nyour Identity',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 40,
                      height: 1.2,
                      letterSpacing: 0,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'To verify your identity with your NIN, kindly enter your 11-digit NIN number below.',
                    style: TextStyle(
                      fontFamily: 'ProductSans Light',
                      fontWeight: FontWeight.w300,
                      fontSize: 15.0,
                      height: 1.0,
                      letterSpacing: 0.0,
                      color: Colors.black,
                    ),
                  ),
                  
                  SizedBox(height: Get.height * 0.03),
                  
                  // NIN Icon/Image
                  Center(
                    child: Image.asset(
                      'assets/image/icon 1.png',
                      width: 280,
                      height: 280,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image not found
                        return Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.badge_outlined,
                            size: 120,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: Get.height * 0.04),
                  
                  // NIN Input Field
                  TextField(
                    controller: _ninController,
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      hintText: 'Enter your 11-digit NIN',
                      counterText: '',
                      fillColor: const Color(0xFFF8F8F8),
                      hintStyle: const TextStyle(
                        fontFamily: 'ProductSans Light',
                        fontWeight: FontWeight.w300,
                        color: Color(0xFFBDBDBD),
                      ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: Get.height * 0.05),
                  
                  // Help Link
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Can't find my NIN no.?\n",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'ProductSans',
                            ),
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _showNINCheckMethods,
                              child: const Text(
                                'Check here?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontFamily: 'ProductSans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: Get.height * 0.04),
                  
                  // Submit Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: 
                            _isLoading.value
                                ? null
                                : (isButtonEnabled ? _submitNIN : null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: const Color(0xFFF8F8F8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 22,
                                  letterSpacing: 0,
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
        ),
      ),
    );
  }
}
