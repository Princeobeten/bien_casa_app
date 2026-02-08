import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/lease/lease_application.dart';
import '../../../controllers/lease/application_controller.dart';
import '../../../widgets/status_badges/status_badge.dart';
import '../../../routes/app_routes.dart';

/// ApplicationsListScreen - Home owner view of received applications
class ApplicationsListScreen extends StatefulWidget {
  const ApplicationsListScreen({Key? key}) : super(key: key);

  @override
  State<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends State<ApplicationsListScreen>
    with SingleTickerProviderStateMixin {
  ApplicationController? _applicationController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    try {
      _applicationController = Get.put(ApplicationController());
      _loadApplications();
    } catch (e) {
      print('Error initializing ApplicationController: $e');
      // Initialize with empty controller if there's an error
      _applicationController = ApplicationController();
    }
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
    // const String ownerId = 'owner_001';
    // await _applicationController.fetchReceivedApplications(ownerId);
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
        viewedByOwner: false,
      ),
      LeaseApplication(
        id: 'app_002',
        houseLeaseId: 'lease_002',
        applicantId: 'user_456',
        applicationType: 'negotiation',
        proposedPrice: 4500000,
        status: 'Pending_review',
        message: 'Looking for a long-term rental. I am a working professional.',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        viewedByOwner: true,
      ),
      LeaseApplication(
        id: 'app_003',
        houseLeaseId: 'lease_003',
        applicantId: 'user_789',
        applicationType: 'immediate_rent',
        status: 'Approved_by_owner',
        message: 'I need a place close to my workplace.',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
        approvedAt: now.subtract(const Duration(days: 2)),
        viewedByOwner: true,
      ),
      LeaseApplication(
        id: 'app_004',
        houseLeaseId: 'lease_004',
        applicantId: 'user_321',
        applicationType: 'negotiation',
        proposedPrice: 3000000,
        status: 'Declined_by_owner',
        message: 'Family of 4 looking for a peaceful neighborhood.',
        declineReason: 'Property already rented to another tenant.',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 4)),
        declinedAt: now.subtract(const Duration(days: 4)),
        viewedByOwner: true,
      ),
    ];

    // Add mock data to controller
    _applicationController?.receivedApplications.clear();
    _applicationController?.receivedApplications.addAll(mockApplications);
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
          'Applications',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 35,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          labelStyle: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Declined'),
          ],
        ),
      ),
      body: Obx(
        () => TabBarView(
          controller: _tabController,
          children: [
            _buildApplicationList(
              _applicationController?.receivedApplications ?? [],
            ),
            _buildApplicationList(
              _applicationController?.receivedApplications
                      .where((app) => app.isPending)
                      .toList() ??
                  [],
            ),
            _buildApplicationList(
              _applicationController?.receivedApplications
                      .where((app) => app.isApproved)
                      .toList() ??
                  [],
            ),
            _buildApplicationList(
              _applicationController?.receivedApplications
                      .where((app) => app.isDeclined)
                      .toList() ??
                  [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationList(List<LeaseApplication> applications) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No Applications',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Applications will appear here',
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
          final application = applications[index];
          return _buildApplicationCard(application);
        },
      ),
    );
  }

  Widget _buildApplicationCard(LeaseApplication application) {
    // Mock property data mapping
    final propertyData = {
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

    final property = propertyData[application.houseLeaseId];

    return GestureDetector(
      onTap: () {
        // Navigate to application detail screen
        Get.toNamed(AppRoutes.APPLICATION_DETAIL, arguments: application);
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
                    property?['image'] ?? 'https://via.placeholder.com/80',
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
                        property?['title'] ?? 'Property',
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
                        property?['location'] ?? 'Location',
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
                // New indicator
                if (!application.viewedByOwner)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
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
                Text(
                  _formatDate(application.createdAt),
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Applicant ID: ${application.applicantId.substring(0, 8)}',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
