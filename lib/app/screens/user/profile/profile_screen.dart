import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/kyc_completion_banner.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../../controllers/home_owner_controller.dart';
import '../../../controllers/app_mode_controller.dart';
import '../../../controllers/user_profile_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/kyc_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/biometric_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // Profile tab is index 4
  final _kycService = KYCService();
  late UserProfileController _profileController;
  bool _biometricEnabled = false;
  bool _biometricLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    // Ensure AppModeController is initialized
    if (!Get.isRegistered<AppModeController>()) {
      Get.put(AppModeController(), permanent: true);
    }
    
    // Initialize UserProfileController
    if (Get.isRegistered<UserProfileController>()) {
      _profileController = Get.find<UserProfileController>();
    } else {
      _profileController = Get.put(UserProfileController());
    }
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final canUse = await BiometricService.canCheckBiometrics();
    final enabled = await BiometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = canUse;
        _biometricEnabled = enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppModeController>(
      init: Get.find<AppModeController>(),
      builder: (controller) {
        // Show skeleton loader while loading profile
        return Obx(() {
          if (_profileController.isLoading.value && _profileController.userProfile.isEmpty) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (controller.isHomeOwnerMode) {
                      Get.offAllNamed('/home-owner-main');
                    } else {
                      Get.offAllNamed('/user-home');
                    }
                  },
                  child: const Icon(
                    CupertinoIcons.back,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                centerTitle: true,
                title: const Text(
                  'User profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              body: const ProfileSkeletonLoader(),
            );
          }
          
          return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (controller.isHomeOwnerMode) {
                  Get.offAllNamed('/home-owner-main');
                } else {
                  Get.offAllNamed('/user-home');
                }
              },
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.black,
                size: 28,
              ),
            ),
            centerTitle: true,
            title: const Text(
              'User profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'ProductSans',
              ),
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/profile/Edit icon Vector.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  // Navigate to personal information in edit mode
                  Get.toNamed(
                    AppRoutes.PERSONAL_INFORMATION,
                    arguments: true, // isEditMode = true
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Profile Header
                Column(
                  children: [
                    // Profile Picture with fallback
                    Obx(() => Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFB6C1),
                      ),
                      child: ClipOval(
                        child: _profileController.profilePhoto.isNotEmpty
                            ? Image.network(
                                _profileController.profilePhoto,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderAvatar();
                                },
                              )
                            : _buildPlaceholderAvatar(),
                      ),
                    )),
                    const SizedBox(height: 16),

                    // Name with verified badge
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _profileController.fullName.isEmpty 
                              ? 'User' 
                              : _profileController.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ProductSans',
                          ),
                        ),
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          'assets/icons/profile/verified.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    )),
                    const SizedBox(height: 4),

                    // User type
                    const Text(
                      'User',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'I\'m easygoing and reliable, I enjoy organized spaces and smooth living. Always on the lookout for the right place and great vibes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontFamily: 'ProductSans',
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // KYC Completion Banner (only show if not completed)
                    if (!_kycService.isKYCCompleted()) ...[
                      const KYCCompletionBanner(),
                      const SizedBox(height: 16),
                    ],

                    // Home Owner Toggle
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            controller.isHomeOwnerMode
                                ? const Color(0xFFE8F5E8)
                                : const Color(0xFFE0F7F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            controller.isHomeOwnerMode
                                ? Icons.home_work
                                : Icons.home,
                            color:
                                controller.isHomeOwnerMode
                                    ? Colors.green[800]
                                    : Colors.teal[900],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.isHomeOwnerMode
                                      ? 'Home Owner Mode'
                                      : 'Switch to Home Owner',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        controller.isHomeOwnerMode
                                            ? Colors.green[800]
                                            : Colors.teal[900],
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                                Text(
                                  controller.isHomeOwnerMode
                                      ? 'Manage your properties and tenants'
                                      : 'Access property management features',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        controller.isHomeOwnerMode
                                            ? Colors.green[700]
                                            : Colors.teal[800],
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: controller.isHomeOwnerMode,
                            onChanged: (value) {
                              print('Switch toggled to: $value');
                              // Defer state changes to avoid calling setState during build
                              Future.microtask(() {
                                if (value) {
                                  // Switch to home owner mode
                                  controller.switchToHomeOwnerMode();
                                  print(
                                    'Switched to home owner mode: ${controller.isHomeOwnerMode}',
                                  );
                                  Get.put(HomeOwnerController());
                                  Get.offAllNamed('/home-owner-main');
                                } else {
                                  // Switch to user mode
                                  controller.switchToUserMode();
                                  print(
                                    'Switched to user mode: ${controller.isHomeOwnerMode}',
                                  );
                                  Get.delete<HomeOwnerController>();
                                  Get.offAllNamed('/user-home');
                                }
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Profile update tip
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Keep your profile updated to get tailored listings and faster communication.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.teal[900],
                                fontFamily: 'ProductSans',
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.teal[900]),
                        ],
                      ),
                    ),

                    // Transfer with Biometric toggle
                    if (_biometricAvailable) ...[
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _biometricEnabled ? const Color(0xFFE8F5E9) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.fingerprint,
                              size: 28,
                              color: _biometricEnabled ? Colors.green[700] : Colors.grey[700],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transfer with Biometric',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _biometricEnabled ? Colors.green[800] : Colors.black87,
                                      fontFamily: 'ProductSans',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _biometricEnabled
                                        ? 'Use fingerprint or face to approve withdrawals'
                                        : 'Use fingerprint or face instead of PIN for withdrawals',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontFamily: 'ProductSans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_biometricLoading)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              Switch(
                                value: _biometricEnabled,
                                onChanged: (value) => _onBiometricToggle(value),
                                activeColor: Colors.green,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 32),

                // Menu Items
                _buildMenuItem(
                  icon: 'assets/icons/profile/Vector.svg',
                  title: 'Personal information',
                  onTap: () {
                    // Navigate to personal information in view mode
                    Get.toNamed(
                      AppRoutes.PERSONAL_INFORMATION,
                      arguments: false, // isEditMode = false
                    );
                  },
                ),

                _buildMenuItem(
                  icon: 'assets/icons/green_heart.svg',
                  title: 'My Favourites',
                  onTap: () {
                    Get.toNamed(AppRoutes.FAVORITES);
                  },
                ),
                _buildMenuItem(
                  icon: 'assets/icons/clipboard.svg',
                  title: 'My Applications',
                  onTap: () {
                    Get.toNamed(AppRoutes.MY_APPLICATIONS);
                  },
                ),
                _buildMenuItem(
                  icon: 'assets/icons/f7--building-2.svg',
                  title: 'My Inspections',
                  onTap: () {
                    Get.toNamed(AppRoutes.MY_INSPECTIONS);
                  },
                ),
                _buildMenuItem(
                  icon: 'assets/icons/home.svg',
                  title: 'My Leases',
                  onTap: () {
                    Get.toNamed(AppRoutes.MY_LEASES);
                  },
                ),
                _buildMenuItem(
                  icon: 'assets/icons/document.svg',
                  title: 'My Documents',
                  onTap: () {
                    Get.toNamed(AppRoutes.MY_DOCUMENTS);
                  },
                ),
                _buildMenuItem(
                  icon: 'assets/icons/escrow_lock.svg',
                  title: 'Escrow',
                  onTap: () {
                    // Navigate to escrow
                  },
                ),
                _buildMenuItem(
                  icon: 'assets/icons/profile/Vector-4.svg',
                  title: 'Payment method',
                  onTap: () {
                    // Navigate to payment method
                  },
                ),
                _buildMenuItem(
                  icon: 'assets/icons/profile/Vector-5.svg',
                  title: 'Help and Support',
                  onTap: () {
                    // Navigate to help and support
                  },
                ),
                _buildMenuItem(
                  icon: 'assets/icons/profile/Vector-6.svg',
                  title: 'Sign out',
                  onTap: () {
                    _showSignOutDialog();
                  },
                ),
                _buildMenuItem(
                  icon: 'assets/icons/profile/Vector-6.svg',
                  title: 'Delete Account',
                  onTap: () {
                    _showDeleteAccountDialog();
                  },
                  isLast: true,
                  textColor: Colors.red,
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar:
              controller.isHomeOwnerMode
                  ? null
                  : CustomBottomNavBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });

                      switch (index) {
                        case 0:
                          Get.offAllNamed('/user-home');
                          break;
                        case 1:
                          Get.offAllNamed('/flatmate');
                          break;
                        case 2:
                          Get.toNamed('/chat-list');
                          break;
                        case 3:
                          Get.toNamed('/wallet');
                          break;
                        case 4:
                          // Already on profile screen
                          break;
                      }
                    },
                  ),
        );
        });
      },
    );
  }

  Future<void> _onBiometricToggle(bool enable) async {
    setState(() => _biometricLoading = true);
    try {
      if (enable) {
        final authenticated = await BiometricService.authenticateWithBiometric(
          reason: 'Authenticate to enable biometric for withdrawals',
        );
        if (!authenticated) {
          if (mounted) {
            setState(() => _biometricLoading = false);
            Get.snackbar(
              'Cancelled',
              'Biometric is required to enable this feature',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
          return;
        }
        await BiometricService.enableBiometric();
        if (mounted) setState(() => _biometricEnabled = true);
        Get.snackbar(
          'Enabled',
          'You can now use biometric to approve withdrawals',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final authenticated = await BiometricService.authenticateWithBiometric(
          reason: 'Authenticate to disable biometric for withdrawals',
        );
        if (!authenticated) {
          if (mounted) setState(() => _biometricLoading = false);
          return;
        }
        await BiometricService.disableBiometric();
        if (mounted) setState(() => _biometricEnabled = false);
        Get.snackbar(
          'Disabled',
          'Withdrawals will require your PIN',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.grey[700]!,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _biometricLoading = false);
    }
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
    Color? textColor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    textColor ?? Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'ProductSans',
                      color: textColor,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: textColor ?? Colors.grey),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: Colors.grey[200], indent: 60),
      ],
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'ProductSans',
              ),
            ),
            content: const Text(
              'Are you sure you want to sign out?',
              style: TextStyle(fontFamily: 'ProductSans'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  // Clear stored auth data
                  await StorageService.clearAuthData();
                  
                  // Clear all controllers and navigate to welcome screen
                  Get.delete<AppModeController>(force: true);
                  Get.delete<HomeOwnerController>(force: true);
                  Get.delete<UserProfileController>(force: true);
                  Get.offAllNamed(AppRoutes.WELCOME);
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Delete Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'ProductSans',
                color: Colors.red,
              ),
            ),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
              style: TextStyle(fontFamily: 'ProductSans'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Call API to delete account
                  await _profileController.deleteAccount();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
          color: const Color(0xFFFFB6C1),
          child: const Icon(
            Icons.person,
            size: 50,
            color: Colors.white,
          ),);
  }
}
