/// CampaignContribution Model - Financial contributions
class CampaignContribution {
  final String id;
  final String campaignId;
  final String contributorId;
  final double amount;
  final String paymentStatus; // 'Pending', 'Completed', 'Failed'
  final String? paymentReference;
  final DateTime createdAt;
  final DateTime updatedAt;

  CampaignContribution({
    required this.id,
    required this.campaignId,
    required this.contributorId,
    required this.amount,
    required this.paymentStatus,
    this.paymentReference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampaignContribution.fromJson(Map<String, dynamic> json) {
    return CampaignContribution(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String,
      contributorId: json['contributorId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      paymentReference: json['paymentReference'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignId': campaignId,
      'contributorId': contributorId,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'paymentReference': paymentReference,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => paymentStatus == 'Pending';
  bool get isCompleted => paymentStatus == 'Completed';
  bool get isFailed => paymentStatus == 'Failed';
  String get formattedAmount => 'NGN${amount.toStringAsFixed(2)}';
}
