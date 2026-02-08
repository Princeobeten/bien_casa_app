/// CampaignHouse Model - Houses linked to campaign
class CampaignHouse {
  final String id;
  final String campaignId;
  final String houseLeaseId;
  final String addedBy;
  final Map<String, dynamic>? votes; // JSON: {userId: vote}
  final DateTime createdAt;
  final DateTime updatedAt;

  CampaignHouse({
    required this.id,
    required this.campaignId,
    required this.houseLeaseId,
    required this.addedBy,
    this.votes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampaignHouse.fromJson(Map<String, dynamic> json) {
    return CampaignHouse(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String,
      houseLeaseId: json['houseLeaseId'] as String,
      addedBy: json['addedBy'] as String,
      votes: json['votes'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignId': campaignId,
      'houseLeaseId': houseLeaseId,
      'addedBy': addedBy,
      'votes': votes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get voteCount => votes?.length ?? 0;
}
