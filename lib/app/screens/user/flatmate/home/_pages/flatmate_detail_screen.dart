import 'package:bien_casa/app/controllers/flatmate_match_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

// Import widget components
import 'detail_widgets/flatmate_header_image.dart';
import 'detail_widgets/flatmate_about_section.dart';
import 'detail_widgets/flatmate_basic_section.dart';
import 'detail_widgets/flatmate_work_section.dart';
import 'detail_widgets/flatmate_language_section.dart';
import 'detail_widgets/flatmate_profile_section.dart';
import 'detail_widgets/flatmate_action_buttons.dart';

// Enum to track different request statuses
enum RequestStatus {
  none, // No request sent
  pending, // Request sent, awaiting response
  accepted, // Request accepted
  declined, // Request declined
}

class FlatmateDetailScreen extends StatelessWidget {
  final bool myFlatmate;

  const FlatmateDetailScreen({super.key, this.myFlatmate = false});

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

  // Helper method to determine button text based on request status
  String _getButtonText(String flatmateId) {
    final controller = Get.find<FlatmateMatchController>();
    final status =
        controller.flatmateRequestStatus[flatmateId] ?? RequestStatus.none;

    switch (status) {
      case RequestStatus.none:
        return 'Join Now';
      case RequestStatus.pending:
        return 'Processing Request...';
      case RequestStatus.accepted:
        return 'Request Accepted';
      case RequestStatus.declined:
        return 'Request Declined';
      default:
        return 'Join Now';
    }
  }

  // Show payment modal for joining campaign
  void _showJoinCampaignPaymentModal(
    BuildContext context,
    String flatmateId,
    StateSetter setModalState,
  ) {
    // Mock campaign amount - in production, this would come from the campaign data
    const double campaignAmount = 5000.0;
    const double joinFee = 500.0;
    final double percentage = (joinFee / campaignAmount * 100);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF29BCA2).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment,
                  size: 40,
                  color: Color(0xFF29BCA2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Join Campaign',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ProductSans',
                ),
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                'Pay ${percentage.toStringAsFixed(0)}% (NGN${joinFee.toStringAsFixed(0)}) of the campaign amount to join',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'ProductSans',
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              
              // Amount breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Campaign Amount',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'ProductSans',
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'NGN${campaignAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Join Fee (${percentage.toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'NGN${joinFee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF29BCA2),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                        // Process payment and join campaign
                        final controller = Get.find<FlatmateMatchController>();
                        controller.updateFlatmateStatus(
                          flatmateId,
                          RequestStatus.pending,
                        );
                        setModalState(() {});

