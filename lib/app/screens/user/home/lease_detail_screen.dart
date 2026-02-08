import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> lease;

  const LeaseDetailScreen({Key? key, required this.lease}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Lease Details',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed:
                () => Get.snackbar(
                  'Share',
                  'Sharing lease details...',
                  snackPosition: SnackPosition.BOTTOM,
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeaseStatusCard(),
            const SizedBox(height: 20),
            _buildPropertyInfo(),
            const SizedBox(height: 24),
            _buildLeaseTerms(),
            const SizedBox(height: 24),
            _buildPaymentSchedule(),
            const SizedBox(height: 24),
            _buildLeaseDocuments(),
            const SizedBox(height: 24),
            _buildActions(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaseStatusCard() {
    final status = lease['status'] ?? 'active';
    final startDate = lease['startDate'] as DateTime? ?? DateTime.now();
    final endDate =
        lease['endDate'] as DateTime? ??
        DateTime.now().add(const Duration(days: 365));
    final daysRemaining = endDate.difference(DateTime.now()).inDays;

    Color statusColor =
        status == 'active'
            ? Colors.green
            : status == 'expired'
            ? Colors.red
            : Colors.orange;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withAlpha(120), statusColor.withAlpha(80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.check_circle, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Lease Period',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormat('MMM d, y').format(startDate)} - ${DateFormat('MMM d, y').format(endDate)}',
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                '$daysRemaining days remaining',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  lease['propertyImage'] ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.home, size: 40),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lease['propertyTitle'] ?? 'Property',
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lease['location'] ?? '',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to property detail screen
                Get.toNamed(
                  '/property-detail',
                  arguments: {
                    'propertyId': lease['propertyId'] ?? lease['id'],
                    'property': lease,
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Property',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseTerms() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lease Terms',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildTermRow(
                  'Monthly Rent',
                  'NGN${NumberFormat('#,###').format(lease['monthlyRent'] ?? 500000)}',
                ),
                const Divider(height: 24),
                _buildTermRow(
                  'Deposit',
                  'NGN${NumberFormat('#,###').format(lease['deposit'] ?? 1000000)}',
                ),
                const Divider(height: 24),
                _buildTermRow(
                  'Lease Duration',
                  lease['duration'] ?? '12 months',
                ),
                const Divider(height: 24),
                _buildTermRow(
                  'Payment Due Date',
                  lease['paymentDueDate'] ?? '1st of every month',
                ),
                const Divider(height: 24),
                _buildTermRow(
                  'Late Payment Fee',
                  'NGN${NumberFormat('#,###').format(lease['lateFee'] ?? 50000)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSchedule() {
    final payments = [
      {
        'month': 'November 2025',
        'amount': 500000,
        'status': 'paid',
        'date': DateTime(2025, 11, 1),
      },
      {
        'month': 'December 2025',
        'amount': 500000,
        'status': 'pending',
        'date': DateTime(2025, 12, 1),
      },
      {
        'month': 'January 2026',
        'amount': 500000,
        'status': 'upcoming',
        'date': DateTime(2026, 1, 1),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Schedule',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...payments.map((payment) => _buildPaymentCard(payment)).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    Color statusColor =
        payment['status'] == 'paid'
            ? Colors.green
            : payment['status'] == 'pending'
            ? Colors.orange
            : Colors.grey;
    IconData statusIcon =
        payment['status'] == 'paid'
            ? Icons.check_circle
            : payment['status'] == 'pending'
            ? Icons.access_time
            : Icons.schedule;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['month'],
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NGN${NumberFormat('#,###').format(payment['amount'])}',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (payment['status'] == 'paid')
            TextButton(
              onPressed:
                  () => Get.snackbar(
                    'Receipt',
                    'Downloading receipt...',
                    snackPosition: SnackPosition.BOTTOM,
                  ),
              child: const Text(
                'Receipt',
                style: TextStyle(fontFamily: 'ProductSans', fontSize: 13),
              ),
            )
          else if (payment['status'] == 'pending')
            ElevatedButton(
              onPressed:
                  () => Get.snackbar(
                    'Pay Rent',
                    'Opening payment screen...',
                    snackPosition: SnackPosition.BOTTOM,
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaseDocuments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lease Documents',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lease Agreement',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Signed on Nov 1, 2025',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed:
                      () => Get.snackbar(
                        'Download',
                        'Downloading lease agreement...',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      ),
                  icon: const Icon(Icons.download),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            Icons.payment,
            'Pay Rent',
            Colors.green,
            () => Get.snackbar(
              'Pay Rent',
              'Opening payment screen...',
              snackPosition: SnackPosition.BOTTOM,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            Icons.refresh,
            'Request Renewal',
            Colors.blue,
            () => _showRenewalDialog(),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            Icons.cancel,
            'Request Termination',
            Colors.orange,
            () => _showTerminationDialog(),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            Icons.build,
            'Report Issue',
            Colors.purple,
            () => Get.snackbar(
              'Report Issue',
              'Opening maintenance request...',
              snackPosition: SnackPosition.BOTTOM,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            Icons.message,
            'Contact Landlord',
            Colors.black,
            () => Get.snackbar(
              'Contact',
              'Opening messages...',
              snackPosition: SnackPosition.BOTTOM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showRenewalDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Request Lease Renewal',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Would you like to request a lease renewal?',
          style: TextStyle(fontFamily: 'ProductSans'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Renewal Request',
                'Your renewal request has been sent',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showTerminationDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Request Lease Termination',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to request lease termination?',
          style: TextStyle(fontFamily: 'ProductSans'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Termination Request',
                'Your termination request has been sent',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}
