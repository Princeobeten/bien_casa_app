import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlatmateRequestsScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const FlatmateRequestsScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  State<FlatmateRequestsScreen> createState() => _FlatmateRequestsScreenState();
}

class _FlatmateRequestsScreenState extends State<FlatmateRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for flatmate requests
  final List<Map<String, dynamic>> _allRequests = [
    {
      'id': 'req_001',
      'requesterId': 'user_001',
      'requesterName': 'John Doe',
      'requesterAge': 28,
      'requesterGender': 'Male',
      'requesterOccupation': 'Software Engineer',
      'requesterBio':
          'Clean, organized, and respectful. Love cooking and outdoor activities.',
      'requesterImage': 'https://i.pravatar.cc/150?img=12',
      'status': 'Pending',
      'message':
          'Hi! I\'m interested in joining your flatmate campaign. I think we\'d be a great match based on our preferences.',
      'requestedAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 'req_002',
      'requesterId': 'user_002',
      'requesterName': 'Sarah Johnson',
      'requesterAge': 25,
      'requesterGender': 'Female',
      'requesterOccupation': 'Graphic Designer',
      'requesterBio':
          'Creative professional looking for like-minded flatmates. Non-smoker, pet-friendly.',
      'requesterImage': 'https://i.pravatar.cc/150?img=45',
      'status': 'Pending',
      'message':
          'Your campaign looks perfect! I\'d love to be part of your flatmate group.',
      'requestedAt': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 'req_003',
      'requesterId': 'user_003',
      'requesterName': 'Michael Chen',
      'requesterAge': 30,
      'requesterGender': 'Male',
      'requesterOccupation': 'Marketing Manager',
      'requesterBio':
          'Friendly and easy-going. Enjoy gaming and movies on weekends.',
      'requesterImage': 'https://i.pravatar.cc/150?img=33',
      'status': 'Matched',
      'message': 'Looking forward to finding a great place together!',
      'requestedAt': DateTime.now().subtract(const Duration(days: 3)),
      'respondedAt': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 'req_004',
      'requesterId': 'user_004',
      'requesterName': 'Emily Williams',
      'requesterAge': 27,
      'requesterGender': 'Female',
      'requesterOccupation': 'Teacher',
      'requesterBio': 'Quiet, studious, and respectful of personal space.',
      'requesterImage': 'https://i.pravatar.cc/150?img=47',
      'status': 'Declined',
      'message': 'Hi, I\'d like to join your campaign.',
      'requestedAt': DateTime.now().subtract(const Duration(days: 5)),
      'respondedAt': DateTime.now().subtract(const Duration(days: 4)),
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

  List<Map<String, dynamic>> _getRequestsByStatus(String status) {
    return _allRequests.where((req) => req['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests = _getRequestsByStatus('Pending');
    final matchedRequests = _getRequestsByStatus('Matched');
    final declinedRequests = _getRequestsByStatus('Declined');

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flatmate Requests',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.campaignTitle,
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.black,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(text: 'Pending (${pendingRequests.length})'),
                Tab(text: 'Matched (${matchedRequests.length})'),
                Tab(text: 'Declined (${declinedRequests.length})'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(pendingRequests, 'Pending'),
                _buildRequestsList(matchedRequests, 'Matched'),
                _buildRequestsList(declinedRequests, 'Declined'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(
    List<Map<String, dynamic>> requests,
    String status,
  ) {
    if (requests.isEmpty) {
      return _buildEmptyState(status);
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

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'Pending':
        message = 'No pending requests at the moment';
        icon = Icons.inbox_outlined;
        break;
      case 'Matched':
        message = 'No matched flatmates yet';
        icon = Icons.people_outline;
        break;
      case 'Declined':
        message = 'No declined requests';
        icon = Icons.block_outlined;
        break;
      default:
        message = 'No requests';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'];
    final isPending = status == 'Pending';
    final isMatched = status == 'Matched';

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
          // Header with profile
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile image
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(request['requesterImage']),
                ),
                const SizedBox(width: 12),
                // Name and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['requesterName'],
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request['requesterAge']} • ${request['requesterGender']} • ${request['requesterOccupation']}',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                _buildStatusBadge(status),
              ],
            ),
          ),

          // Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              request['requesterBio'],
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Message
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.message_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request['message'],
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatTimestamp(request['requestedAt']),
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),

          // Action buttons (only for pending)
          if (isPending) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _declineRequest(request),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Decline',
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
                      onPressed: () => _acceptRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Accept',
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
            ),
          ],

          // View profile button (for matched)
          if (isMatched) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _viewProfile(request),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.person_outline),
                  label: const Text(
                    'View Profile',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'Pending':
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        label = 'Pending';
        break;
      case 'Matched':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        label = 'Matched';
        break;
      case 'Declined':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        label = 'Declined';
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade800;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _acceptRequest(Map<String, dynamic> request) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Accept Request',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Accept ${request['requesterName']} as a flatmate?',
          style: const TextStyle(fontFamily: 'ProductSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setState(() {
                request['status'] = 'Matched';
                request['respondedAt'] = DateTime.now();
              });
              Get.snackbar(
                'Success',
                '${request['requesterName']} has been added to your campaign',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade900,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _declineRequest(Map<String, dynamic> request) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Decline Request',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Decline request from ${request['requesterName']}?',
          style: const TextStyle(fontFamily: 'ProductSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setState(() {
                request['status'] = 'Declined';
                request['respondedAt'] = DateTime.now();
              });
              Get.snackbar(
                'Declined',
                'Request from ${request['requesterName']} has been declined',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade900,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _viewProfile(Map<String, dynamic> request) {
    Get.snackbar(
      'View Profile',
      'Opening profile for ${request['requesterName']}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
    );
  }
}
