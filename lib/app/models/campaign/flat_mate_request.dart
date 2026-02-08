/// FlatMateRequest Model - Flatmate join requests
/// Represents a request to join a campaign
class FlatMateRequest {
  final String id;
  final String campaignId;
  final String requesterId;
  final String status; // 'Pending', 'Matched', 'Declined'
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;

  FlatMateRequest({
    required this.id,
    required this.campaignId,
    required this.requesterId,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlatMateRequest.fromJson(Map<String, dynamic> json) {
    return FlatMateRequest(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String,
      requesterId: json['requesterId'] as String,
      status: json['status'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignId': campaignId,
      'requesterId': requesterId,
      'status': status,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  FlatMateRequest copyWith({
    String? id,
    String? campaignId,
    String? requesterId,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FlatMateRequest(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      requesterId: requesterId ?? this.requesterId,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isMatched => status == 'Matched';
  bool get isDeclined => status == 'Declined';
}

enum FlatMateRequestStatus {
  pending,
  matched,
  declined;

  String get value {
    switch (this) {
      case FlatMateRequestStatus.pending:
        return 'Pending';
      case FlatMateRequestStatus.matched:
        return 'Matched';
      case FlatMateRequestStatus.declined:
        return 'Declined';
    }
  }
}
