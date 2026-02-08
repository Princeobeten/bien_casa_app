import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/home_owner_controller.dart';

class HomeOwnerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeOwnerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeOwnerController>(
      builder: (controller) {
        return Container(
          constraints: const BoxConstraints(minHeight: 76),
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.only(top: 5),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'ProductSans',
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/solar--buildings-3-line-duotone.svg',
                  colorFilter: ColorFilter.mode(
                    currentIndex == 0 ? Colors.black : Colors.grey,
                    BlendMode.srcIn,
                  ),
                  height: 25,
                ),
                label: 'Properties',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/clipboard.svg',
                      colorFilter: ColorFilter.mode(
                        currentIndex == 1 ? Colors.black : Colors.grey,
                        BlendMode.srcIn,
                      ),
                      height: 25,
                    ),
                    if (controller.pendingRequests > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${controller.pendingRequests}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/message.svg',
                      colorFilter: ColorFilter.mode(
                        currentIndex == 2 ? Colors.black : Colors.grey,
                        BlendMode.srcIn,
                      ),
                      height: 25,
                    ),
                    if (controller.unreadMessages > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${controller.unreadMessages}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/wallet.svg',
                  colorFilter: ColorFilter.mode(
                    currentIndex == 3 ? Colors.black : Colors.grey,
                    BlendMode.srcIn,
                  ),
                  height: 25,
                ),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/profile icon.svg',
                  colorFilter: ColorFilter.mode(
                    currentIndex == 4 ? Colors.black : Colors.grey,
                    BlendMode.srcIn,
                  ),
                  height: 25,
                ),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
