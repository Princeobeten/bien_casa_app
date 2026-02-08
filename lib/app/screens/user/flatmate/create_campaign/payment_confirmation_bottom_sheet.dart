import 'package:flutter/material.dart';
import 'escrow_payment_confirm_page.dart';

class PaymentConfirmationBottomSheet extends StatefulWidget {
  const PaymentConfirmationBottomSheet({super.key});

  @override
  State<PaymentConfirmationBottomSheet> createState() =>
      _PaymentConfirmationBottomSheetState();
}

class _PaymentConfirmationBottomSheetState
    extends State<PaymentConfirmationBottomSheet> {
  bool agreeToTerms = false;
  bool understandTransaction = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Confirm payment',
            style: TextStyle(
              fontFamily: 'Product Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),

          // Payment amount section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xff29BCA2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'NGN250,000',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Flatmate Escrow fee',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Wallet Balance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'NGN500,000',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
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
                    fontFamily: 'Product Sans',
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
                    fontFamily: 'Product Sans',
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
            height: 70,
            child: ElevatedButton(
              onPressed:
                  (agreeToTerms && understandTransaction)
                      ? () {
                        // Close current bottom sheet and show PIN entry
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => const PinEntryBottomSheet(),
                        );
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (agreeToTerms && understandTransaction)
                        ? Colors.black
                        : Colors.grey[300],
                foregroundColor:
                    (agreeToTerms && understandTransaction)
                        ? Colors.white
                        : Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(fontFamily: 'Product Sans', fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Terms and Privacy
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 12,
                color: Colors.grey,
              ),
              children: [
                TextSpan(text: 'By using Bien Casa you agree to our '),
                TextSpan(
                  text: 'Term of Service',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
                TextSpan(text: ' and\n'),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
