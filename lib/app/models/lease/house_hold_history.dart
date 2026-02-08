/// HouseHoldHistory Model - Property hold/reservation
/// Represents a temporary hold on a property
class HouseHoldHistory {
  final String id;
  final String houseLeaseId;
  final String userId;
  final double holdAmount;
  final String
  holdStatus; // 'Pending', 'Active', 'Completed', 'Cancelled', 'Expired'
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields
  final String? paymentReference;
  final bool isPaymentSuccessful;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  HouseHoldHistory({
    required this.id,
    required this.houseLeaseId,
    required this.userId,
    required this.holdAmount,
    required this.holdStatus,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.paymentReference,
    this.isPaymentSuccessful = false,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  /// Create HouseHoldHistory from JSON
  factory HouseHoldHistory.fromJson(Map<String, dynamic> json) {
    return HouseHoldHistory(
      id: json['id'] as String,
      houseLeaseId: json['houseLeaseId'] as String,
      userId: json['userId'] as String,
      holdAmount: (json['holdAmount'] as num).toDouble(),
      holdStatus: json['holdStatus'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      paymentReference: json['paymentReference'] as String?,
      isPaymentSuccessful: json['isPaymentSuccessful'] as bool? ?? false,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
      cancelledAt:
          json['cancelledAt'] != null
              ? DateTime.parse(json['cancelledAt'] as String)
              : null,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  /// Convert HouseHoldHistory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'houseLeaseId': houseLeaseId,
      'userId': userId,
      'holdAmount': holdAmount,
      'holdStatus': holdStatus,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'paymentReference': paymentReference,
      'isPaymentSuccessful': isPaymentSuccessful,
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  /// Create a copy with updated fields
  HouseHoldHistory copyWith({
    String? id,
    String? houseLeaseId,
    String? userId,
    double? holdAmount,
    String? holdStatus,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentReference,
    bool? isPaymentSuccessful,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return HouseHoldHistory(
      id: id ?? this.id,
      houseLeaseId: houseLeaseId ?? this.houseLeaseId,
      userId: userId ?? this.userId,
      holdAmount: holdAmount ?? this.holdAmount,
      holdStatus: holdStatus ?? this.holdStatus,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentReference: paymentReference ?? this.paymentReference,
      isPaymentSuccessful: isPaymentSuccessful ?? this.isPaymentSuccessful,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  /// Check if hold is pending
  bool get isPending => holdStatus == 'Pending';

  /// Check if hold is active
  bool get isActive => holdStatus == 'Active';

  /// Check if hold is completed
  bool get isCompleted => holdStatus == 'Completed';

  /// Check if hold is cancelled
  bool get isCancelled => holdStatus == 'Cancelled';

  /// Check if hold is expired
  bool get isExpired =>
      holdStatus == 'Expired' || expiresAt.isBefore(DateTime.now());

  /// Get time remaining until expiry
  Duration get timeRemaining => expiresAt.difference(DateTime.now());

  /// Get hours remaining
  int get hoursRemaining => timeRemaining.inHours;

  /// Get minutes remaining
  int get minutesRemaining => timeRemaining.inMinutes % 60;

  /// Check if hold is expiring soon (within 1 hour)
  bool get isExpiringSoon => hoursRemaining <= 1 && hoursRemaining >= 0;

  /// Get formatted hold amount
  String get formattedHoldAmount => 'NGN${holdAmount.toStringAsFixed(2)}';

  /// Get formatted expiry date
  String get formattedExpiryDate {
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
    return '${expiresAt.day} ${months[expiresAt.month - 1]} ${expiresAt.year} at ${expiresAt.hour}:${expiresAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get time remaining display
  String get timeRemainingDisplay {
    if (isExpired) return 'Expired';
    if (hoursRemaining < 1) return '$minutesRemaining minutes';
    if (hoursRemaining < 24) return '$hoursRemaining hours';
    return '${timeRemaining.inDays} days';
  }
}

/// Enum for hold status
enum HoldStatus {
  pending,
  active,
  completed,
  cancelled,
  expired;

  String get value {
    switch (this) {
      case HoldStatus.pending:
        return 'Pending';
      case HoldStatus.active:
        return 'Active';
      case HoldStatus.completed:
        return 'Completed';
      case HoldStatus.cancelled:
        return 'Cancelled';
      case HoldStatus.expired:
        return 'Expired';
    }
  }
}
