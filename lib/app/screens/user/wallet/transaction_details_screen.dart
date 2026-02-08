import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  Widget _buildNairaSymbol({double size = 16, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/naira.svg',
      width: size,
      height: size,
      color: color ?? Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> transaction = Get.arguments ?? {};
    final bool isPositive = (transaction['amount'] ?? 0) > 0;

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Transaction Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'ProductSans',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: Colors.black),
            onPressed: () {},
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Transaction Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Transaction Title
            Text(
              transaction['title'] ?? 'Transaction',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'ProductSans',
              ),
            ),
            const SizedBox(height: 32),

            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isPositive)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      '- ',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ProductSans',
                        color: Colors.black,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _buildNairaSymbol(
                    size: 49,
                    color: isPositive ? Colors.green[700] : Colors.black,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  (transaction['amount'] ?? 0)
                      .abs()
                      .toStringAsFixed(2)
                      .replaceAll(RegExp(r'\\.0*$'), ''),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ProductSans',
                    color: isPositive ? Colors.green[700] : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Successful',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Transaction Details
            _buildDetailRowWithAmount(
              'Amount',
              (transaction['amount'] ?? 0).abs(),
            ),
            _buildDetailRowWithAmount('Fee', 0.00),
            _buildDetailRowWithAmount(
              'Amount Paid',
              (transaction['amount'] ?? 0).abs(),
            ),

            const SizedBox(height: 24),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 24),

            _buildDetailRow(
              'Recipient Details',
              'VICTOR CHARLES AMA',
              bold: true,
            ),
            _buildDetailRow('', 'Bien Casa Wallet | 3070350169'),

            const SizedBox(height: 24),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 24),

            _buildDetailRow(
              'Remark',
              transaction['type'] == 'funds_added'
                  ? 'Add funds'
                  : 'Debit transaction',
            ),
            _buildDetailRowWithCopy(
              context,
              'Transaction No.',
              '873673882783947438944747',
            ),
            _buildDetailRow('Payment Method', 'Quinance Wallet'),
            _buildDetailRow('Transaction Date', 'May 21st, 2025 19:04:25'),
            _buildDetailRowWithCopy(
              context,
              'Session ID',
              '012838239724394834834907',
            ),

            const SizedBox(height: 24),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 24),

            // Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontFamily: 'ProductSans',
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Transfer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Report Issue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Share Receipt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontFamily: 'ProductSans',
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithAmount(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNairaSymbol(size: 13, color: Colors.grey[800]),
              const SizedBox(width: 2),
              Text(
                amount.toStringAsFixed(2).replaceAll(RegExp(r'\\.0*$'), ''),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'ProductSans',
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithCopy(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'ProductSans',
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$label copied to clipboard',
                          style: const TextStyle(fontFamily: 'ProductSans'),
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.black87,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.copy, size: 16, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
