import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class WalletNotificationsScreen extends StatefulWidget {
  const WalletNotificationsScreen({super.key});

  @override
  State<WalletNotificationsScreen> createState() =>
      _WalletNotificationsScreenState();
}

class _WalletNotificationsScreenState extends State<WalletNotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Funds Added Successfully',
      'message': 'Your wallet has been credited with ₦30,000.00',
      'time': '2 hours ago',
      'isRead': false,
      'type': 'credit',
      'amount': 30000.00,
    },
    {
      'title': 'Withdrawal Completed',
      'message': 'Your withdrawal of ₦3,700.00 has been processed successfully',
      'time': '5 hours ago',
      'isRead': false,
      'type': 'debit',
      'amount': 3700.00,
    },
    {
      'title': 'Payment Received',
      'message': 'You received ₦50,500.00 from rent payment',
      'time': '1 day ago',
      'isRead': true,
      'type': 'credit',
      'amount': 50500.00,
    },
    {
      'title': 'Transaction Failed',
      'message': 'Your transaction of ₦10,000.00 failed. Please try again',
      'time': '2 days ago',
      'isRead': true,
      'type': 'failed',
      'amount': 10000.00,
    },
    {
      'title': 'Low Balance Alert',
      'message': 'Your wallet balance is below ₦5,000.00. Please top up',
      'time': '3 days ago',
      'isRead': true,
      'type': 'alert',
      'amount': null,
    },
  ];

  Future<void> _onRefresh() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Get.back(),
          child: const Icon(CupertinoIcons.back, color: Colors.black, size: 28),
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'ProductSans',
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in _notifications) {
                    notification['isRead'] = true;
                  }
                });
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.cyan,
                ),
              ),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF26306A),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationItem(notification, index);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'ProductSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;
    final amount = notification['amount'] as double?;

    // Determine icon and color based on type
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case 'credit':
        icon = Icons.arrow_downward;
        iconColor = Colors.green[600]!;
        bgColor = Colors.green.withValues(alpha: 0.1);
        break;
      case 'debit':
        icon = Icons.arrow_upward;
        iconColor = Colors.grey[600]!;
        bgColor = Colors.grey.withValues(alpha: 0.1);
        break;
      case 'failed':
        icon = Icons.error_outline;
        iconColor = Colors.red[600]!;
        bgColor = Colors.red.withValues(alpha: 0.1);
        break;
      case 'alert':
        icon = Icons.warning_amber;
        iconColor = Colors.orange[600]!;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.blue[600]!;
        bgColor = Colors.blue.withValues(alpha: 0.1);
    }

    return Dismissible(
      key: Key('notification_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        Get.snackbar(
          'Deleted',
          'Notification removed',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              notification['isRead'] = true;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                                fontFamily: 'ProductSans',
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.cyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'ProductSans',
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification['time'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontFamily: 'ProductSans',
                            ),
                          ),
                          if (amount != null)
                            Text(
                              '₦${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: type == 'credit' ? Colors.black : Colors.grey[600],
                                fontFamily: 'ProductSans',
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
        ),
      ),
    );
  }
}
