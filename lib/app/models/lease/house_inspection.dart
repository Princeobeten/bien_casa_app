/// HouseInspection Model - Property inspection scheduling
/// Represents a scheduled inspection for a property
class HouseInspection {
  final String id;
  final String houseLeaseId;
  final String requesterId;
  final String ownerId;
  final String? campaignId; // If inspection is for a campaign
  final String? leaseApplicationId; // Link to application
  final DateTime inspectionDate;
  final String inspectionTime; // e.g., "10:00 AM"
  final String status; // 'Pending', 'Scheduled', 'Completed', 'Cancelled', 'Rescheduled'
  final bool userAgreed;
  final bool ownerAgreed;
  final String? feedback; // Feedback after inspection
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields
  final String? cancellationReason;
  final String? rescheduledReason;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final Map<String, dynamic>? inspectionNotes; // JSON: detailed notes

  HouseInspection({
    required this.id,
    required this.houseLeaseId,
    required this.requesterId,
    required this.ownerId,
    this.campaignId,
    this.leaseApplicationId,
    required this.inspectionDate,
    required this.inspectionTime,
    required this.status,
    this.userAgreed = false,
    this.ownerAgreed = false,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
    this.cancellationReason,
    this.rescheduledReason,
    this.completedAt,
    this.cancelledAt,
    this.inspectionNotes,
  });

  /// Create HouseInspection from JSON
  factory HouseInspection.fromJson(Map<String, dynamic> json) {
    return HouseInspection(
      id: json['id'] as String,
      houseLeaseId: json['houseLeaseId'] as String,
      requesterId: json['requesterId'] as String,
      ownerId: json['ownerId'] as String,
      campaignId: json['campaignId'] as String?,
      leaseApplicationId: json['leaseApplicationId'] as String?,
      inspectionDate: DateTime.parse(json['inspectionDate'] as String),
      inspectionTime: json['inspectionTime'] as String,
      status: json['status'] as String,
      userAgreed: json['userAgreed'] as bool? ?? false,
      ownerAgreed: json['ownerAgreed'] as bool? ?? false,
      feedback: json['feedback'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      cancellationReason: json['cancellationReason'] as String?,
      rescheduledReason: json['rescheduledReason'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      inspectionNotes: json['inspectionNotes'] as Map<String, dynamic>?,
    );
  }

  /// Convert HouseInspection to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'houseLeaseId': houseLeaseId,
      'requesterId': requesterId,
      'ownerId': ownerId,
      'campaignId': campaignId,
      'leaseApplicationId': leaseApplicationId,
      'inspectionDate': inspectionDate.toIso8601String(),
      'inspectionTime': inspectionTime,
      'status': status,
      'userAgreed': userAgreed,
      'ownerAgreed': ownerAgreed,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cancellationReason': cancellationReason,
      'rescheduledReason': rescheduledReason,
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'inspectionNotes': inspectionNotes,
    };
  }

  /// Create a copy with updated fields
  HouseInspection copyWith({
    String? id,
    String? houseLeaseId,
    String? requesterId,
    String? ownerId,
    String? campaignId,
    String? leaseApplicationId,
    DateTime? inspectionDate,
    String? inspectionTime,
    String? status,
    bool? userAgreed,
    bool? ownerAgreed,
    String? feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    String? rescheduledReason,
    DateTime? completedAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? inspectionNotes,
  }) {
    return HouseInspection(
      id: id ?? this.id,
      houseLeaseId: houseLeaseId ?? this.houseLeaseId,
      requesterId: requesterId ?? this.requesterId,
      ownerId: ownerId ?? this.ownerId,
      campaignId: campaignId ?? this.campaignId,
      leaseApplicationId: leaseApplicationId ?? this.leaseApplicationId,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      inspectionTime: inspectionTime ?? this.inspectionTime,
      status: status ?? this.status,
      userAgreed: userAgreed ?? this.userAgreed,
      ownerAgreed: ownerAgreed ?? this.ownerAgreed,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rescheduledReason: rescheduledReason ?? this.rescheduledReason,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      inspectionNotes: inspectionNotes ?? this.inspectionNotes,
    );
  }

  /// Check if inspection is pending
  bool get isPending => status == 'Pending';

  /// Check if inspection is scheduled
  bool get isScheduled => status == 'Scheduled';

  /// Check if inspection is completed
  bool get isCompleted => status == 'Completed';

  /// Check if inspection is cancelled
  bool get isCancelled => status == 'Cancelled';

  /// Check if inspection is rescheduled
  bool get isRescheduled => status == 'Rescheduled';

  /// Check if both parties agreed
  bool get isBothAgreed => userAgreed && ownerAgreed;

  /// Check if inspection is for a campaign
  bool get isCampaignInspection => campaignId != null;

  /// Check if inspection date is in the past
  bool get isPast => inspectionDate.isBefore(DateTime.now());

  /// Check if inspection is upcoming (within 7 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final diff = inspectionDate.difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }

  /// Get formatted inspection date
  String get formattedDate {
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
      'Dec'
    ];
    return '${inspectionDate.day} ${months[inspectionDate.month - 1]} ${inspectionDate.year}';
  }

  /// Get inspection date and time display
  String get dateTimeDisplay => '$formattedDate at $inspectionTime';
}

/// Enum for inspection status
enum InspectionStatus {
  pending,
  scheduled,
  completed,
  cancelled,
  rescheduled;

  String get value {
    switch (this) {
      case InspectionStatus.pending:
        return 'Pending';
      case InspectionStatus.scheduled:
        return 'Scheduled';
      case InspectionStatus.completed:
        return 'Completed';
      case InspectionStatus.cancelled:
        return 'Cancelled';
      case InspectionStatus.rescheduled:
        return 'Rescheduled';
    }
  }
}
