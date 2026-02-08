import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_owner_controller.dart';
import '../../controllers/app_mode_controller.dart';
import '../../widgets/home_owner_bottom_nav_bar.dart';
import 'properties/properties_screen.dart';
import 'requests/requests_screen.dart';
import 'messages/messages_screen.dart';
import '../user/wallet/wallet_screen.dart';
import '../user/profile/profile_screen.dart';

class HomeOwnerMainScreen extends StatefulWidget {
  const HomeOwnerMainScreen({super.key});

  @override
  State<HomeOwnerMainScreen> createState() => _HomeOwnerMainScreenState();
}

class _HomeOwnerMainScreenState extends State<HomeOwnerMainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const PropertiesScreen(),
    const RequestsScreen(),
    const MessagesScreen(),
    WalletScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Ensure controllers are initialized
    Get.put(HomeOwnerController());
    // Get existing AppModeController and switch to home owner mode
    // Defer to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appModeController = Get.find<AppModeController>();
      appModeController.switchToHomeOwnerMode();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: HomeOwnerBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
