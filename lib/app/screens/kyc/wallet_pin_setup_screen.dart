import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/kyc_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';
import '../../services/account_status_service.dart';

class WalletPinSetupScreen extends StatefulWidget {
  const WalletPinSetupScreen({super.key});

  @override
  State<WalletPinSetupScreen> createState() => _WalletPinSetupScreenState();
}

class _WalletPinSetupScreenState extends State<WalletPinSetupScreen> {
  final kycController = Get.find<KYCController>();
  
  // Step tracking
  int _currentStep = 1; // 1 = Create PIN, 2 = Confirm PIN
  
  // PIN values
  String _createPin = '';
  String _confirmPin = '';
  
  // Loading state
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _currentStep == 1 ? 'Create Wallet PIN' : 'Confirm Wallet PIN',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
             fontFamily: 'ProductSans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _currentStep == 1
                ? _buildCreatePinStep()
                : _buildConfirmPinStep(),
      ),
    );
  }

  Widget _buildCreatePinStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title
          Center(
            child: const Text(
              'Create Your Wallet PIN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'ProductSans',
                color: Colors.black,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Center(
            child: const Text(
              'Set up a 4-digit PIN to secure your wallet transactions',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'ProductSans Light',
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // PIN Input Display
          _buildPinDisplay(_createPin),
          
          const Spacer(),
          
          // Number Pad
          _buildNumberPad(
            currentPin: _createPin,
            onPinChanged: (pin) {
              setState(() => _createPin = pin);
              if (pin.length == 4) {
                // Auto-proceed to confirm step
                Future.delayed(const Duration(milliseconds: 300), () {
                  setState(() => _currentStep = 2);
                });
              }
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildConfirmPinStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title
          Center(
            child: const Text(
              'Confirm Your PIN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'ProductSans',
                color: Colors.black,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Center(
            child: const Text(
              'Re-enter your 4-digit PIN to confirm',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'ProductSans Light',
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // PIN Input Display
          _buildPinDisplay(_confirmPin),
          
          const Spacer(),
          
          // Number Pad
          _buildNumberPad(
            currentPin: _confirmPin,
            onPinChanged: (pin) {
              setState(() => _confirmPin = pin);
              if (pin.length == 4) {
                // Auto-verify when 4 digits entered
                _verifyAndSubmitPin();
              }
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPinDisplay(String pin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad({
    required String currentPin,
    required Function(String) onPinChanged,
  }) {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('1', currentPin, onPinChanged),
            _buildNumberButton('2', currentPin, onPinChanged),
            _buildNumberButton('3', currentPin, onPinChanged),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 2: 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4', currentPin, onPinChanged),
            _buildNumberButton('5', currentPin, onPinChanged),
            _buildNumberButton('6', currentPin, onPinChanged),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 3: 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7', currentPin, onPinChanged),
            _buildNumberButton('8', currentPin, onPinChanged),
            _buildNumberButton('9', currentPin, onPinChanged),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 4: Empty, 0, Backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 70, height: 70), // Empty space
            _buildNumberButton('0', currentPin, onPinChanged),
            _buildBackspaceButton(currentPin, onPinChanged),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(
    String number,
    String currentPin,
    Function(String) onPinChanged,
  ) {
    return InkWell(
      onTap: () {
        if (currentPin.length < 4) {
          onPinChanged(currentPin + number);
        }
      },
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(
    String currentPin,
    Function(String) onPinChanged,
  ) {
    return InkWell(
      onTap: () {
        if (currentPin.isNotEmpty) {
          onPinChanged(currentPin.substring(0, currentPin.length - 1));
        }
      },
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 24,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> _verifyAndSubmitPin() async {
    // Check if PINs match
    if (_createPin != _confirmPin) {
      Get.snackbar(
        'PIN Mismatch',
        'The PINs you entered do not match. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Reset to step 1
      setState(() {
        _currentStep = 1;
        _createPin = '';
        _confirmPin = '';
      });
      return;
    }

    // Submit PIN to backend
    setState(() => _isLoading = true);

    try {
      final token = await StorageService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      print('🔐 ===== WALLET PIN SETUP START =====');
      print('🔐 PIN to set: $_createPin');
      print('🔐 Token exists: ${token.isNotEmpty}');
      print('🔐 Token length: ${token.length}');
      print('🔐 Calling processVirtualAccount...');
      print('🔐 ====================================');

      // Call API to process virtual account (create wallet)
      final response = await AccountStatusService.processVirtualAccount(_createPin);

      print('🔐 ===== WALLET PIN SETUP RESPONSE =====');
      print('🔐 Full response: $response');
      print('🔐 Response type: ${response.runtimeType}');
      print('🔐 Response keys: ${response.keys}');
      print('🔐 Message: ${response['message']}');
      print('🔐 Data: ${response['data']}');
      print('🔐 =======================================');

      // Check for success - API returns 201 status code for success
      if (response['message'] != null && response['message'].toString().contains('successfully')) {
        print('🔐 ✅ Success detected! Updating KYC status...');
        
        // Update KYC status
        kycController.walletCreated.value = true;
        await kycController.fetchAccountStatus();
        
        // Show success message with account details
        final accountData = response['data'];
        final successMessage = accountData != null 
            ? 'Wallet created! Account: ${accountData['accountNumber']} (${accountData['bankName']})'
            : response['message'] ?? 'Wallet PIN created successfully!';
        
        print('🔐 Success message: $successMessage');
        
        Get.snackbar(
          'Success',
          successMessage,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Navigate to home and reload
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Get.offAllNamed(AppRoutes.USER_HOME);
          }
        });
      } else {
        print('🔐 ❌ Success not detected in response');
        throw Exception(response['message'] ?? 'Failed to create wallet PIN');
      }
    } catch (e, stackTrace) {
      print('❌ ===== WALLET PIN SETUP ERROR =====');
      print('❌ Error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: $stackTrace');
      print('❌ ====================================');
      
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Reset on error
      setState(() {
        _currentStep = 1;
        _createPin = '';
        _confirmPin = '';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

}
