import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/flatmate_controller.dart';
import 'flatmate_card.dart';

class AvailableCampaignsSection extends StatelessWidget {
  // Function to call when View All is tapped
  final VoidCallback onViewAllTap;

  const AvailableCampaignsSection({super.key, required this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    // Get the controller to access campaign data from API
    final controller = Get.find<FlatmateController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and View All button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                const Text(
                  'Other Campaigns',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ProductSans',
                  ),
                ),

                // View all button
                GestureDetector(
                  onTap: onViewAllTap,
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Horizontal scrollable list of campaigns
          SizedBox(
            height: 390,
            child: Obx(() {
              // Show loading indicator
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // If no campaigns, show a message
              if (controller.campaigns.isEmpty) {
                return const Center(
                  child: Text(
                    'No campaigns available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                );
              }

              // Show horizontal list of campaign cards
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: controller.campaigns.length > 30
                    ? 30
                    : controller.campaigns.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 255,
                      child: FlatmateCard(campaign: controller.campaigns[index]),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
