import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class FlatAboutSection extends StatefulWidget {
  final Map<String, dynamic> flat;

  const FlatAboutSection({super.key, required this.flat});

  @override
  State<FlatAboutSection> createState() => _FlatAboutSectionState();
}

class _FlatAboutSectionState extends State<FlatAboutSection> {
  void _showDetailBottomSheet() {
    Get.bottomSheet(
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Set the bottom sheet to take up 85% of screen height
      FractionallySizedBox(
        heightFactor: 0.85,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Center drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Flat name and location section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.flat['bedrooms']} Bedroom Flat',
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Location row
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/map pin.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.flat['location'] ?? 'Abuja, Nigeria',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'ProductSansLight',
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price row
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/naira.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 1.75),
                        Text(
                          '${widget.flat['price'] ?? "500,000"}${widget.flat['isShortStay'] == true ? "/day" : "/yr"}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Product Sans Light',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // About section
                const Text(
                  'About',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.flat['description'] ??
                      'A beautiful and spacious flat perfect for comfortable living. Features modern amenities and is located in a prime area with easy access to essential services.',
                  style: const TextStyle(
                    fontFamily: 'ProductSans Light',
                    fontSize: 14,
                    color: Color(0xff6B6B6B),
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.32,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Basic Info Section
                _buildInfoSection('Basic', [
                  {
                    'iconPath': 'assets/icons/home.svg',
                    'value': '${widget.flat['bedrooms']} bedrooms',
                  },
                  {
                    'iconPath': 'assets/icons/home.svg',
                    'value': '${widget.flat['bathrooms'] ?? 2} bathrooms',
                  },
                  {
                    'iconPath': 'assets/icons/map pin.svg',
                    'value': '${widget.flat['size'] ?? 120} sqm',
                  },
                  {
                    'iconPath': 'assets/icons/map pin.svg',
                    'value': widget.flat['location'] ?? 'Not specified',
                  },
                ]),

                const SizedBox(height: 24),

                // Features & Amenities
                const Text(
                  'Features & Amenities',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (widget.flat['amenities'] as List).map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        amenity,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      item['iconPath'] as String,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item['value'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'ProductSansLight',
                        color: Color(0xff6B6B6B),
                      ),
                    ),
                  ],
                ),
              ),
            )
            ,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text:
                    widget.flat['description'] != null &&
                            widget.flat['description'].toString().length > 150
                        ? '${widget.flat['description'].toString().substring(0, 150)}...'
                        : (widget.flat['description'] ??
                            'A beautiful and spacious flat perfect for comfortable living...'),
                style: const TextStyle(
                  fontFamily: 'ProductSansLight',
                  fontSize: 14,
                  color: Color(0xff6B6B6B),
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.32,
                  height: 1.4,
                ),
              ),
              TextSpan(
                text: ' Read more',
                style: const TextStyle(
                  fontFamily: 'ProductSansLight',
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.32,
                  height: 1.4,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () {
                        _showDetailBottomSheet();
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
