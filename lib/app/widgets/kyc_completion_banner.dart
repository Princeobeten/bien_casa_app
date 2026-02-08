import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kyc_controller.dart';
import '../routes/app_routes.dart';

class KYCCompletionBanner extends StatelessWidget {
  const KYCCompletionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final kycController = Get.put(KYCController());

    return Obx(() {
      if (kycController.isKYCCompleted) {
        return const SizedBox.shrink();
      }

      final steps = [
        {
          'headline': 'Verify your email',
          'subtitle': 'Get updates and keep your account secure',
          'icon': Icons.email_outlined,
          'title': 'Verify Email',
          'isCompleted': kycController.emailVerified.value,
          'onTap': () async {
            await Get.toNamed(AppRoutes.EMAIL_VERIFICATION);
          },
        },
        {
          'headline': 'Confirm your identity',
          'subtitle': 'Link your NIN to verify your identity and unlock all features',
          'icon': Icons.badge_outlined,
          'title': 'Verify NIN',
          'isCompleted': kycController.ninSet.value,
          'onTap': () async {
            await Get.toNamed(AppRoutes.NIN_VERIFICATION);
          },
        },
        {
          'headline': 'Secure your wallet',
          'subtitle': 'Set a PIN to protect your funds and enable transactions',
          'icon': Icons.lock_outline,
          'title': 'Setup Wallet PIN',
          'isCompleted': kycController.walletCreated.value,
          'onTap': () async {
            await Get.toNamed(AppRoutes.WALLET_PIN_SETUP);
          },
        },
      ];

      int currentStepIndex = steps.indexWhere(
        (step) => !(step['isCompleted'] as bool),
      );
      if (currentStepIndex == -1) currentStepIndex = steps.length - 1;

      final currentStep = steps[currentStepIndex];

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: currentStep['onTap'] as VoidCallback,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.06),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Spotlight gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: RadialGradient(
                          center: const Alignment(0.6, 0.3),
                          radius: 1.2,
                          colors: [
                            const Color.fromARGB(
                              255,
                              255,
                              231,
                              238,
                            ).withValues(alpha: 0.18),
                            const Color.fromARGB(
                              255,
                              255,
                              225,
                              225,
                            ).withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
                        child: Row(
                          children: [
                            // Step badge
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${currentStepIndex + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'ProductSans',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Title + subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentStep['headline'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'ProductSans',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentStep['subtitle'] as String,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                      fontSize: 12,
                                      fontFamily: 'ProductSans Light',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Icon (moved to right)
                            Icon(
                              currentStep['icon'] as IconData,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 24,
                            ),
                            const SizedBox(width: 8), 
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                      // Progress accent line
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        child: LinearProgressIndicator(
                          value: kycController.completionPercentage / 100,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
