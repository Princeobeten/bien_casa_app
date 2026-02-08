import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/flatmate_match_controller.dart';
import 'flat_card.dart';

class AvailableFlatsSection extends StatelessWidget {
  // Function to call when View All is tapped
  final VoidCallback onViewAllTap;

  const AvailableFlatsSection({super.key, required this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    // Get the controller to access flat data
    final controller = Get.find<FlatmateMatchController>();

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
                  'Available Flats',
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

          // Horizontal scrollable list of flats
          SizedBox(
            height: 220, // Set appropriate height for the cards
            child: Obx(() {
              // If no flats, show a message
              if (controller.flats.isEmpty) {
                return const Center(
                  child: Text(
                    'No flats available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                );
              }

              // Show horizontal list of flat cards
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount:
                    controller.flats.length > 30 ? 30 : controller.flats.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 182, // Set width for each card
                      child: FlatCard(flat: controller.flats[index]),
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
