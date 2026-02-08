import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:bien_casa/app/controllers/create_campaign_controller.dart';
import 'payment_confirmation_bottom_sheet.dart';

class EscrowSummaryPage extends StatelessWidget {
  const EscrowSummaryPage({super.key});

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
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/escrow_lock.svg',
                          width: 32,
                          height: 35,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Escrow',
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 40,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Payment',
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 40,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  'Secure your campaign via Escrow. Your money stays safe, only released when terms are met.',
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
                      color: Color(0xff29BCA2).withValues(alpha: 0.1),
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

                        // Flatmate Preference
                        const Text(
                          'Flatmate Preference',
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (controller.matePersonalityTraitPreference['gender'] != null)
                          _buildDetailRow('Gender', controller.matePersonalityTraitPreference['gender']),
                        if (controller.matePersonalityTraitPreference['religion'] != null)
                          _buildDetailRow('Religion', controller.matePersonalityTraitPreference['religion']),
                        if (controller.matePersonalityTraitPreference['maritalStatus'] != null)
                          _buildDetailRow('Marital Status', controller.matePersonalityTraitPreference['maritalStatus']),
                        _buildDetailRow('Max Flatmates', controller.maxNumberOfFlatmates.toString()),

                        const SizedBox(height: 20),

                        // Apartment Preference
                        const Text(
                          'Apartment Preference',
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
                        _buildDetailRow('Location', controller.locationController.text),
                        _buildDetailRow('City/Town', controller.campaignCityTownController.text),

                        const SizedBox(height: 20),

                        // Budget
                        const Text(
                          'Budget',
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow('Budget Range', 'NGN ${controller.campaignStartBudgetController.text} - ${controller.campaignEndBudgetController.text}'),
                        _buildDetailRow('Budget Plan', controller.campaignBudgetPlan),
                        _buildDetailRow('Move Date', '${controller.moveDate.day}/${controller.moveDate.month}/${controller.moveDate.year}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Escrow fee (25% of max budget)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/escrow_lock.svg',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Escrow fee (25%)',
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'NGN${_calculateEscrowFee(controller.campaignEndBudgetController.text)}',
                        style: const TextStyle(
                          fontFamily: 'Product Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Tax',
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'NGN0.00',
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: const Text(
                    'To publish your flatmate campaign, lock in just 25% of your total budget via escrow. This shows serious intent, builds trust, and protects your funds until the right flatmates are matched.',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Proceed button
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder:
                            (context) => const PaymentConfirmationBottomSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Proceed',
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

  String _calculateEscrowFee(String budget) {
    if (budget.isEmpty) return '0';
    try {
      int budgetAmount = int.parse(budget.replaceAll(',', ''));
      int escrowFee = (budgetAmount * 0.25).round(); // 25% of budget
      return escrowFee.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return '0';
    }
  }
}
