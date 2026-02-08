import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:bien_casa/app/controllers/create_campaign_controller.dart';
import 'escrow_payment_confirm_page.dart';

class EscrowPaymentPage extends StatefulWidget {
  const EscrowPaymentPage({super.key});

  @override
  State<EscrowPaymentPage> createState() => _EscrowPaymentPageState();
}

class _EscrowPaymentPageState extends State<EscrowPaymentPage> {
  bool agreeToTerms = false;
  bool understandTransaction = false;

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
          body: Padding(
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
                  'Secure your campaign with Escrow. Your money stays safe, only released when terms are met.',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Campaign details section (smaller version)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campaign details',
                        style: TextStyle(
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (controller.matePersonalityTraitPreference['gender'] != null)
                        _buildDetailRow('Gender', controller.matePersonalityTraitPreference['gender']),
                      if (controller.matePersonalityTraitPreference['religion'] != null)
                        _buildDetailRow('Religion', controller.matePersonalityTraitPreference['religion']),
                      if (controller.matePersonalityTraitPreference['maritalStatus'] != null)
                        _buildDetailRow('Marital Status', controller.matePersonalityTraitPreference['maritalStatus']),
                      _buildDetailRow('Max Flatmates', controller.maxNumberOfFlatmates.toString()),

                      const SizedBox(height: 16),

                      // Apartment Preference
                      const Text(
                        'Apartment Preference',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (controller.apartmentPreference['type'] != null)
                        _buildDetailRow('Type', controller.apartmentPreference['type']),
                      if (controller.apartmentPreference['aesthetic'] != null)
                        _buildDetailRow('Aesthetic', controller.apartmentPreference['aesthetic']),
                      _buildDetailRow('Location', controller.locationController.text),
                      _buildDetailRow('City/Town', controller.campaignCityTownController.text),

                      const SizedBox(height: 16),

                      // Budget
                      const Text(
                        'Budget',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _buildDetailRow('Budget Range', 'NGN ${controller.campaignStartBudgetController.text} - ${controller.campaignEndBudgetController.text}'),
                      _buildDetailRow('Budget Plan', controller.campaignBudgetPlan),
                      _buildDetailRow('Move Date', '${controller.moveDate.day}/${controller.moveDate.month}/${controller.moveDate.year}'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Payment confirmation modal overlay
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Confirm payment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          'NGN250,000',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        const Text(
                          'Flatmate Escrow fee',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),

                        // Wallet Balance
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Wallet Balance',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const Text(
                                'NGN500,000',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Checkboxes
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: Colors.black,
                            ),
                            const Expanded(
                              child: Text(
                                'I agree to lock in 25% of my total flatmate campaign budget via escrow till the terms are met. I confirm and approve this transaction.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: understandTransaction,
                              onChanged: (value) {
                                setState(() {
                                  understandTransaction = value ?? false;
                                });
                              },
                              activeColor: Colors.black,
                            ),
                            const Expanded(
                              child: Text(
                                'I understand that once this transaction is initiated, it CANNOT be undone.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                (agreeToTerms && understandTransaction)
                                    ? () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        builder:
                                            (context) =>
                                                const PinEntryBottomSheet(),
                                      );
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Terms and Privacy
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            children: [
                              TextSpan(
                                text: 'By using Bien Casa you agree to our ',
                              ),
                              TextSpan(
                                text: 'Term of Service',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' and\n'),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
