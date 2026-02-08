import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/lease/lease_application.dart';
import '../../../controllers/lease/application_controller.dart';
import '../../../widgets/status_badges/status_badge.dart';

/// MyApplicationsScreen - View all user's lease applications
class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen>
    with SingleTickerProviderStateMixin {
  final ApplicationController _applicationController = Get.put(
    ApplicationController(),
  );
  late TabController _tabController;

  // Mock property data mapping for display purposes
  final Map<String, Map<String, dynamic>> _propertyDataMap = {
    'lease_001': {
      'title': 'Modern 3BR Apartment in Lekki',
      'image':
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'location': 'Lekki Phase 1, Lagos',
    },
    'lease_002': {
      'title': 'Luxury 4BR Duplex with Pool',
      'image':
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      'location': 'Victoria Island, Lagos',
    },
    'lease_003': {
      'title': 'Cozy 2BR Flat in Ikeja',
      'image':
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      'location': 'Ikeja GRA, Lagos',
    },
    'lease_004': {
      'title': 'Spacious 3BR with Garden',
      'image':
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      'location': 'Ikoyi, Lagos',
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    // Add mock data for testing
    _addMockApplications();

    // TODO: Uncomment when API is ready
    // const String currentUserId = 'user_123';
    // await _applicationController.fetchMyApplications(currentUserId);
  }

  void _addMockApplications() {
    final now = DateTime.now();

    // Create mock applications for testing
    final mockApplications = [
      LeaseApplication(
        id: 'app_001',
        houseLeaseId: 'lease_001',
        applicantId: 'user_123',
        applicationType: 'immediate_rent',
        status: 'Pending_review',
        message:
            'I am interested in this property and would like to schedule a viewing.',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      LeaseApplication(
        id: 'app_002',
        houseLeaseId: 'lease_002',
        applicantId: 'user_123',
        applicationType: 'negotiation',
        proposedPrice: 4500000,
        status: 'Approved_by_owner',
        message: 'Looking for a long-term rental. I am a working professional.',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        approvedAt: now.subtract(const Duration(hours: 12)),
      ),
      LeaseApplication(
        id: 'app_003',
        houseLeaseId: 'lease_003',
        applicantId: 'user_123',
        applicationType: 'immediate_rent',
        status: 'Declined_by_owner',
        message: 'I need a place close to my workplace.',
        declineReason: 'Sorry, the property has been rented to another tenant.',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
        declinedAt: now.subtract(const Duration(days: 2)),
      ),
      LeaseApplication(
        id: 'app_004',
        houseLeaseId: 'lease_004',
        applicantId: 'user_123',
        applicationType: 'negotiation',
        proposedPrice: 3000000,
        status: 'Pending_review',
        message: 'Family of 4 looking for a peaceful neighborhood.',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    // Add mock data to controller using addAll
    _applicationController.myApplications.clear();
    _applicationController.myApplications.addAll(mockApplications);
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: const Color(0xff6B6B6B),
          indicatorColor: Colors.black,
          labelStyle: const TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'ProductSans Light',
            fontWeight: FontWeight.w300,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Declined'),
          ],
        ),
      ),
      body: Obx(() {
        if (_applicationController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_applicationController.myApplications.isEmpty) {
          return _buildEmptyState();
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildApplicationList(_applicationController.myApplications),
            _buildApplicationList(_filterByStatus('Pending_review')),
            _buildApplicationList(
              _filterByStatus(['Approved_by_owner', 'Approved_by_realtor']),
            ),
            _buildApplicationList(
              _filterByStatus(['Declined_by_owner', 'Declined_by_realtor']),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.offAllNamed('/user-home');
        },
        backgroundColor: const Color(0xff020202),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Application',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Applications Yet',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start browsing properties to apply',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.offAllNamed('/user-home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff020202),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Browse Properties',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationList(List<LeaseApplication> applications) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No applications in this category',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          return _buildApplicationCard(applications[index]);
        },
      ),
    );
  }

  Widget _buildApplicationCard(LeaseApplication application) {
    return GestureDetector(
      onTap: () {
        // Navigate to application detail
        _applicationController.setSelectedApplication(application);
        // TODO: Navigate to detail screen
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Property Image and Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _propertyDataMap[application.houseLeaseId]?['image'] ??
                        'https://via.placeholder.com/80',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home,
                          size: 40,
                          color: Color(0xff6B6B6B),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Property Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Title
                      Text(
                        _propertyDataMap[application.houseLeaseId]?['title'] ??
                            'Property',
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Text(
                        _propertyDataMap[application
                                .houseLeaseId]?['location'] ??
                            'Location',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status Badge
                      ApplicationStatusBadge(status: application.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Application type
            Row(
              children: [
                Icon(
                  application.isImmediateRent
                      ? Icons.flash_on
                      : Icons.handshake,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  application.isImmediateRent
                      ? 'Immediate Rent'
                      : 'Negotiation',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            if (application.proposedPrice != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Proposed: ${application.formattedProposedPrice}',
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Message preview
            if (application.message != null)
              Text(
                application.message!,
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(application.createdAt),
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                if (application.viewedByOwner)
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 14,
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Viewed',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 12,
                          color: Colors.blue.shade400,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Actions for pending applications
            if (application.isPending) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _withdrawApplication(application.id),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text(
                      'Withdraw',
                      style: TextStyle(fontFamily: 'ProductSans'),
                    ),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<LeaseApplication> _filterByStatus(dynamic status) {
    if (status is String) {
      return _applicationController.myApplications
          .where((app) => app.status == status)
          .toList();
    } else if (status is List<String>) {
      return _applicationController.myApplications
          .where((app) => status.contains(app.status))
          .toList();
    }
    return [];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _withdrawApplication(String applicationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Withdraw Application?',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to withdraw this application? This action cannot be undone.',
              style: TextStyle(fontFamily: 'ProductSans'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'ProductSans'),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Withdraw',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _applicationController.withdrawApplication(applicationId);
      await _loadApplications();
    }
  }
}
