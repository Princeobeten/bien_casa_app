import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CampaignContributionsScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;
  final int totalMembers;

  const CampaignContributionsScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
    required this.totalMembers,
  });

  @override
  State<CampaignContributionsScreen> createState() =>
      _CampaignContributionsScreenState();
}

class _CampaignContributionsScreenState
    extends State<CampaignContributionsScreen> {
  // Mock data - replace with actual data from controller/API
  final List<Map<String, dynamic>> _contributions = [
    {
      'id': 'cont_1',
      'contributorId': 'user_1',
      'contributorName': 'You',
      'contributorAvatar': 'https://i.pravatar.cc/150?img=1',
      'amount': 150000,
      'paymentStatus': 'Completed',
      'paymentReference': 'PAY-123456',
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      'isCurrentUser': true,
    },
    {
      'id': 'cont_2',
      'contributorId': 'user_2',
      'contributorName': 'Sarah Johnson',
      'contributorAvatar': 'https://i.pravatar.cc/150?img=5',
      'amount': 150000,
      'paymentStatus': 'Completed',
      'paymentReference': 'PAY-123457',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      'isCurrentUser': false,
    },
    {
      'id': 'cont_3',
      'contributorId': 'user_3',
      'contributorName': 'Michael Chen',
      'contributorAvatar': 'https://i.pravatar.cc/150?img=8',
      'amount': 100000,
      'paymentStatus': 'Pending',
      'paymentReference': 'PAY-123458',
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
      'isCurrentUser': false,
    },
  ];

  double get _totalPooledFunds {
    return _contributions
        .where((c) => c['paymentStatus'] == 'Completed')
        .fold(0.0, (sum, c) => sum + (c['amount'] as num).toDouble());
  }

  double get _pendingFunds {
    return _contributions
        .where((c) => c['paymentStatus'] == 'Pending')
        .fold(0.0, (sum, c) => sum + (c['amount'] as num).toDouble());
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campaign Contributions',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.campaignTitle,
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Total Pooled Funds Card
          _buildPooledFundsCard(),

          // Info Banner
          _buildInfoBanner(),

          // Contributions List
          Expanded(
            child:
                _contributions.isEmpty
                    ? _buildEmptyState()
                    : _buildContributionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContribution,
        backgroundColor: Colors.black,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Contribution',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPooledFundsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Container(
              //   padding: const EdgeInsets.all(10),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: const Icon(
              //     Icons.account_balance_wallet,
              //     color: Colors.white,
              //     size: 24,
              //   ),
              // ),
              const Expanded(
                child: Text(
                  'Total Pooled Funds',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _withdrawToWallet,
                child: SvgPicture.asset(
                  'assets/icons/hugeicons--reverse-withdrawal-01.svg',
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  width: 32,
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatAmount(_totalPooledFunds),
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatChip(
                icon: Icons.people,
                label: '${_contributions.length} Contributors',
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 8),
              if (_pendingFunds > 0)
                _buildStatChip(
                  icon: Icons.pending,
                  label: 'Pending: ${_formatAmount(_pendingFunds)}',
                  color: Colors.orange.shade100,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Contributions are pooled for group expenses like deposits, inspections, or rent.',
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _contributions.length,
      itemBuilder: (context, index) {
        final contribution = _contributions[index];
        return _buildContributionCard(contribution);
      },
    );
  }

  Widget _buildContributionCard(Map<String, dynamic> contribution) {
    final bool isCompleted = contribution['paymentStatus'] == 'Completed';
    final bool isPending = contribution['paymentStatus'] == 'Pending';
    final bool isCurrentUser = contribution['isCurrentUser'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  contribution['contributorAvatar'],
                ),
              ),
              const SizedBox(width: 12),

              // Contributor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          contribution['contributorName'],
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'You',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 11,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(contribution['createdAt']),
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(contribution['amount']),
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? Colors.green.shade50
                              : isPending
                              ? Colors.orange.shade50
                              : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle
                              : isPending
                              ? Icons.pending
                              : Icons.error,
                          size: 14,
                          color:
                              isCompleted
                                  ? Colors.green.shade700
                                  : isPending
                                  ? Colors.orange.shade700
                                  : Colors.red.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          contribution['paymentStatus'],
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 12,
                            color:
                                isCompleted
                                    ? Colors.green.shade700
                                    : isPending
                                    ? Colors.orange.shade700
                                    : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Payment Reference
          if (contribution['paymentReference'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.receipt, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Ref: ${contribution['paymentReference']}',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Contributions Yet',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start pooling funds with your campaign members for group expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addContribution,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add First Contribution',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addContribution() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddContributionSheet(),
    );
  }

  Widget _buildAddContributionSheet() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add Contribution',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount Field
            const Text(
              'Amount',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefixText: 'NGN ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note Field
            const Text(
              'Note (Optional)',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add a note about this contribution',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Process payment and add contribution
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Contribution added successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Proceed to Payment',
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
    );
  }

  void _withdrawToWallet() {
    if (_totalPooledFunds <= 0) {
      Get.snackbar(
        'No Funds',
        'There are no funds available to withdraw',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Withdraw to Wallet',
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
              'Withdraw pooled funds to your personal wallet?',
              style: TextStyle(
                fontFamily: 'ProductSans',
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Amount',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatAmount(_totalPooledFunds),
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 18,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Note: This requires approval from other campaign members.',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 12,
                color: Colors.orange.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Create transfer request for approval
              Get.snackbar(
                'Transfer Request Created',
                'Waiting for approval from campaign members',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Request Withdrawal',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(num amount) {
    return 'NGN${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
