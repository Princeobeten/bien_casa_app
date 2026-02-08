/// TransferRequest Model - Multi-sig withdrawal requests
class TransferRequest {
  final String id;
  final String campaignId;
  final String requesterId;
  final double amount;
  final String purpose;
  final int requiredApprovals;
  final Map<String, dynamic> approvals; // JSON: {userId: approved}
  final String status; // 'Pending', 'Approved', 'Rejected', 'Executed'
  final DateTime? executedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransferRequest({
    required this.id,
    required this.campaignId,
    required this.requesterId,
    required this.amount,
    required this.purpose,
    required this.requiredApprovals,
    required this.approvals,
    required this.status,
    this.executedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransferRequest.fromJson(Map<String, dynamic> json) {
    return TransferRequest(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String,
      requesterId: json['requesterId'] as String,
      amount: (json['amount'] as num).toDouble(),
      purpose: json['purpose'] as String,
      requiredApprovals: json['requiredApprovals'] as int,
      approvals: json['approvals'] as Map<String, dynamic>,
      status: json['status'] as String,
      executedAt:
          json['executedAt'] != null
              ? DateTime.parse(json['executedAt'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignId': campaignId,
      'requesterId': requesterId,
      'amount': amount,
      'purpose': purpose,
      'requiredApprovals': requiredApprovals,
      'approvals': approvals,
      'status': status,
      'executedAt': executedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';
  bool get isExecuted => status == 'Executed';

  int get approvalCount => approvals.values.where((v) => v == true).length;
  double get approvalProgress => (approvalCount / requiredApprovals) * 100;
  bool get hasEnoughApprovals => approvalCount >= requiredApprovals;
  String get formattedAmount => 'NGN${amount.toStringAsFixed(2)}';
}
