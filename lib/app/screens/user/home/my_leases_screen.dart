import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// MyLeasesScreen - View and manage active leases
class MyLeasesScreen extends StatefulWidget {
  const MyLeasesScreen({Key? key}) : super(key: key);

  @override
  State<MyLeasesScreen> createState() => _MyLeasesScreenState();
}

class _MyLeasesScreenState extends State<MyLeasesScreen> {
  // Mock lease data
  final List<Map<String, dynamic>> _leases = [
    {
      'id': 'lease_001',
      'propertyTitle': 'Modern 3BR Apartment in Lekki',
      'propertyImage':
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'location': 'Lekki Phase 1, Lagos',
      'monthlyRent': 5000000,
      'startDate': DateTime(2024, 1, 1),
      'endDate': DateTime(2024, 12, 31),
      'status': 'active',
      'nextPaymentDate': DateTime.now().add(const Duration(days: 15)),
      'nextPaymentAmount': 5000000,
    },
    {
      'id': 'lease_002',
      'propertyTitle': 'Cozy 2BR Flat in Ikeja',
      'propertyImage':
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      'location': 'Ikeja GRA, Lagos',
      'monthlyRent': 3500000,
      'startDate': DateTime(2023, 6, 1),
      'endDate': DateTime(2024, 5, 31),
      'status': 'expiring_soon',
      'nextPaymentDate': DateTime.now().add(const Duration(days: 45)),
      'nextPaymentAmount': 3500000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.only(left: 18),
        ),
        title: const Text(
          'My Leases',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 40,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: 0,
            color: Colors.black,
          ),
        ),
      ),
      body:
          _leases.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _leases.length,
                itemBuilder:
                    (context, index) => _buildLeaseCard(_leases[index]),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_work,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Leases',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any active leases at the moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaseCard(Map<String, dynamic> lease) {
    final String status = lease['status'];
    final DateTime endDate = lease['endDate'];
    final DateTime nextPayment = lease['nextPaymentDate'];
    final int daysUntilExpiry = endDate.difference(DateTime.now()).inDays;
    final int daysUntilPayment = nextPayment.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () {
        Get.toNamed('/lease-detail', arguments: lease);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
            // Property Image and Status
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    lease['propertyImage'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.home, size: 80),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Lease Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lease['propertyTitle'],
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lease['location'],
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Lease Period
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lease Period',
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatDate(lease['startDate'])} - ${_formatDate(lease['endDate'])}',
                                style: const TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (daysUntilExpiry <= 60 && daysUntilExpiry > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$daysUntilExpiry days left',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Next Payment
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          daysUntilPayment <= 7
                              ? Colors.red.shade50
                              : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          daysUntilPayment <= 7
                              ? Border.all(color: Colors.red.shade200)
                              : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Payment',
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NGN${lease['nextPaymentAmount'].toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Due ${_formatDate(nextPayment)}',
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 12,
                                  color:
                                      daysUntilPayment <= 7
                                          ? Colors.red.shade800
                                          : Colors.grey[600],
                                  fontWeight:
                                      daysUntilPayment <= 7
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (daysUntilPayment <= 7)
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red.shade800,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed:
                                () => Get.toNamed(
                                  '/lease-detail',
                                  arguments: lease,
                                ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xff020202),
                              side: const BorderSide(
                                color: Color(0xff020202),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _makePayment(lease),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff020202),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Pay Rent',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'expiring_soon':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'expiring_soon':
        return 'Expiring Soon';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _viewLeaseDetails(Map<String, dynamic> lease) {
    Get.snackbar(
      'Lease Details',
      'Lease details screen coming soon',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
    );
  }

  void _makePayment(Map<String, dynamic> lease) {
    Get.snackbar(
      'Payment',
      'Payment feature coming soon',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
    );
  }
}
