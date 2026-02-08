import 'package:flutter/material.dart';

/// StatusBadge - Reusable status badge widget
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsets? padding;

  const StatusBadge({
    Key? key,
    required this.status,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(status);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors['background'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          fontFamily: 'ProductSans',
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w600,
          color: textColor ?? colors['text'],
        ),
      ),
    );
  }

  /// Get colors based on status
  Map<String, Color> _getStatusColors(String status) {
    final statusLower = status.toLowerCase();

    // Lease/Application statuses
    if (statusLower.contains('active') || statusLower.contains('approved')) {
      return {'background': Colors.green.shade100, 'text': Colors.green.shade700};
    } else if (statusLower.contains('pending')) {
      return {'background': Colors.orange.shade100, 'text': Colors.orange.shade700};
    } else if (statusLower.contains('declined') || statusLower.contains('rejected') || statusLower.contains('cancelled')) {
      return {'background': Colors.red.shade100, 'text': Colors.red.shade700};
    } else if (statusLower.contains('completed')) {
      return {'background': Colors.blue.shade100, 'text': Colors.blue.shade700};
    } else if (statusLower.contains('draft')) {
      return {'background': Colors.grey.shade100, 'text': Colors.grey.shade700};
    } else if (statusLower.contains('scheduled')) {
      return {'background': Colors.purple.shade100, 'text': Colors.purple.shade700};
    } else if (statusLower.contains('verified')) {
      return {'background': Colors.teal.shade100, 'text': Colors.teal.shade700};
    } else if (statusLower.contains('withdrawn')) {
      return {'background': Colors.grey.shade200, 'text': Colors.grey.shade600};
    } else if (statusLower.contains('expired')) {
      return {'background': Colors.red.shade50, 'text': Colors.red.shade600};
    } else if (statusLower.contains('matched')) {
      return {'background': Colors.green.shade100, 'text': Colors.green.shade700};
    }

    // Default
    return {'background': Colors.grey.shade100, 'text': Colors.grey.shade700};
  }

  /// Format status text
  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

/// LeaseStatusBadge - Specific badge for lease status
class LeaseStatusBadge extends StatelessWidget {
  final String status;

  const LeaseStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusBadge(status: status);
  }
}

/// ApplicationStatusBadge - Specific badge for application status
class ApplicationStatusBadge extends StatelessWidget {
  final String status;

  const ApplicationStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusBadge(status: status);
  }
}

/// PaymentStatusBadge - Specific badge for payment status
class PaymentStatusBadge extends StatelessWidget {
  final String status;

  const PaymentStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusBadge(status: status);
  }
}
