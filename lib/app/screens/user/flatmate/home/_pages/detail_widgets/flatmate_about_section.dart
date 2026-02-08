import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class FlatmateAboutSection extends StatefulWidget {
  final Map<String, dynamic> match;

  const FlatmateAboutSection({super.key, required this.match});

  @override
  State<FlatmateAboutSection> createState() => _FlatmateAboutSectionState();
}

class _FlatmateAboutSectionState extends State<FlatmateAboutSection> {
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

                // Name and Age section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.match['name']}, ${widget.match['age']}',
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
                          widget.match['location'] ?? 'Abuja, Nigeria',
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

                // Budget row
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
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
                          widget.match['budget'] ??
                              widget.match['income'] ??
                              '400,000 - 600,000/year',
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
                  widget.match['bio'] ??
                      'Easygoing and friendly. I appreciate a clean and organized space filled with good vibes. I enjoy socializing, whether it\'s sharing a meal, having a good conversation, or unwinding with a movie. At the same time, I respect personal space and quiet moments, making me a great balance between fun and chill. I value open communication, mutual respect, and a positive living environment.',
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
                    'iconPath': 'assets/icons/gender.svg',
                    'value': widget.match['gender'] ?? 'Male',
                  },
                  {
                    'iconPath': 'assets/icons/birthday.svg',
                    'value': '${widget.match['age']} years old',
                  },
                  {
                    'iconPath': 'assets/icons/faith.svg',
                    'value': widget.match['religion'] ?? 'Not specified',
                  },
                  {
                    'iconPath': 'assets/icons/map pin.svg',
                    'value': widget.match['location'] ?? 'Not specified',
                  },
                ]),

                const SizedBox(height: 24),

                // Work Section
                _buildInfoSection('Work', [
                  {
                    'iconPath': 'assets/icons/briefcase.svg',
                    'value': widget.match['occupation'] ?? 'Not specified',
                  },
                ]),

                const SizedBox(height: 24),

                // Language Section
                _buildInfoSection('Language', [
                  {
                    'iconPath': 'assets/icons/language.svg',
                    'value': 'English, Hausa, Yoruba',
                  },
                ]),

                const SizedBox(height: 24),

                // Values Section
                _buildTextSection(
                  'What do you value most in a living environment?',
                  widget.match['values'] ?? 'My privacy',
                ),

                const SizedBox(height: 24),

                // Personality Section
                _buildTextSection(
                  'How would you describe your personality?',
                  widget.match['personality'] ?? 'Introvert',
                ),

                const SizedBox(height: 24),

                // Religion Details Section
                _buildTextSection(
                  'How would you describe your religion?',
                  widget.match['religionDetails'] ??
                      widget.match['religion'] ??
                      'Not specified',
                ),

                const SizedBox(height: 24),

                // Habits Section
                _buildTextSection(
                  'Do you drink or smoke?',
                  widget.match['habits'] ?? 'I don\'t drink, I don\'t smoke',
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

  Widget _buildTextSection(String title, String content) {
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
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            fontFamily: 'ProductSansLight',
            color: Color(0xff6B6B6B),
          ),
        ),
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
                    widget.match['bio'] != null &&
                            widget.match['bio'].toString().length > 150
                        ? '${widget.match['bio'].toString().substring(0, 150)}...'
                        : (widget.match['bio'] ??
                            'Easygoing and friendly. I appreciate a clean and organized space filled with good vibes...'),
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
