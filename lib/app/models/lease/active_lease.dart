/// ActiveLease Model - Active rental agreement
/// Represents an active lease between tenant and owner
class ActiveLease {
  final String id;
  final String houseLeaseId;
  final String leaseApplicationId;
  final String tenantId;
  final String ownerId;
  final String? inspectionId;
  final DateTime leaseStartDate;
  final DateTime leaseEndDate;
  final int leaseDurationValue;
  final String leaseDurationUnit; // 'Days', 'Weeks', 'Months'
  final String? agreementDocument; // URL to signed agreement
  final bool tenantAccepted;
  final bool ownerAccepted;
  final String paymentStatus; // 'Pending', 'Completed', 'Partial'
  final String
  leaseStatus; // 'Pending_review', 'Accepted', 'Active', 'Declined', 'Terminated', 'Withdrawn', 'Renewed', 'Expired'
  final DateTime? terminatedAt;
  final String? terminationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional tracking fields
  final double? totalAmount;
  final double? paidAmount;
  final DateTime? lastPaymentDate;
  final DateTime? nextPaymentDate;
  final String? renewalStatus;

  ActiveLease({
    required this.id,
    required this.houseLeaseId,
    required this.leaseApplicationId,
    required this.tenantId,
    required this.ownerId,
    this.inspectionId,
    required this.leaseStartDate,
    required this.leaseEndDate,
    required this.leaseDurationValue,
    required this.leaseDurationUnit,
    this.agreementDocument,
    this.tenantAccepted = false,
    this.ownerAccepted = false,
    required this.paymentStatus,
    required this.leaseStatus,
    this.terminatedAt,
    this.terminationReason,
    required this.createdAt,
    required this.updatedAt,
    this.totalAmount,
    this.paidAmount,
    this.lastPaymentDate,
    this.nextPaymentDate,
    this.renewalStatus,
  });