                        // Simulate payment processing
                        Future.delayed(const Duration(seconds: 2), () {
                          controller.updateFlatmateStatus(
                            flatmateId,
                            RequestStatus.accepted,
                          );
                          setModalState(() {});
                          
                          Get.snackbar(
                            'Success',
                            'You have successfully joined the campaign!',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF29BCA2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pay Now',
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
    );
  }

  // Show campaign details bottom sheet
  void _showCampaignDetails(
    BuildContext context,
    Map<String, dynamic> flatmate,
  ) {
    // Generate a unique ID for this flatmate if needed
    String flatmateId = flatmate['id'] ?? flatmate['name'];

    // Campaign preferences (mock data - would come from backend in real app)
    final campaignPrefs = {
      'gender': flatmate['gender'] ?? 'All',
      'religion': flatmate['religion'] ?? 'Christian',
      'marital_status': 'Single',
      'num_flatmates': '4',
      'apt_type': '4 bedroom flat',
      'aesthetic': 'Furnished',
      'location': flatmate['location'] ?? 'Gwagwalada, Abuja',
      'budget_individual': '250,000',
      'budget_total': '1,000,000',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return DraggableScrollableSheet(
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
                            'Looking for the right\nplace and people?',
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
                            'Join a flatmate campaign that fits your lifestyle, share costs, and live better together.',
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

                          // Campaign details section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xff29BCA2,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Campaign details header
                                const Text(
                                  'Campaign details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Flatmate Preference
                                const Text(
                                  'Flatmate Preference',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Preference rows
                                _buildPreferenceRow(
                                  'Gender',
                                  campaignPrefs['gender']!,
                                ),
                                _buildPreferenceRow(
                                  'Religion',
                                  campaignPrefs['religion']!,
                                ),
                                _buildPreferenceRow(
                                  'Marital status',
                                  campaignPrefs['marital_status']!,
                                ),
                                _buildPreferenceRow(
                                  'No. of flatmates',
                                  campaignPrefs['num_flatmates']!,
                                ),
                                const SizedBox(height: 20),

                                // Apartment Preference
                                const Text(
                                  'Apartment Preference',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                                const SizedBox(height: 12),

                                _buildPreferenceRow(
                                  'Type',
                                  campaignPrefs['apt_type']!,
                                ),
                                _buildPreferenceRow(
                                  'Aesthetic',
                                  campaignPrefs['aesthetic']!,
                                ),
                                _buildPreferenceRow(
                                  'Location',
                                  campaignPrefs['location']!,
                                ),
                                const SizedBox(height: 20),

                                // Budget
                                const Text(
                                  'Budget',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                                const SizedBox(height: 12),

                                _buildPreferenceRow(
                                  'Individual',
                                  campaignPrefs['budget_individual']!,
                                ),
                                _buildPreferenceRow(
                                  'Total',
                                  campaignPrefs['budget_total']!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Host section
                          const Text(
                            'Host',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ProductSans',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Host details section using FlatmateProfileSection widget
                          FlatmateProfileSection(match: flatmate),
                          const SizedBox(height: 32),

                          // Join Now button
                          SizedBox(
                            width: double.infinity,
                            height: 70,
                            child: ElevatedButton(
                              onPressed:
                                  Get.find<FlatmateMatchController>()
                                              .flatmateRequestStatus[flatmateId] ==
                                          RequestStatus.pending
                                      ? null // Disable button if request is pending
                                      : () {
                                        // Show payment modal
                                        _showJoinCampaignPaymentModal(
                                          context,
                                          flatmateId,
                                          setModalState,
                                        );
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor: Colors.grey.shade400,
                                disabledForegroundColor: Colors.white70,
                              ),
                              child: Text(
                                _getButtonText(flatmateId) == 'Join Now'
                                    ? 'Join Now'
                                    : _getButtonText(flatmateId),
                                style: const TextStyle(
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
              );
            },
          ),
    );
  }

  // Helper method to build preference rows in campaign details
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

  // Build the bottom action area with campaign and flatmate buttons
  Widget _buildBottomActionArea(
    BuildContext context,
    Map<String, dynamic> match,
    RequestStatus status,
  ) {
    // Use the status passed from the controller
    final currentStatus = status;

    // Create the Column that will hold our buttons
    return Column(
      children: [
        // For status NONE: Show View Campaign button only
        if (currentStatus == RequestStatus.none)
          Container(
            width: double.infinity,
            height: 70,
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () => _showCampaignDetails(context, match),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'View Campaign',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),

        // For status PENDING: Show Accept and Decline buttons
        if (currentStatus == RequestStatus.pending)
          FlatmateActionButtons(match: match),

        // For status ACCEPTED: Show View My Flatmates button
        if (currentStatus == RequestStatus.accepted)
          Container(
            width: double.infinity,
            height: 70,
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to My Flatmate section
                Get.until((route) => route.isFirst); // Go back to main screen

                // Get tab controller index for My Flatmate
                final int tabIndex = 2; // Index of My Flatmate tab

                // Update the tab index to navigate to My Flatmate section
                Get.find<TabController>().animateTo(tabIndex);

                Get.snackbar(
                  'My Flatmate',
                  'Navigating to My Flatmate section',
                  snackPosition: SnackPosition.TOP,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29BCA2).withOpacity(0.1),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'View My Flatmate',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),

        // For status DECLINED: Show View Campaign and regular actions
        if (currentStatus == RequestStatus.declined) ...[
          // First the View Campaign button
          Container(
            width: double.infinity,
            height: 70,
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () => _showCampaignDetails(context, match),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'View Campaign',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),

          // Then the action buttons
          FlatmateActionButtons(match: match),
        ],

        /*

        // Show status message if request is pending
        if (currentStatus == RequestStatus.pending)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Your request is being processed...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.amber.shade800,
                fontFamily: 'ProductSans',
              ),
            ),
          ),

        // Show success message if request is accepted
        if (currentStatus == RequestStatus.accepted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF29BCA2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Your request has been accepted!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF29BCA2),
                fontFamily: 'ProductSans',
              ),
            ),
          ),
     
      */
      ],
    );
  }

  // Build UI for 'My Flatmate' view
  Widget _buildMyFlatmateView(Map<String, dynamic> match) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate back to My Flatmate tab
              Get.back(); // Return to previous screen
            },
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF29BCA2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: const Text(
                'View My Flatmate',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get controller to access data
    final controller = Get.find<FlatmateMatchController>();

    // Default status is none
    RequestStatus status = RequestStatus.none;

    // Handle different types of arguments
    Map<String, dynamic> matchData;
    if (Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;

      // Extract data from arguments
      if (args.containsKey('data')) {
        matchData = args['data'] as Map<String, dynamic>;

        // Check if status was passed
        if (args.containsKey('status')) {
          status = args['status'] as RequestStatus;
        } else if (matchData.containsKey('id')) {
          // Get status from controller if ID is available
          final id = matchData['id'] as String;
          status = controller.flatmateRequestStatus[id] ?? RequestStatus.none;
        }
      } else {
        // Legacy format - just the match data
        matchData = args;

        // Try to get status if ID is available
        if (matchData.containsKey('id')) {
          final id = matchData['id'] as String;
          status = controller.flatmateRequestStatus[id] ?? RequestStatus.none;
        }
      }
    } else {
      // Get from controller if no arguments
      matchData = controller.getCurrentFlatmateData();

      // Try to get status if ID is available
      if (matchData.containsKey('id')) {
        final id = matchData['id'] as String;
        status = controller.flatmateRequestStatus[id] ?? RequestStatus.none;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh
        slivers: [
          // Add pull-to-refresh functionality
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              // Reload flatmate data
              print('Refreshing flatmate details');
              // Here you would typically fetch fresh data from your controller
              // For now, we'll just simulate a delay
              await Future.delayed(const Duration(seconds: 1));
            },
          ),

          // Profile Image Header
          FlatmateHeaderImage(match: matchData),

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
                  FlatmateAboutSection(match: matchData),

                  const SizedBox(height: 24),

                  // Basic Info Section
                  FlatmateBasicSection(match: matchData),

                  const SizedBox(height: 24),

                  // Work Section
                  FlatmateWorkSection(match: matchData),

                  const SizedBox(height: 24),

                  // Language Section
                  FlatmateLanguageSection(match: matchData),

                  const SizedBox(height: 32),

                  // Flatmate Profile Section with contact buttons
                  FlatmateProfileSection(match: matchData),

                  const SizedBox(height: 24),

                  // Conditionally show buttons based on status
                  _buildBottomActionArea(context, matchData, status),

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
