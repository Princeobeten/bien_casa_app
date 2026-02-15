import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// Status of a withdrawal transaction for display.
enum WithdrawalStatus {
  success,
  pending,
  failed,
}

class WithdrawalStatusScreen extends StatelessWidget {
  final WithdrawalStatus status;
  final String message;
  final double amount;
  final String? reference;

  const WithdrawalStatusScreen({
    super.key,
    required this.status,
    required this.message,
    required this.amount,
    this.reference,
  });

  static String _formatAmount(double value) {
    final str = value.toStringAsFixed(2);
    return str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == WithdrawalStatus.success;
    final isPending = status == WithdrawalStatus.pending;
    final isFailed = status == WithdrawalStatus.failed;

    IconData icon;
    Color iconColor;
    String title;
    Color titleColor;

    if (isSuccess) {
      icon = Icons.check_circle_rounded;
      iconColor = const Color(0xFF1ABC9C);
      title = 'Transfer initiated successfully';
      titleColor = Colors.black;
    } else if (isPending) {
      icon = Icons.schedule_rounded;
      iconColor = Colors.orange;
      title = 'Withdrawal Pending';
      titleColor = Colors.black;
    } else {
      icon = Icons.error_rounded;
      iconColor = Colors.red;
      title = 'Withdrawal Failed';
      titleColor = Colors.black;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Icon(icon, size: 80, color: iconColor),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ProductSans',
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/icons/naira.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatAmount(amount),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'ProductSans',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'ProductSans',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'ProductSans',
                        color: Colors.black87,
                      ),
                    ),
                    if (reference != null && reference!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Reference',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'ProductSans',
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reference!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'ProductSans',
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
