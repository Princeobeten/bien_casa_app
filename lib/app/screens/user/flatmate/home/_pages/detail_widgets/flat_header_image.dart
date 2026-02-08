import 'package:bien_casa/app/controllers/flatmate_match_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class FlatHeaderImage extends StatefulWidget {
  final Map<String, dynamic> flat;

  const FlatHeaderImage({super.key, required this.flat});

  @override
  State<FlatHeaderImage> createState() => _FlatHeaderImageState();
}

class _FlatHeaderImageState extends State<FlatHeaderImage> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  final List<String> _imageList = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
    _pageController = PageController(initialPage: 0);
    // Start auto-scroll timer
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_imageList.isNotEmpty && _pageController.hasClients) {
        _pageController.animateToPage(
          (_currentPage + 1) % _imageList.length,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _loadImages() {
    // Default image from flat data
    if (widget.flat['image'] != null) {
      _imageList.add(widget.flat['image']);
    }

    // Add more images if available in flat data
    if (widget.flat['images'] != null && widget.flat['images'] is List) {
      _imageList.addAll(List<String>.from(widget.flat['images']));
    } else {
      // Fallback images if none provided
      _imageList.addAll([
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        'https://images.unsplash.com/photo-1581858726788-75bc0f6a952d',
      ]);
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Image
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
              // Close button
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        // Favorite button
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              // Check directly from flat data if it's favorited
              (widget.flat['isFavorite'] == true)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color:
                  (widget.flat['isFavorite'] == true)
                      ? Colors.red
                      : Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            // Toggle favorite status using the controller
            Get.find<FlatmateMatchController>().toggleFlatFavorite(
              widget.flat['id'],
            );

            // Update local state to reflect the change immediately
            setState(() {
              widget.flat['isFavorite'] = !(widget.flat['isFavorite'] == true);
            });
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image carousel
            GestureDetector(
              onTap:
                  () => _showFullScreenImage(context, _imageList[_currentPage]),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _imageList.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    _imageList[index],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.home,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                  );
                },
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // Progress indicators at the bottom
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_imageList.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),

            // Flat details at bottom
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flat name
                  Text(
                    '${widget.flat['bedrooms']} Bedroom Flat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < (widget.flat['rating'] ?? 0)
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.flat['rating'] ?? 0}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price and location in one row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NGN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ProductSans',
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${widget.flat['price'] ?? "500,000"}${widget.flat['isShortStay'] == true ? "/day" : "/yr"}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ProductSans',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.flat['location'] ?? 'Location not specified',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'ProductSans',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
