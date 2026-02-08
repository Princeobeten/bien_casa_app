import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ActiveLeasesScreen - Home owner manages active leases
class ActiveLeasesScreen extends StatefulWidget {
  const ActiveLeasesScreen({super.key});

  @override
  State<ActiveLeasesScreen> createState() => _ActiveLeasesScreenState();
}

class _ActiveLeasesScreenState extends State<ActiveLeasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock active leases data
  final List<Map<String, dynamic>> _leases = [
    {
      'id': 'lease_001',
      'propertyTitle': 'Modern 3BR Apartment in Lekki',
      'propertyImage':
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'location': 'Lekki Phase 1, Lagos',
      'tenantName': 'John Doe',
      'tenantPhone': '+234 801 234 5678',
      'monthlyRent': 5000000,
      'startDate': DateTime(2024, 1, 1),
      'endDate': DateTime(2024, 12, 31),
      'status': 'active',
      'paymentStatus': 'paid',
      'nextPaymentDate': DateTime.now().add(const Duration(days: 25)),
      'lastPaymentDate': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': 'lease_002',
      'propertyTitle': 'Luxury 4BR Duplex with Pool',
      'propertyImage':
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      'location': 'Victoria Island, Lagos',
      'tenantName': 'Sarah Johnson',
      'tenantPhone': '+234 802 345 6789',
      'monthlyRent': 8000000,
      'startDate': DateTime(2024, 2, 1),
      'endDate': DateTime(2025, 1, 31),
      'status': 'active',
      'paymentStatus': 'overdue',
      'nextPaymentDate': DateTime.now().subtract(const Duration(days: 3)),
      'lastPaymentDate': DateTime.now().subtract(const Duration(days: 33)),
    },
    {
      'id': 'lease_003',
      'propertyTitle': 'Cozy 2BR Flat in Ikeja',
      'propertyImage':
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      'location': 'Ikeja GRA, Lagos',
      'tenantName': 'Michael Chen',
      'tenantPhone': '+234 803 456 7890',
      'monthlyRent': 3500000,
      'startDate': DateTime(2023, 6, 1),
      'endDate': DateTime(2024, 5, 31),
      'status': 'expiring_soon',
      'paymentStatus': 'paid',
      'nextPaymentDate': DateTime.now().add(const Duration(days: 15)),
      'lastPaymentDate': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 'lease_004',
      'propertyTitle': 'Spacious 3BR with Garden',
      'propertyImage':
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      'location': 'Ikoyi, Lagos',
      'tenantName': 'Emma Williams',
      'tenantPhone': '+234 804 567 8901',
      'monthlyRent': 6000000,
      'startDate': DateTime(2023, 9, 1),
      'endDate': DateTime(2024, 8, 31),
      'status': 'pending_renewal',
      'paymentStatus': 'paid',
      'nextPaymentDate': DateTime.now().add(const Duration(days: 20)),
      'lastPaymentDate': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          'Active Leases',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 35,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: 0,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Active'),
                Tab(text: 'Expiring Soon'),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaseList(_leases),
                _buildLeaseList(
                  _leases
                      .where((lease) => lease['status'] == 'active')
                      .toList(),
                ),
                _buildLeaseList(
                  _leases
                      .where(
                        (lease) =>
                            lease['status'] == 'expiring_soon' ||
                            lease['status'] == 'pending_renewal',
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseList(List<Map<String, dynamic>> leases) {
    if (leases.isEmpty) {
      return Center(
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
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: leases.length,
      itemBuilder: (context, index) {
        final lease = leases[index];
        return _buildLeaseCard(lease);
      },
    );
  }

  Widget _buildLeaseCard(Map<String, dynamic> lease) {
    final String status = lease['status'];
    final String paymentStatus = lease['paymentStatus'];
    final DateTime endDate = lease['endDate'];
    final DateTime nextPayment = lease['nextPaymentDate'];
    final int daysUntilExpiry = endDate.difference(DateTime.now()).inDays;
    final bool isOverdue = paymentStatus == 'overdue';

    return Container(
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
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
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
                // Tenant Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lease['tenantName'],
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lease['tenantPhone'],
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Lease Period
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
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
                // Payment Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isOverdue
                              ? Colors.red.shade200
                              : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOverdue ? 'Payment Overdue' : 'Next Payment',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 12,
                                color:
                                    isOverdue
                                        ? Colors.red.shade800
                                        : Colors.grey[600],
                                fontWeight:
                                    isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NGN${lease['monthlyRent'].toStringAsFixed(0)}',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color:
                                    isOverdue
                                        ? Colors.red.shade800
                                        : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isOverdue
                                  ? 'Due ${_formatDate(nextPayment)}'
                                  : 'Due ${_formatDate(nextPayment)}',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 12,
                                color:
                                    isOverdue
                                        ? Colors.red.shade800
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getPaymentStatusColor(
                            paymentStatus,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getPaymentStatusText(paymentStatus),
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getPaymentStatusColor(paymentStatus),
                          ),
                        ),
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
                          onPressed: () => _viewLeaseDetails(lease),
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
                          onPressed: () => _contactTenant(lease),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff020202),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Contact',
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'expiring_soon':
      case 'pending_renewal':
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
      case 'pending_renewal':
        return 'Pending Renewal';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'overdue':
        return 'Overdue';
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

  void _contactTenant(Map<String, dynamic> lease) {
    Get.snackbar(
      'Contact Tenant',
      'Opening chat with ${lease['tenantName']}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
    );
  }
}
