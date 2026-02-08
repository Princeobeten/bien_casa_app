import 'package:bien_casa/app/data/property_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'detail_widgets/property_header_image.dart';
import 'detail_widgets/property_title_section.dart';
import 'detail_widgets/property_specifications_row.dart';
import 'detail_widgets/property_description_section.dart';
import 'detail_widgets/area_ranking_widget.dart';
import 'detail_widgets/agent_info_card.dart';
import 'detail_widgets/property_price.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/property_converter.dart';

class PropertyDetailScreen extends StatelessWidget {
  PropertyDetailScreen({super.key})
    : property =
          Get.arguments != null
              ? Get.arguments as Map<String, dynamic>
              : PropertyData.defaultProperty;

  final Map<String, dynamic> property;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh
        slivers: [
          // Add pull-to-refresh functionality
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              // Reload property data
              print('Refreshing property details');
              // Here you would typically fetch fresh data from your controller
              // For now, we'll just simulate a delay
              await Future.delayed(const Duration(seconds: 1));
            },
          ),

          // Property Header Image
          PropertyHeaderImage(property: property),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 26,
                right: 26,
                bottom: 50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Title Section
                  PropertyTitleSection(property: property),

                  const SizedBox(height: 20),

                  // Property Specifications Row
                  PropertySpecificationsRow(
                    features: property['features'] ?? [],
                  ),

                  const SizedBox(height: 20),

                  // Property Description Section
                  PropertyDescriptionSection(
                    description: property['description'] ?? '',
                    features: property['features'] ?? [],
                    landmarks: property['landmarks'] ?? [],
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

                  const SizedBox(height: 30),

                  // Action Buttons
                  Column(
                    children: [
                      // Schedule Inspection Button
                      SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff020202),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to inspection request screen
                            try {
                              print('Property data for inspection: $property');
                              final houseLease = PropertyConverter.convertToHouseLease(property);
                              print('Converted HouseLease: ${houseLease.toJson()}');
                              Get.toNamed(
                                AppRoutes.INSPECTION_REQUEST,
                                arguments: houseLease,
                              );
                            } catch (e, stackTrace) {
                              print('Error converting property for inspection: $e');
                              print('Stack trace: $stackTrace');
                              print('Property data: $property');
                              Get.snackbar(
                                'Error',
                                'Unable to process property data: ${e.toString()}',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 5),
                              );
                            }
                          },
                          child: const Text(
                            'Schedule inspection',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hold Property Button
                      SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xff020202),
                            side: const BorderSide(
                              color: Color(0xff020202),
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to hold payment screen
                            try {
                              final houseLease = PropertyConverter.convertToHouseLease(property);
                              Get.toNamed(
                                AppRoutes.HOLD_PAYMENT,
                                arguments: houseLease,
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Unable to process property data',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_clock, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'Hold Property',
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Apply for Lease Button
                      SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff29BCA2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            // Convert property map to HouseLease model
                            try {
                              // Use PropertyConverter to handle both old and new formats
                              final houseLease = PropertyConverter.convertToHouseLease(property);
                              Get.toNamed(
                                AppRoutes.LEASE_APPLICATION,
                                arguments: houseLease,
                              );
                            } catch (e, stackTrace) {
                              Get.snackbar(
                                'Error',
                                'Unable to process property data: ${e.toString()}',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                              );
                              print('Error converting property to HouseLease: $e');
                              print('Stack trace: $stackTrace');
                            }
                          },
                          child: const Text(
                            'Apply for Lease',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
