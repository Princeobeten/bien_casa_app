import 'dart:async';
import 'package:bien_casa/app/screens/user/home/heart_icon.dart';
import 'package:bien_casa/app/screens/user/home/gallery_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'full_screen_gallery.dart';

class PropertyHeaderImage extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyHeaderImage({super.key, required this.property});

  @override
  State<PropertyHeaderImage> createState() => _PropertyHeaderImageState();
}

class _PropertyHeaderImageState extends State<PropertyHeaderImage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<String> _images = [];
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    // Initialize images list
    if (widget.property['photos'] != null &&
        widget.property['photos'] is List &&
        (widget.property['photos'] as List).isNotEmpty) {
      _images = List<String>.from(widget.property['photos']);
    } else {
      // Fallback to placeholder if no images are provided
      _images = ['assets/image/house.png'];
    }

    // Start auto-slide timer if there are multiple images
    if (_images.length > 1) {
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    // Auto-slide every 5 seconds
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  @override
  void dispose() {
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  void _showFullScreenGallery(BuildContext context, int initialIndex) {
    print('_showFullScreenGallery called with initialIndex: $initialIndex');
    print('Images to show: $_images');
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          print('Building FullScreenGallery route');
          return FullScreenGallery(images: _images, initialIndex: initialIndex);
        },
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    String selectedReason = 'Incorrect Information';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Report Property',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Reason dropdown
                const Text(
                  'Reason',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      isExpanded: true,
                      items: [
                        'Incorrect Information',
                        'Fraudulent Listing',
                        'Property Not Available',
                        'Inappropriate Content',
                        'Other',
                      ].map((reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedReason = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Additional details
                const Text(
                  'Additional Details (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Provide more details...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'ProductSans',
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Submit report to backend
                          Get.snackbar(
                            'Report Submitted',
                            'Thank you for reporting. We will review this property.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      floating: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Property image carousel
            PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                // Wrap the image in a Stack to handle both tap events and auto-slide
                return Stack(
                  children: [
                    // Image widget
                    _images[index].startsWith('http')
                        ? Image.network(
                          _images[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              'Error loading network image: ${_images[index]}',
                            );
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('Image not found'),
                              ),
                            );
                          },
                        )
                        : Image.asset(
                          _images[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              'Error loading asset image: ${_images[index]}',
                            );
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('Image not found'),
                              ),
                            );
                          },
                        ),

                    // Transparent overlay for tap detection
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white24,
                          onTap: () {
                            print('Simple onTap detected on image $index');
                            _showFullScreenGallery(context, index);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Gradient overlay for better visibility of icons
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
            // Progress indicator dots
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                  (index) => Container(
                    width: 67,
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color:
                          _currentPage == index
                              ? Colors.white
                              : Color(0xffBDBDBD),
                    ),
                  ),
                ),
              ),
            ),
            // Debug button to test FullScreenGallery
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
      actions: [
        // View gallery icon
        Padding(
          padding: const EdgeInsets.only(top: 30, right: 10.0),
          child: GalleryIcon(
            isWhite: false,
            size: 32.0,
            padding: 6.0,
            iconSize: 16.0,
            images: _images,
            currentIndex: _currentPage,
          ),
        ),
        // Favorite icon
        Padding(
          padding: const EdgeInsets.only(top: 30, right: 10.0),
          child: HeartIcon(
            isWhite: false,
            propertyId: widget.property['id']?.toString(),
          ),
        ),
        // Report button
        Padding(
          padding: const EdgeInsets.only(top: 30, right: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.flag_outlined, color: Colors.white, size: 20),
              onPressed: () => _showReportDialog(context),
            ),
          ),
        ),
      ],
    );
  }
}
