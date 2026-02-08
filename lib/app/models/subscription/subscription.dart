/// Subscription model for property owners
class Subscription {
  final String id;
  final String userId;
  final String planType; // 'basic', 'premium'
  final int propertyLimit; // Number of properties allowed
  final double monthlyFee;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'expired', 'cancelled'
  final String? paymentReference;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.planType,
    required this.propertyLimit,
    required this.monthlyFee,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.paymentReference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      planType: json['planType'] ?? json['plan_type'] ?? 'basic',
      propertyLimit: json['propertyLimit'] ?? json['property_limit'] ?? 10,
      monthlyFee: (json['monthlyFee'] ?? json['monthly_fee'] ?? 0).toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : (json['start_date'] != null
              ? DateTime.parse(json['start_date'])
              : DateTime.now()),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : (json['end_date'] != null
              ? DateTime.parse(json['end_date'])
              : DateTime.now().add(const Duration(days: 30))),
      status: json['status'] ?? 'active',
      paymentReference: json['paymentReference'] ?? json['payment_reference'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planType': planType,
      'propertyLimit': propertyLimit,
      'monthlyFee': monthlyFee,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'paymentReference': paymentReference,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());
  bool get isExpired => endDate.isBefore(DateTime.now());
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}

/// Campaign fee payment model
class CampaignFee {
  final String id;
  final String userId;
  final String campaignId;
  final String feeType; // 'hosting', 'participation'
  final double amount;
  final String status; // 'pending', 'paid', 'failed'
  final String? paymentReference;
  final DateTime? paidAt;
  final DateTime createdAt;

  CampaignFee({
    required this.id,
    required this.userId,
    required this.campaignId,
    required this.feeType,
    required this.amount,
    required this.status,
    this.paymentReference,
    this.paidAt,
    required this.createdAt,
  });

  factory CampaignFee.fromJson(Map<String, dynamic> json) {
    return CampaignFee(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      campaignId: json['campaignId'] ?? json['campaign_id'] ?? '',
      feeType: json['feeType'] ?? json['fee_type'] ?? 'hosting',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentReference: json['paymentReference'] ?? json['payment_reference'],
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'])
          : (json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'campaignId': campaignId,
      'feeType': feeType,
      'amount': amount,
      'status': status,
      'paymentReference': paymentReference,
      'paidAt': paidAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isPaid => status == 'paid';
}
