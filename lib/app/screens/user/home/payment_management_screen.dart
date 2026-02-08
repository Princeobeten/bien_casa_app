import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({Key? key}) : super(key: key);

  @override
  State<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _allPayments = [
    {
      'id': 'pay_001',
      'propertyTitle': 'Modern 3BR Apartment',
      'type': 'Rent',
      'amount': 500000,
      'dueDate': DateTime(2025, 11, 1),
      'status': 'paid',
      'paidDate': DateTime(2025, 10, 30),
    },
    {
      'id': 'pay_002',
      'propertyTitle': 'Modern 3BR Apartment',
      'type': 'Rent',
      'amount': 500000,
      'dueDate': DateTime(2025, 12, 1),
      'status': 'pending',
    },
    {
      'id': 'pay_003',
      'propertyTitle': 'Luxury 4BR Duplex',
      'type': 'Deposit',
      'amount': 1000000,
      'dueDate': DateTime(2025, 10, 15),
      'status': 'paid',
      'paidDate': DateTime(2025, 10, 14),
    },
    {
      'id': 'pay_004',
      'propertyTitle': 'Cozy 2BR Flat',
      'type': 'Hold Amount',
      'amount': 100000,
      'dueDate': DateTime(2025, 10, 20),
      'status': 'paid',
      'paidDate': DateTime(2025, 10, 19),
    },
    {
      'id': 'pay_005',
      'propertyTitle': 'Modern 3BR Apartment',
      'type': 'Rent',
      'amount': 500000,
      'dueDate': DateTime(2026, 1, 1),
      'status': 'upcoming',
    },
    {
      'id': 'pay_006',
      'propertyTitle': 'Penthouse Suite',
      'type': 'Rent',
      'amount': 800000,
      'dueDate': DateTime(2025, 10, 25),
      'status': 'overdue',
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Payment Management',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed:
                () => Get.snackbar(
                  'Filter',
                  'Opening filters...',
                  snackPosition: SnackPosition.BOTTOM,
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 20),
          _buildWalletCard(),
          const SizedBox(height: 20),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalPaid = _allPayments
        .where((p) => p['status'] == 'paid')
        .fold<int>(0, (sum, p) => sum + (p['amount'] as int));
    final upcomingCount =
        _allPayments.where((p) => p['status'] == 'upcoming').length;
    final overdueCount =
        _allPayments.where((p) => p['status'] == 'overdue').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Paid',
              'NGN${NumberFormat('#,###').format(totalPaid)}',
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Upcoming',
              '$upcomingCount',
              Colors.blue,
              Icons.schedule,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Overdue',
              '$overdueCount',
              Colors.red,
              Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'NGN2,500,000',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed:
                () => Get.snackbar(
                  'Top Up',
                  'Opening wallet top-up...',
                  snackPosition: SnackPosition.BOTTOM,
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Top Up',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Upcoming'),
          Tab(text: 'Paid'),
          Tab(text: 'Overdue'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPaymentList(_allPayments),
        _buildPaymentList(
          _allPayments
              .where(
                (p) => p['status'] == 'upcoming' || p['status'] == 'pending',
              )
              .toList(),
        ),
        _buildPaymentList(
          _allPayments.where((p) => p['status'] == 'paid').toList(),
        ),
        _buildPaymentList(
          _allPayments.where((p) => p['status'] == 'overdue').toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentList(List<Map<String, dynamic>> payments) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: payments.length,
      itemBuilder: (context, index) => _buildPaymentCard(payments[index]),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final status = payment['status'];
    Color statusColor =
        status == 'paid'
            ? Colors.green
            : status == 'pending' || status == 'upcoming'
            ? Colors.orange
            : Colors.red;
    IconData statusIcon =
        status == 'paid'
            ? Icons.check_circle
            : status == 'pending' || status == 'upcoming'
            ? Icons.access_time
            : Icons.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      payment['propertyTitle'],
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment['type'],
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'NGN${NumberFormat('#,###').format(payment['amount'])}',
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    status == 'paid' ? 'Paid Date' : 'Due Date',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, y').format(
                      status == 'paid'
                          ? payment['paidDate']
                          : payment['dueDate'],
                    ),
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (status == 'pending' || status == 'overdue') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showPaymentDialog(payment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (status == 'paid') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _downloadReceipt(payment),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.download, size: 18),
                label: const Text(
                  'Download Receipt',
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
    );
  }

  void _showPaymentDialog(Map<String, dynamic> payment) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Payment',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property: ${payment['propertyTitle']}',
              style: const TextStyle(fontFamily: 'ProductSans'),
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${payment['type']}',
              style: const TextStyle(fontFamily: 'ProductSans'),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: NGN${NumberFormat('#,###').format(payment['amount'])}',
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pay from wallet balance?',
              style: TextStyle(fontFamily: 'ProductSans', color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Payment Successful',
                'Your payment has been processed',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(Map<String, dynamic> payment) {
    Get.snackbar(
      'Download Receipt',
      'Downloading receipt for ${payment['type']}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
