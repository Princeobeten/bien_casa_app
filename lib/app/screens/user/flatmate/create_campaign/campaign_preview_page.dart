import 'package:bien_casa/app/controllers/create_campaign_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'campaign_success_page.dart';

class CampaignPreviewPage extends StatelessWidget {
  const CampaignPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateCampaignController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Campaign\nPreview',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Ready to find the right match? Hit Publish to launch your campaign!',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Campaign details section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xff29BCA2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Campaign details',
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Basic Info
                        const Text(
                          'Basic Information',
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow('Title', controller.titleController.text),
                        _buildDetailRow('Goal', controller.goal),
                        _buildDetailRow('Budget Range', 'NGN ${controller.campaignStartBudgetController.text} - ${controller.campaignEndBudgetController.text}'),
                        _buildDetailRow('Budget Plan', controller.campaignBudgetPlan),
                        _buildDetailRow('Move Date', '${controller.moveDate.day}/${controller.moveDate.month}/${controller.moveDate.year}'),
                        _buildDetailRow('Location', controller.locationController.text),
                        _buildDetailRow('City/Town', controller.campaignCityTownController.text),
                        _buildDetailRow('Country', controller.country),
                        _buildDetailRow('Max Flatmates', controller.maxNumberOfFlatmates.toString()),

                        // Show Home Owner details if applicable
                        if (controller.creatorIsHomeOwner) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Home Owner Details',
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (controller.creatorHomeDistrictController.text.isNotEmpty)
                            _buildDetailRow('District', controller.creatorHomeDistrictController.text),
                          if (controller.creatorHomeCityController.text.isNotEmpty)
                            _buildDetailRow('City', controller.creatorHomeCityController.text),
                          if (controller.creatorNeighboringLocationController.text.isNotEmpty)
                            _buildDetailRow('Neighboring Location', controller.creatorNeighboringLocationController.text),
                          if (controller.creatorHouseFeatures.isNotEmpty)
                            _buildDetailRow('House Features', controller.creatorHouseFeatures.join(', ')),
                          if (controller.creatorAdditionalPreferenceNoteController.text.isNotEmpty)
                            _buildDetailRow('Additional Notes', controller.creatorAdditionalPreferenceNoteController.text),
                        ],

                        // Show Flatmate preferences if goal is Flatmate
                        if (controller.goal == 'Flatmate' && controller.matePersonalityTraitPreference.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Flatmate Preferences',
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...controller.matePersonalityTraitPreference.entries.map((e) {
                            if (e.value == null) return const SizedBox.shrink();
                            final v = e.value;
                            final str = v is List ? v.map((x) => x.toString()).join(', ') : v.toString();
                            if (str.isEmpty) return const SizedBox.shrink();
                            final label = e.key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim();
                            final name = label.isNotEmpty ? label[0].toUpperCase() + label.substring(1) : e.key;
                            return _buildDetailRow(name, str);
                          }),
                        ],

                        // Show Flat preferences if goal is Flat
                        if (controller.goal == 'Flat' && controller.apartmentPreference.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Apartment Preferences',
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (controller.apartmentPreference['type'] != null)
                            _buildDetailRow('Type', controller.apartmentPreference['type']),
                          if (controller.apartmentPreference['aesthetic'] != null)
                            _buildDetailRow('Aesthetic', controller.apartmentPreference['aesthetic']),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Host section (separate from campaign details)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Escrow badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Host',
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          // Escrow badge
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/escrow_lock.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Escrow',
                                style: TextStyle(
                                  fontFamily: 'Product Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          // Profile picture
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9B9B),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/image/profile_placeholder.png', // You can replace with actual profile image
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 35,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Name and verification
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Isaac Isa',
                                  style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      'Verified',
                                      style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SvgPicture.asset(
                                      'assets/icons/verified.svg',
                                      width: 16,
                                      height: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Contact icons
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/phone.svg',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 12),
                              SvgPicture.asset(
                                'assets/icons/chat.svg',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Publish button
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: controller.campaignController.isLoading
                        ? null
                        : () async {
                            await controller.createCampaign();
                            // Only navigate to success if campaign was created
                            if (!controller.campaignController.isLoading &&
                                controller.campaignController.errorMessage.isEmpty) {
                              Get.to(() => const CampaignSuccessPage());
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: controller.campaignController.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Publish campaign',
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 16,
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
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Product Sans',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Product Sans',
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
