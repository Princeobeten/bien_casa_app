/// LeaseApplication Model - Tenant application for a lease
/// Represents a tenant's application to rent a property
class LeaseApplication {
  final String id;
  final String houseLeaseId;
  final String applicantId;
  final String applicationType; // 'immediate_rent', 'negotiation'
  final double? proposedPrice;
  final String? message;
  final String
  status; // 'Pending_review', 'Approved_by_owner', 'Approved_by_realtor', 'Declined_by_owner', 'Declined_by_realtor', 'Withdrawn'
  final bool viewedByOwner;
  final DateTime? viewedAt;
  final String? paymentReference;
  final bool isPaymentSuccessful;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for tracking
  final String? declineReason;
  final DateTime? approvedAt;
  final DateTime? declinedAt;
  final DateTime? withdrawnAt;

  LeaseApplication({
    required this.id,
    required this.houseLeaseId,
    required this.applicantId,
    required this.applicationType,
    this.proposedPrice,
    this.message,
    required this.status,
    this.viewedByOwner = false,
    this.viewedAt,
    this.paymentReference,
    this.isPaymentSuccessful = false,
    required this.createdAt,
    required this.updatedAt,
    this.declineReason,
    this.approvedAt,
    this.declinedAt,
    this.withdrawnAt,
  });

  /// Create LeaseApplication from JSON
  factory LeaseApplication.fromJson(Map<String, dynamic> json) {
    return LeaseApplication(
      id: json['id'] as String,
      houseLeaseId: json['houseLeaseId'] as String,
      applicantId: json['applicantId'] as String,
      applicationType: json['applicationType'] as String,
      proposedPrice:
          json['proposedPrice'] != null
              ? (json['proposedPrice'] as num).toDouble()
              : null,
      message: json['message'] as String?,
      status: json['status'] as String,
      viewedByOwner: json['viewedByOwner'] as bool? ?? false,
      viewedAt:
          json['viewedAt'] != null
              ? DateTime.parse(json['viewedAt'] as String)
              : null,
      paymentReference: json['paymentReference'] as String?,
      isPaymentSuccessful: json['isPaymentSuccessful'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      declineReason: json['declineReason'] as String?,
      approvedAt:
          json['approvedAt'] != null
              ? DateTime.parse(json['approvedAt'] as String)
              : null,
      declinedAt:
          json['declinedAt'] != null
              ? DateTime.parse(json['declinedAt'] as String)
              : null,
      withdrawnAt:
          json['withdrawnAt'] != null
              ? DateTime.parse(json['withdrawnAt'] as String)
              : null,
    );
  }

  /// Convert LeaseApplication to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'houseLeaseId': houseLeaseId,
      'applicantId': applicantId,
      'applicationType': applicationType,
      'proposedPrice': proposedPrice,
      'message': message,
      'status': status,
      'viewedByOwner': viewedByOwner,
      'viewedAt': viewedAt?.toIso8601String(),
      'paymentReference': paymentReference,
      'isPaymentSuccessful': isPaymentSuccessful,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'declineReason': declineReason,
      'approvedAt': approvedAt?.toIso8601String(),
      'declinedAt': declinedAt?.toIso8601String(),
      'withdrawnAt': withdrawnAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  LeaseApplication copyWith({
    String? id,
    String? houseLeaseId,
    String? applicantId,
    String? applicationType,
    double? proposedPrice,
    String? message,
    String? status,
    bool? viewedByOwner,
    DateTime? viewedAt,
    String? paymentReference,
    bool? isPaymentSuccessful,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? declineReason,
    DateTime? approvedAt,
    DateTime? declinedAt,
    DateTime? withdrawnAt,
  }) {
    return LeaseApplication(
      id: id ?? this.id,
      houseLeaseId: houseLeaseId ?? this.houseLeaseId,
      applicantId: applicantId ?? this.applicantId,
      applicationType: applicationType ?? this.applicationType,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      message: message ?? this.message,
      status: status ?? this.status,
      viewedByOwner: viewedByOwner ?? this.viewedByOwner,
      viewedAt: viewedAt ?? this.viewedAt,
      paymentReference: paymentReference ?? this.paymentReference,
      isPaymentSuccessful: isPaymentSuccessful ?? this.isPaymentSuccessful,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      declineReason: declineReason ?? this.declineReason,
      approvedAt: approvedAt ?? this.approvedAt,
      declinedAt: declinedAt ?? this.declinedAt,
      withdrawnAt: withdrawnAt ?? this.withdrawnAt,
    );
  }

  /// Check if application is pending
  bool get isPending => status == 'Pending_review';

  /// Check if application is approved
  bool get isApproved =>
      status == 'Approved_by_owner' || status == 'Approved_by_realtor';

  /// Check if application is declined
  bool get isDeclined =>
      status == 'Declined_by_owner' || status == 'Declined_by_realtor';

  /// Check if application is withdrawn
  bool get isWithdrawn => status == 'Withdrawn';

  /// Check if application is negotiation type
  bool get isNegotiation => applicationType == 'negotiation';

  /// Check if application is immediate rent type
  bool get isImmediateRent => applicationType == 'immediate_rent';

  /// Get status color
  String get statusColor {
    if (isPending) return 'orange';
    if (isApproved) return 'green';
    if (isDeclined) return 'red';
    if (isWithdrawn) return 'grey';
    return 'grey';
  }

  /// Get formatted proposed price
  String? get formattedProposedPrice =>
      proposedPrice != null ? 'NGN${proposedPrice!.toStringAsFixed(2)}' : null;
}

/// Enum for application type
enum ApplicationType {
  immediateRent,
  negotiation;

  String get value {
    switch (this) {
      case ApplicationType.immediateRent:
        return 'immediate_rent';
      case ApplicationType.negotiation:
        return 'negotiation';
    }
  }

  String get displayName {
    switch (this) {
      case ApplicationType.immediateRent:
        return 'Immediate Rent';
      case ApplicationType.negotiation:
        return 'Negotiation';
    }
  }
}

/// Enum for application status
enum ApplicationStatus {
  pendingReview,
  approvedByOwner,
  approvedByRealtor,
  declinedByOwner,
  declinedByRealtor,
  withdrawn;

  String get value {
    switch (this) {
      case ApplicationStatus.pendingReview:
        return 'Pending_review';
      case ApplicationStatus.approvedByOwner:
        return 'Approved_by_owner';
      case ApplicationStatus.approvedByRealtor:
        return 'Approved_by_realtor';
      case ApplicationStatus.declinedByOwner:
        return 'Declined_by_owner';
      case ApplicationStatus.declinedByRealtor:
        return 'Declined_by_realtor';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  String get displayName {
    switch (this) {
      case ApplicationStatus.pendingReview:
        return 'Pending Review';
      case ApplicationStatus.approvedByOwner:
        return 'Approved by Owner';
      case ApplicationStatus.approvedByRealtor:
        return 'Approved by Realtor';
      case ApplicationStatus.declinedByOwner:
        return 'Declined by Owner';
      case ApplicationStatus.declinedByRealtor:
        return 'Declined by Realtor';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}
