import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class FlatmateHeaderImage extends StatefulWidget {
  final Map<String, dynamic> match;

  const FlatmateHeaderImage({super.key, required this.match});

  @override
  State<FlatmateHeaderImage> createState() => _FlatmateHeaderImageState();
}

class _FlatmateHeaderImageState extends State<FlatmateHeaderImage> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<String> _images;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    // Initialize images list
    _images = [
      widget.match['image'] ??
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d',
      'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7',
    ];

    // Filter out any null values
    _images = _images.where((img) => img.isNotEmpty).toList();

    print('FlatmateHeaderImage: Loaded ${_images.length} images');

    // Initialize page controller
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);

    // Start auto-scrolling timer after a brief delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    // Auto-scroll every 5 seconds
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_images.length <= 1) return;

      // Calculate next index with wrap-around
      final nextIndex = (_currentIndex + 1) % _images.length;

      // Only proceed if controller is attached to widget
      if (_pageController.hasClients) {
        print('FlatmateHeaderImage: Auto-scrolling to page $nextIndex');
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Cancel timer to prevent memory leaks
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Show full-screen image gallery
  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              body: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Full-screen image
                    Center(
                      child: PageView.builder(
                        controller: PageController(initialPage: _currentIndex),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.network(
                              _images[index],
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) => const Center(
                                    child: Icon(
                                      Icons.error,
                                      size: 50,
                                      color: Colors.white54,
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image carousel with swipe functionality
            GestureDetector(
              onTap: () => _showFullScreenImage(context),
              child: PageView.builder(
                controller: _pageController,
                physics:
                    const ClampingScrollPhysics(), // Better swipe experience
                itemCount: _images.length,
                onPageChanged: (index) {
                  print('FlatmateHeaderImage: Page changed to $index');
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    _images[index],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                  );
                },
              ),
            ),

            // Bottom gradient overlay ONLY (not full image)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 200, // Adjusted to only cover bottom portion
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),

            // User info overlay at the bottom of the image
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and age
                    Text(
                      '${widget.match['name']}, ${widget.match['age']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'ProductSans',
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Gender, Religion, Occupation
                    Text(
                      '${widget.match['gender']} | ${widget.match['religion']} | ${widget.match['occupation']}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'ProductSansLight',
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Budget with Naira icon and Location on same row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/naira.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 1.75),
                            Text(
                              widget.match['budget'] ??
                                  widget.match['income'] ??
                                  '400,000 - 600,000/year',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        // Location with icon
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 1.75),
                            Text(
                              widget.match['location'] ?? 'Abuja, Nigeria',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontFamily: 'ProductSansLight',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Dynamic image progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _images.length,
                        (index) => Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color:
                                  index == _currentIndex
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 30, left: 20.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          iconSize: 12,
          onPressed: () => Get.back(),
        ),
      ),
    );
  }
}
