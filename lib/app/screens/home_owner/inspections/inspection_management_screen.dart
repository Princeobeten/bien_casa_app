import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// InspectionManagementScreen - Home owner manages inspection requests
class InspectionManagementScreen extends StatefulWidget {
  const InspectionManagementScreen({Key? key}) : super(key: key);

  @override
  State<InspectionManagementScreen> createState() =>
      _InspectionManagementScreenState();
}

class _InspectionManagementScreenState extends State<InspectionManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock inspection request data
  final List<Map<String, dynamic>> _inspectionRequests = [
    {
      'id': 'insp_req_001',
      'propertyTitle': 'Modern 3BR Apartment in Lekki',
      'propertyImage':
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'location': 'Lekki Phase 1, Lagos',
      'requesterName': 'John Doe',
      'requesterPhone': '+234 801 234 5678',
      'requestedDate': DateTime.now().add(const Duration(days: 2)),
      'requestedTime': '10:00 AM',
      'status': 'pending',
      'notes': 'Interested in viewing the property this weekend',
      'submittedAt': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': 'insp_req_002',
      'propertyTitle': 'Luxury 4BR Duplex with Pool',
      'propertyImage':
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      'location': 'Victoria Island, Lagos',
      'requesterName': 'Sarah Johnson',
      'requesterPhone': '+234 802 345 6789',
      'requestedDate': DateTime.now().add(const Duration(days: 5)),
      'requestedTime': '2:00 PM',
      'status': 'pending',
      'notes': '',
      'submittedAt': DateTime.now().subtract(const Duration(hours: 12)),
    },
    {
      'id': 'insp_req_003',
      'propertyTitle': 'Cozy 2BR Flat in Ikeja',
      'propertyImage':
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      'location': 'Ikeja GRA, Lagos',
      'requesterName': 'Michael Chen',
      'requesterPhone': '+234 803 456 7890',
      'requestedDate': DateTime.now().add(const Duration(days: 1)),
      'requestedTime': '11:00 AM',
      'status': 'approved',
      'notes': 'Looking for a place close to work',
      'submittedAt': DateTime.now().subtract(const Duration(days: 1)),
      'approvedAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 'insp_req_004',
      'propertyTitle': 'Spacious 3BR with Garden',
      'propertyImage':
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      'location': 'Ikoyi, Lagos',
      'requesterName': 'Emma Williams',
      'requesterPhone': '+234 804 567 8901',
      'requestedDate': DateTime.now().subtract(const Duration(days: 1)),
      'requestedTime': '3:00 PM',
      'status': 'completed',
      'notes': '',
      'submittedAt': DateTime.now().subtract(const Duration(days: 3)),
      'completedAt': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 'insp_req_005',
      'propertyTitle': 'Modern Studio Apartment',
      'propertyImage':
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      'location': 'Yaba, Lagos',
      'requesterName': 'David Brown',
      'requesterPhone': '+234 805 678 9012',
      'requestedDate': DateTime.now().add(const Duration(days: 3)),
      'requestedTime': '4:00 PM',
      'status': 'declined',
      'notes': 'Urgent viewing needed',
      'submittedAt': DateTime.now().subtract(const Duration(hours: 8)),
      'declinedAt': DateTime.now().subtract(const Duration(hours: 1)),
      'declineReason': 'Property not available on requested date',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          'Inspection Requests',
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
              isScrollable: true,
              labelStyle: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(_inspectionRequests),
                _buildRequestList(
                  _inspectionRequests
                      .where((req) => req['status'] == 'pending')
                      .toList(),
                ),
                _buildRequestList(
                  _inspectionRequests
                      .where((req) => req['status'] == 'approved')
                      .toList(),
                ),
                _buildRequestList(
                  _inspectionRequests
                      .where((req) => req['status'] == 'completed')
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> requests) {
    if (requests.isEmpty) {
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
                Icons.calendar_today,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Inspection Requests',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any inspection requests yet',
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
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final String status = request['status'];
    final DateTime requestedDate = request['requestedDate'];
    final bool isPending = status == 'pending';
    final bool isApproved = status == 'approved';
    final bool isUpcoming = requestedDate.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  request['propertyImage'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.home, size: 60),
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
          // Request Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['propertyTitle'],
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
                        request['location'],
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
                // Requester Info
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
                            request['requesterName'],
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
                            request['requesterPhone'],
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
                // Requested Date & Time
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(requestedDate),
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
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          request['requestedTime'],
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (request['notes'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request['notes'],
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (status == 'declined' &&
                    request['declineReason'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 16,
                          color: Colors.red.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Declined: ${request['declineReason']}',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 12,
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: OutlinedButton(
                            onPressed: () => _declineRequest(request),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Decline',
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
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () => _approveRequest(request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff020202),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Approve',
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
                if (isApproved && isUpcoming) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () => _markAsCompleted(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mark as Completed',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      case 'declined':
        return 'Declined';
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

  void _approveRequest(Map<String, dynamic> request) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Approve Inspection?',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Confirm inspection for ${request['requesterName']} on ${_formatDate(request['requestedDate'])} at ${request['requestedTime']}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.grey[700],
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
                        side: const BorderSide(color: Colors.black, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Approved',
                          'Inspection request has been approved',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green.shade100,
                          colorText: Colors.green.shade900,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Approve',
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
            ],
          ),
        ),
      ),
    );
  }

  void _declineRequest(Map<String, dynamic> request) {
    final TextEditingController reasonController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_outlined, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Decline Inspection?',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please provide a reason for declining',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason...',
                  hintStyle: TextStyle(
                    fontFamily: 'ProductSans',
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        reasonController.dispose();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (reasonController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please provide a reason',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }
                        reasonController.dispose();
                        Get.back();
                        Get.snackbar(
                          'Declined',
                          'Inspection request has been declined',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Decline',
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
            ],
          ),
        ),
      ),
    );
  }

  void _markAsCompleted(Map<String, dynamic> request) {
    Get.snackbar(
      'Completed',
      'Inspection marked as completed',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
  }
}
