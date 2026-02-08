import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/subscription/subscription.dart';

/// SubscriptionScreen - Property owner subscription management
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'en_NG',
    symbol: 'NGN',
    decimalDigits: 0,
  );

  // Mock current subscription (free tier)
  Subscription? _currentSubscription;
  int _currentPropertyCount = 8; // Mock: user has 8 properties

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  void _loadSubscription() {
    // TODO: Load from API
    // For now, user is on free tier
    setState(() {
      _currentSubscription = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool needsUpgrade = _currentPropertyCount >= 10;
    final bool hasActiveSubscription =
        _currentSubscription?.isActive ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.only(left: 18),
        ),
        title: const Text(
          'Subscription',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 35,
            fontWeight: FontWeight.w400,
            height: 1,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Card
            _buildCurrentStatusCard(hasActiveSubscription, needsUpgrade),

            const SizedBox(height: 24),

            // Subscription Plans
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subscription Plans',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Free Plan
                  _buildPlanCard(
                    title: 'Free Plan',
                    price: 0,
                    propertyLimit: 10,
                    features: [
                      'Up to 10 property listings',
                      'Basic property management',
                      'Application management',
                      'Inspection scheduling',
                      'Standard support',
                    ],
                    isCurrentPlan: !hasActiveSubscription,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 16),

                  // Premium Plan
                  _buildPlanCard(
                    title: 'Premium Plan',
                    price: 5000,
                    propertyLimit: null, // Unlimited
                    features: [
                      'Unlimited property listings',
                      'Advanced analytics',
                      'Priority support',
                      'Featured listings',
                      'Bulk operations',
                      'Revenue reports',
                      'Tenant screening tools',
                    ],
                    isCurrentPlan: hasActiveSubscription,
                    color: Colors.blue,
                    isRecommended: needsUpgrade,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(bool hasActiveSubscription, bool needsUpgrade) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasActiveSubscription
              ? [Colors.blue.shade400, Colors.blue.shade600]
              : needsUpgrade
                  ? [Colors.orange.shade400, Colors.orange.shade600]
                  : [Colors.grey.shade400, Colors.grey.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (hasActiveSubscription
                    ? Colors.blue
                    : needsUpgrade
                        ? Colors.orange
                        : Colors.grey)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Plan',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              if (hasActiveSubscription)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasActiveSubscription ? 'Premium Plan' : 'Free Plan',
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.home_work, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                '$_currentPropertyCount properties listed',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (!hasActiveSubscription) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${10 - _currentPropertyCount} properties remaining',
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
          if (hasActiveSubscription && _currentSubscription != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Renews on ${DateFormat('MMM dd, yyyy').format(_currentSubscription!.endDate)}',
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
          if (needsUpgrade && !hasActiveSubscription) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You\'ve reached your property limit. Upgrade to add more!',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required double price,
    required int? propertyLimit,
    required List<String> features,
    required bool isCurrentPlan,
    required Color color,
    bool isRecommended = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isRecommended
            ? Border.all(color: color, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Text(
                'RECOMMENDED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'CURRENT',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyFormat.format(price),
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '/month',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  propertyLimit == null
                      ? 'Unlimited properties'
                      : 'Up to $propertyLimit properties',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: color, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => _handleSubscribe(price, title),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan ? Colors.grey : color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Text(
                      isCurrentPlan ? 'Current Plan' : 'Subscribe Now',
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubscribe(double amount, String planName) {
    // Show payment confirmation dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.payment, size: 48, color: Colors.blue.shade600),
              ),
              const SizedBox(height: 24),
              Text(
                'Subscribe to $planName',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You will be charged ${currencyFormat.format(amount)} monthly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _processSubscription(amount, planName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  void _processSubscription(double amount, String planName) {
    Get.back(); // Close dialog

    // TODO: Integrate with payment service
    // For now, show success message
    Get.snackbar(
      'Subscription Activated',
      'Your $planName subscription is now active!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );

    // Reload subscription
    Future.delayed(const Duration(seconds: 1), () {
      _loadSubscription();
    });
  }
}
