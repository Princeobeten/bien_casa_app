import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile picture skeleton
            const SkeletonLoader(
              width: 100,
              height: 100,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            const SizedBox(height: 16),
            // Name skeleton
            const SkeletonLoader(width: 150, height: 24),
            const SizedBox(height: 8),
            // User type skeleton
            const SkeletonLoader(width: 80, height: 16),
            const SizedBox(height: 16),
            // Bio skeleton
            const SkeletonLoader(width: double.infinity, height: 60),
            const SizedBox(height: 32),
            // Menu items skeleton
            ...List.generate(
              8,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const SkeletonLoader(width: 24, height: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SkeletonLoader(
                        width: double.infinity,
                        height: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalInfoSkeletonLoader extends StatelessWidget {
  const PersonalInfoSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile picture skeleton
            const SkeletonLoader(
              width: 100,
              height: 100,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            const SizedBox(height: 32),
            // Form fields skeleton
            ...List.generate(
              7,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SkeletonLoader(
                  width: double.infinity,
                  height: index == 6 ? 100 : 60,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletSkeletonLoader extends StatelessWidget {
  const WalletSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Wallet Card Skeleton
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(bottom: 24),
              child: const SkeletonLoader(
                width: double.infinity,
                height: 200,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            
            // Quick Actions Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (index) => Column(
                  children: [
                    SkeletonLoader(
                      width: 60,
                      height: 60,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    const SizedBox(height: 8),
                    const SkeletonLoader(width: 60, height: 12),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Recent Activities Header Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonLoader(width: 150, height: 20),
                const SkeletonLoader(width: 60, height: 16),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recent Activities List Skeleton
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    SkeletonLoader(
                      width: 45,
                      height: 45,
                      borderRadius: BorderRadius.circular(22.5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonLoader(width: double.infinity, height: 16),
                          const SizedBox(height: 6),
                          SkeletonLoader(
                            width: 100,
                            height: 12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SkeletonLoader(width: 80, height: 16),
                        SizedBox(height: 6),
                        SkeletonLoader(width: 60, height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavSkeletonLoader extends StatelessWidget {
  const BottomNavSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Banner Skeleton
          Container(
            width: double.infinity,
            height: 120,
            margin: const EdgeInsets.only(bottom: 16),
            child: const SkeletonLoader(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          
          // Search Bar Skeleton
          const SkeletonLoader(
            width: double.infinity,
            height: 50,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          
          const SizedBox(height: 16),
          
          // Filter Buttons Skeleton
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(4, (index) => Container(
                margin: EdgeInsets.only(right: index < 3 ? 10 : 0),
                child: const SkeletonLoader(
                  width: 100,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              )),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Featured Property Skeleton
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: const SkeletonLoader(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Section Header Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonLoader(width: 200, height: 20),
              const SkeletonLoader(width: 60, height: 16),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Property Cards Skeleton
          SizedBox(
            height: 250,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(3, (index) => Container(
                margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
                child: const SkeletonLoader(
                  width: 200,
                  height: 250,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
