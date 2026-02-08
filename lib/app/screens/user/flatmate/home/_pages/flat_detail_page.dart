import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

// Import widget components
import 'detail_widgets/flat_header_image.dart';
import 'detail_widgets/flat_about_section.dart';
import 'detail_widgets/flat_basic_section.dart';
import 'detail_widgets/flat_amenities_section.dart';
import 'detail_widgets/flat_owner_section.dart';
import 'detail_widgets/flat_action_buttons.dart';

class FlatDetailPage extends StatelessWidget {
  const FlatDetailPage({super.key});

  // Helper method to build preference rows in flat details
  Widget _buildPreferenceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff6B6B6B),
              fontWeight: FontWeight.w300,
              fontFamily: 'ProductSansLight',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff000000),
              fontWeight: FontWeight.w300,
              fontFamily: 'ProductSansLight',
            ),
          ),
        ],
      ),
    );
  }

  // Show flat details bottom sheet
  void _showFlatDetails(BuildContext context, Map<String, dynamic> flat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.95, // Almost full screen
            minChildSize: 0.5, // Half screen when dragged down
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header - Looking for right place
                      Text(
                        'Looking for the perfect\nflat for your flatmate?',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 32,
                          leadingDistribution: TextLeadingDistribution.even,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'Find a flat that fits your lifestyle, share costs, and live better together.',
                        style: TextStyle(
                          fontFamily: 'ProductSansLight',
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          leadingDistribution:
                              TextLeadingDistribution.proportional,
                          letterSpacing: -0.32,
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Flat details section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xff29BCA2).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Flat details header
                            const Text(
                              'Flat details',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Property Information
                            const Text(
                              'Property Information',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Property rows
                            _buildPreferenceRow(
                              'Bedrooms',
                              '${flat['bedrooms']}',
                            ),
                            _buildPreferenceRow(
                              'Bathrooms',
                              '${flat['bathrooms'] ?? 2}',
                            ),
                            _buildPreferenceRow(
                              'Size',
                              '${flat['size'] ?? 120} sqm',
                            ),
                            _buildPreferenceRow(
                              'Type',
                              flat['type'] ?? 'Apartment',
                            ),
                            const SizedBox(height: 20),

                            // Location
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildPreferenceRow(
                              'Address',
                              flat['location'] ?? 'Not specified',
                            ),
                            const SizedBox(height: 20),

                            // Price
                            const Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildPreferenceRow(
                              'Annual Rent',
                              '${flat['price']}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Owner section
                      const Text(
                        'Flat Owner',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Owner details section using FlatOwnerSection widget
                      FlatOwnerSection(flat: flat),
                      const SizedBox(height: 32),

                      // Book Now button
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close bottom sheet
                            Get.snackbar(
                              'Book Now',
                              'Processing your booking request',
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'ProductSans',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // Build the bottom action area with view flat button
  Widget _buildBottomActionArea(
    BuildContext context,
    Map<String, dynamic> flat,
  ) {
    return Column(
      children: [
        // View Flat Details button
        Container(
          width: double.infinity,
          height: 70,
          margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
            onPressed: () => _showFlatDetails(context, flat),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'View Flat Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                fontFamily: 'ProductSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the flat data passed as arguments
    final Map<String, dynamic> flat = Get.arguments;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh
        slivers: [
          // Add pull-to-refresh functionality
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              // Reload flat data
              print('Refreshing flat details');
              await Future.delayed(const Duration(seconds: 1));
            },
          ),

          // Profile Image Header
          FlatHeaderImage(flat: flat),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 26,
                right: 26,
                bottom: 80, // Extra space for bottom buttons
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section with Read More functionality
                  FlatAboutSection(flat: flat),

                  const SizedBox(height: 24),

                  // Basic Info Section
                  FlatBasicSection(flat: flat),

                  const SizedBox(height: 24),

                  // Features & Amenities Section
                  FlatAmenitiesSection(flat: flat),

                  const SizedBox(height: 32),

                  // Flat Owner Profile Section with contact buttons
                  FlatOwnerSection(flat: flat),

                  const SizedBox(height: 24),

                  // Bottom action area
                  _buildBottomActionArea(context, flat),

                  // Add some extra padding at bottom of page for better scrolling
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ],
      ),
      // No bottomNavigationBar, buttons moved to content area
    );
  }
}
