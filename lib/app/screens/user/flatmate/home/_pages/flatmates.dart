import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../controllers/flatmate_controller.dart';
import '../../../../../models/campaign/campaign.dart';
import '../_widgets/flatmate_card.dart';

class Flatmates extends StatefulWidget {
  const Flatmates({super.key});

  @override
  State<Flatmates> createState() => _FlatmatesState();
}

class _FlatmatesState extends State<Flatmates> {
  // Get controller - using real API controller
  final FlatmateController controller = Get.find<FlatmateController>();

  // Track join request status for each campaign
  final Map<int, bool> _joinRequestStatus = {};

  // Show campaign details bottom sheet
  void _showCampaignDetails(Campaign campaign) {
    // Generate a unique ID for this campaign
    int campaignId = campaign.id ?? 0;

    // Show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Close handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Campaign header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Campaign Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ProductSans',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Campaign header
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getGoalColor(campaign.goal).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getGoalIcon(campaign.goal),
                                  color: _getGoalColor(campaign.goal),
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        campaign.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'ProductSans',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        campaign.goal,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          fontFamily: 'ProductSans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Campaign info
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Budget
                            _buildInfoRow(
                              title: 'Budget',
                              value: campaign.formattedBudget,
                              icon: Icons.account_balance_wallet,
                            ),
                            const SizedBox(height: 16),

                            // Location
                            _buildInfoRow(
                              title: 'Location',
                              value: '${campaign.city}, ${campaign.country}',
                              icon: Icons.location_on,
                            ),
                            const SizedBox(height: 16),

                            // Duration
                            _buildInfoRow(
                              title: 'Duration',
                              value: campaign.duration,
                              icon: Icons.calendar_today,
                            ),
                            const SizedBox(height: 16),

                            // Move Date
                            _buildInfoRow(
                              title: 'Move Date',
                              value: '${campaign.moveDate.day}/${campaign.moveDate.month}/${campaign.moveDate.year}',
                              icon: Icons.event,
                            ),
                            const SizedBox(height: 16),

                            // Campaign Details
                            const Text(
                              'Campaign Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Looking for ${campaign.goal.toLowerCase()} in ${campaign.location}. Budget: ${campaign.formattedBudget} for ${campaign.duration}.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                                height: 1.5,
                                fontFamily: 'ProductSans',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Preferences (if available)
                            if (campaign.gender != null || campaign.religion != null || campaign.maritalStatus != null) ...[
                              const Text(
                                'Preferences',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ProductSans',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (campaign.gender != null) _buildPreferenceChip(campaign.gender!),
                                  if (campaign.religion != null) _buildPreferenceChip(campaign.religion!),
                                  if (campaign.maritalStatus != null) _buildPreferenceChip(campaign.maritalStatus!),
                                  if (campaign.personality != null) _buildPreferenceChip(campaign.personality!),
                                  if (campaign.habit != null) _buildPreferenceChip(campaign.habit!),
                                ],
                              ),
                            ],
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),

                    // Join button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _joinRequestStatus[campaignId] == true
                              ? null
                              : () async {
                                  if (campaign.id != null) {
                                    final success = await controller.applyToCampaign(campaign.id!);
                                    if (success) {
                                      setModalState(() {
                                        _joinRequestStatus[campaignId] = true;
                                      });
                                      setState(() {
                                        _joinRequestStatus[campaignId] = true;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF29BCA2),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _joinRequestStatus[campaignId] == true
                                ? 'Application Sent'
                                : 'Apply Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ProductSans',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  // Helper method to build info rows in campaign details
  Widget _buildInfoRow({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF29BCA2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF29BCA2), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'ProductSans',
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'ProductSans',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to build preference chips
  Widget _buildPreferenceChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
          fontFamily: 'ProductSans',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Browse available flatmate campaign by budget, location, interest etc.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff6B6B6B),
              fontWeight: FontWeight.w300,
              fontFamily: 'ProductSans',
            ),
          ),
        ),

        // Main content - Campaign cards grid
        Expanded(
          child: Obx(
            () {
              // Show loading indicator
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return controller.campaigns.isEmpty
                  ? _buildNoCampaignsView()
                  : _buildCampaignsGridView();
            },
          ),
        ),
      ],
    );
  }

  // Empty state when no campaigns are available
  Widget _buildNoCampaignsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/home.svg',
            width: 80,
            height: 80,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Campaigns Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'There are no campaigns available at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'ProductSans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Grid view of campaign cards
  Widget _buildCampaignsGridView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: controller.campaigns.length,
        itemBuilder: (context, index) {
          final campaign = controller.campaigns[index];
          return _buildCampaignCard(campaign);
        },
      ),
    );
  }

  // Individual campaign card - using the FlatmateCard widget
  Widget _buildCampaignCard(Campaign campaign) {
    return FlatmateCard(campaign: campaign);
  }

  // Helper methods for campaign details
  Color _getGoalColor(String goal) {
    switch (goal) {
      case 'Flatmate':
        return Colors.blue;
      case 'Flat':
        return Colors.green;
      case 'Short-stay':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Flatmate':
        return Icons.people;
      case 'Flat':
        return Icons.home;
      case 'Short-stay':
        return Icons.hotel;
      default:
        return Icons.campaign;
    }
  }
}
