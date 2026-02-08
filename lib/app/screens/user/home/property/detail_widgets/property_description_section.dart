import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'area_ranking_widget.dart';
import 'agent_info_card.dart';
import 'property_title_section.dart';
import 'property_specifications_row.dart';
import 'property_price.dart';

class PropertyDescriptionSection extends StatefulWidget {
  final String description;
  final List<dynamic> features;
  final List<dynamic> landmarks;

  const PropertyDescriptionSection({
    super.key,
    required this.description,
    required this.features,
    required this.landmarks,
  });

  @override
  State<PropertyDescriptionSection> createState() =>
      _PropertyDescriptionSectionState();
}

class _PropertyDescriptionSectionState
    extends State<PropertyDescriptionSection> {
  void _showDetailBottomSheet() {
    final Map<String, dynamic> property = Get.arguments ?? {};

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

                // Property Title Section
                PropertyTitleSection(property: property),

                const SizedBox(height: 20),

                // Property Specifications Row
                PropertySpecificationsRow(features: property['features'] ?? []),

                const SizedBox(height: 20),

                // Description with Features and Landmarks always visible
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontFamily: 'ProductSans Light',
                        fontSize: 14,
                        color: Color(0xff6B6B6B),
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.32,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Features - Always visible in bottom sheet
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '• ${feature['name']}',
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            color: Color(0xff6B6B6B),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Landmarks - Always visible in bottom sheet
                    const Text(
                      'Landmarks',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.landmarks.map(
                      (landmark) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '• $landmark',
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            color: Color(0xff6B6B6B),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Area Ranking
                AreaRankingWidget(rating: property['rating'] ?? 3.5),

                const SizedBox(height: 24),

                // Agent Information
                AgentInfoCard(sellerProfile: property['sellerProfile']),

                const SizedBox(height: 30),

                // Property Price
                PropertyPrice(property: property),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
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
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: widget.description,
                style: const TextStyle(
                  fontFamily: 'ProductSans Light',
                  fontSize: 14,
                  color: Color(0xff6B6B6B),
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.32,
                  height: 1.4,
                ),
              ),
              TextSpan(
                text: ' read more',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
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