  /// Create ActiveLease from JSON
  factory ActiveLease.fromJson(Map<String, dynamic> json) {
    return ActiveLease(
      id: json['id'] as String,
      houseLeaseId: json['houseLeaseId'] as String,
      leaseApplicationId: json['leaseApplicationId'] as String,
      tenantId: json['tenantId'] as String,
      ownerId: json['ownerId'] as String,
      inspectionId: json['inspectionId'] as String?,
      leaseStartDate: DateTime.parse(json['leaseStartDate'] as String),
      leaseEndDate: DateTime.parse(json['leaseEndDate'] as String),
      leaseDurationValue: json['leaseDurationValue'] as int,
      leaseDurationUnit: json['leaseDurationUnit'] as String,
      agreementDocument: json['agreementDocument'] as String?,
      tenantAccepted: json['tenantAccepted'] as bool? ?? false,
      ownerAccepted: json['ownerAccepted'] as bool? ?? false,
      paymentStatus: json['paymentStatus'] as String,
      leaseStatus: json['leaseStatus'] as String,
      terminatedAt:
          json['terminatedAt'] != null
              ? DateTime.parse(json['terminatedAt'] as String)
              : null,
      terminationReason: json['terminationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      totalAmount:
          json['totalAmount'] != null
              ? (json['totalAmount'] as num).toDouble()
              : null,
      paidAmount:
          json['paidAmount'] != null
              ? (json['paidAmount'] as num).toDouble()
              : null,
      lastPaymentDate:
          json['lastPaymentDate'] != null
              ? DateTime.parse(json['lastPaymentDate'] as String)
              : null,
      nextPaymentDate:
          json['nextPaymentDate'] != null
              ? DateTime.parse(json['nextPaymentDate'] as String)
              : null,
      renewalStatus: json['renewalStatus'] as String?,
    );
  }

  /// Convert ActiveLease to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'houseLeaseId': houseLeaseId,
      'leaseApplicationId': leaseApplicationId,
      'tenantId': tenantId,
      'ownerId': ownerId,
      'inspectionId': inspectionId,
      'leaseStartDate': leaseStartDate.toIso8601String(),
      'leaseEndDate': leaseEndDate.toIso8601String(),
      'leaseDurationValue': leaseDurationValue,
      'leaseDurationUnit': leaseDurationUnit,
      'agreementDocument': agreementDocument,
      'tenantAccepted': tenantAccepted,
      'ownerAccepted': ownerAccepted,
      'paymentStatus': paymentStatus,
      'leaseStatus': leaseStatus,
      'terminatedAt': terminatedAt?.toIso8601String(),
      'terminationReason': terminationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
      'renewalStatus': renewalStatus,
    };
  }

  /// Create a copy with updated fields
  ActiveLease copyWith({
    String? id,
    String? houseLeaseId,
    String? leaseApplicationId,
    String? tenantId,
    String? ownerId,
    String? inspectionId,
    DateTime? leaseStartDate,
    DateTime? leaseEndDate,
    int? leaseDurationValue,
    String? leaseDurationUnit,
    String? agreementDocument,
    bool? tenantAccepted,
    bool? ownerAccepted,
    String? paymentStatus,
    String? leaseStatus,
    DateTime? terminatedAt,
    String? terminationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalAmount,
    double? paidAmount,
    DateTime? lastPaymentDate,
    DateTime? nextPaymentDate,
    String? renewalStatus,
  }) {
    return ActiveLease(
      id: id ?? this.id,
      houseLeaseId: houseLeaseId ?? this.houseLeaseId,
      leaseApplicationId: leaseApplicationId ?? this.leaseApplicationId,
      tenantId: tenantId ?? this.tenantId,
      ownerId: ownerId ?? this.ownerId,
      inspectionId: inspectionId ?? this.inspectionId,
      leaseStartDate: leaseStartDate ?? this.leaseStartDate,
      leaseEndDate: leaseEndDate ?? this.leaseEndDate,
      leaseDurationValue: leaseDurationValue ?? this.leaseDurationValue,
      leaseDurationUnit: leaseDurationUnit ?? this.leaseDurationUnit,
      agreementDocument: agreementDocument ?? this.agreementDocument,
      tenantAccepted: tenantAccepted ?? this.tenantAccepted,
      ownerAccepted: ownerAccepted ?? this.ownerAccepted,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      leaseStatus: leaseStatus ?? this.leaseStatus,
      terminatedAt: terminatedAt ?? this.terminatedAt,
      terminationReason: terminationReason ?? this.terminationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      renewalStatus: renewalStatus ?? this.renewalStatus,
    );
  }

  /// Check if both parties accepted
  bool get isBothAccepted => tenantAccepted && ownerAccepted;

  /// Check if lease is active
  bool get isActive => leaseStatus == 'Active';

  /// Check if lease is pending
  bool get isPending => leaseStatus == 'Pending_review';

  /// Check if lease is terminated
  bool get isTerminated => leaseStatus == 'Terminated';

  /// Check if lease is expired
  bool get isExpired => leaseStatus == 'Expired';

  /// Check if lease is renewed
  bool get isRenewed => leaseStatus == 'Renewed';

  /// Check if payment is completed
  bool get isPaymentCompleted => paymentStatus == 'Completed';

  /// Check if payment is pending
  bool get isPaymentPending => paymentStatus == 'Pending';

  /// Check if payment is partial
  bool get isPaymentPartial => paymentStatus == 'Partial';

  /// Calculate days until lease ends
  int get daysUntilEnd => leaseEndDate.difference(DateTime.now()).inDays;

  /// Check if lease is ending soon (within 30 days)
  bool get isEndingSoon => daysUntilEnd <= 30 && daysUntilEnd > 0;

  /// Get payment progress percentage
  double get paymentProgress {
    if (totalAmount == null || totalAmount == 0) return 0;
    return ((paidAmount ?? 0) / totalAmount!) * 100;
  }

  /// Get formatted total amount
  String? get formattedTotalAmount =>
      totalAmount != null ? 'NGN${totalAmount!.toStringAsFixed(2)}' : null;

  /// Get formatted paid amount
  String? get formattedPaidAmount =>
      paidAmount != null ? 'NGN${paidAmount!.toStringAsFixed(2)}' : null;

  /// Get lease duration display
  String get leaseDurationDisplay => '$leaseDurationValue $leaseDurationUnit';
}

/// Enum for payment status
enum PaymentStatus {
  pending,
  completed,
  partial;

  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.partial:
        return 'Partial';
    }
  }
}

/// Enum for lease status
enum LeaseStatusEnum {
  pendingReview,
  accepted,
  active,
  declined,
  terminated,
  withdrawn,
  renewed,
  expired;

  String get value {
    switch (this) {
      case LeaseStatusEnum.pendingReview:
        return 'Pending_review';
      case LeaseStatusEnum.accepted:
        return 'Accepted';
      case LeaseStatusEnum.active:
        return 'Active';
      case LeaseStatusEnum.declined:
        return 'Declined';
      case LeaseStatusEnum.terminated:
        return 'Terminated';
      case LeaseStatusEnum.withdrawn:
        return 'Withdrawn';
      case LeaseStatusEnum.renewed:
        return 'Renewed';
      case LeaseStatusEnum.expired:
        return 'Expired';
    }
  }
}

/// Enum for lease duration unit
enum LeaseDurationUnit {
  days,
  weeks,
  months;

  String get value {
    switch (this) {
      case LeaseDurationUnit.days:
        return 'Days';
      case LeaseDurationUnit.weeks:
        return 'Weeks';
      case LeaseDurationUnit.months:
        return 'Months';
    }
  }
}
