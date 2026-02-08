import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final currentPage = 0.obs;
  static const String _onboardingCompleteKey = 'onboarding_complete';
  late PageController pageController;
  final String skipButtonImage = 'assets/image/skip_button.png';

  // Lazy loaded onboarding items
  late final List<OnboardingItem> onboardingItems = _initOnboardingItems();

  List<OnboardingItem> _initOnboardingItems() {
    return [
      OnboardingItem(
        image: 'assets/image/Mask_group.png',
        title: 'Explore\nProperties',
        description:
            'Explore a diverse range of listings with smart filters, interactive maps, and detailed insights for your perfect match.',
        buttonImage: 'assets/image/next_button_1.png',
      ),
      OnboardingItem(
        image: 'assets/image/Mask_group_1.png',
        title: 'Co-live\nand Connect',
        description:
            'Find your ideal flat mate based on budget, location, lifestyle preferences. Secure your spot with ease using Quinance escrow payments.',
        buttonImage: 'assets/image/next_button_2.png',
      ),
      OnboardingItem(
        image: 'assets/image/Mask_group_2.png',
        title: 'Trusted\nTransactions',
        description:
            'Trust and transparency with realtor reviews, area rankings, and secure transactions powered by advanced payment solutions.',
        buttonImage: 'assets/image/next_button_3.png',
      ),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize PageController with keepPage true to maintain state
    pageController = PageController(keepPage: true);
    // Pre-cache images
    _precacheImages();
  }

  void _precacheImages() {
    for (var item in onboardingItems) {
      precacheImage(AssetImage(item.image), Get.context!);
      precacheImage(AssetImage(item.buttonImage), Get.context!);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < onboardingItems.length - 1) {
      currentPage.value++;
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void skipOnboarding() => completeOnboarding();

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    Get.offAllNamed(AppRoutes.WELCOME);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }
}

class OnboardingItem {
  final String image;
  final String title;
  final String description;
  final String buttonImage;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonImage,
  });
}
