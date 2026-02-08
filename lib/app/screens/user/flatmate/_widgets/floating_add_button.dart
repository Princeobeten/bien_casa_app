import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class FloatingAddButton extends StatefulWidget {
  final String routeName;
  final Map<String, dynamic>? arguments;

  const FloatingAddButton({super.key, required this.routeName, this.arguments});

  @override
  State<FloatingAddButton> createState() => _FloatingAddButtonState();
}

class _FloatingAddButtonState extends State<FloatingAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 20,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Glowing effect
                // BoxShadow(
                //   color: Colors.black.withOpacity(0.3),
                //   blurRadius: 20,
                //   spreadRadius: 5,
                // ),
                BoxShadow(
                  color: const Color(0xFF29BCA2).withOpacity(_glowAnimation.value),
                  blurRadius: 30,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                // Navigate to Create Campaign page using route
                Get.toNamed(AppRoutes.ADD_FLATMATE);
              },
              backgroundColor: Colors.white,
              elevation: 8,
              child: const Icon(Icons.add_rounded, size: 35, color: Colors.black),
            ),
          );
        },
      ),
    );
  }
}
