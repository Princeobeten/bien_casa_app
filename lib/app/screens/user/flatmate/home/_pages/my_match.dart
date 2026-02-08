import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/campaign/campaign_enhanced_controller.dart';
import '../../../../../models/campaign/campaign.dart';
import '../_widgets/flatmate_card.dart';

class MyMatch extends StatelessWidget {
  MyMatch({super.key});

  // Use real API controller
  final CampaignEnhancedController controller = Get.put(CampaignEnhancedController());

  @override
  Widget build(BuildContext context) {
    // Fetch campaigns on build
    controller.fetchMyCampaigns();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(
              () {
                // Show loading indicator
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show empty state if no campaigns
                if (controller.myCampaigns.isEmpty) {
                  return _buildNoCampaignsView();
                }

                // Show campaigns grid
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: controller.myCampaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = controller.myCampaigns[index];
                    return _buildCampaignCard(campaign);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Build view when there are no campaigns
  Widget _buildNoCampaignsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          const Text(
            'No Campaigns Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You haven\'t created any campaigns yet.\nTap the + button to create one!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'ProductSans',
            ),
          ),
        ],
      ),
    );
  }
  
  // Show bottom sheet with campaign action options
  void _showCampaignActionSheet(Campaign campaign) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  // Edit button
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF29BCA2).withValues(alpha: 0.1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          // TODO: Navigate to edit campaign screen
                          Get.snackbar('Info', 'Edit campaign feature coming soon');
                        },
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.w400,
                            fontSize: 22,
                            color: Color(0xFF29BCA2),
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Delete button
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFDC3545).withValues(alpha: 0.1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          if (campaign.id != null) {
                            controller.deleteCampaign(campaign.id!);
                          }
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.w400,
                            fontSize: 22,
                            color: Color(0xFFDC3545),
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    return GestureDetector(
      onLongPress: () => _showCampaignActionSheet(campaign),
      child: FlatmateCard(campaign: campaign),
    );
  }
}
