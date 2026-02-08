import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../routes/app_routes.dart';
import '../controllers/onboarding_controller.dart';
import '../bindings/onboarding_binding.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _navigateToNextScreen();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.7,  // Higher minimum opacity
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,  // Smooth easing
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // Initialize OnboardingBinding manually
    OnboardingBinding().dependencies();

    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final bool onboardingComplete =
        await OnboardingController.isOnboardingComplete();
    if (onboardingComplete) {
      Get.offAllNamed(AppRoutes.WELCOME);
    } else {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: SvgPicture.asset(
                    'assets/image/splash_image.svg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),
            Center(
              child: Image.asset('assets/image/logo.png', width: 100, height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
