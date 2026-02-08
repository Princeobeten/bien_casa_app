/// Favourite Model - User favorites
/// Represents a user's favorited property
class Favourite {
  final String id;
  final String userId;
  final String houseLeaseId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Favourite({
    required this.id,
    required this.userId,
    required this.houseLeaseId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Favourite from JSON
  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      id: json['id'] as String,
      userId: json['userId'] as String,
      houseLeaseId: json['houseLeaseId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert Favourite to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'houseLeaseId': houseLeaseId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Favourite copyWith({
    String? id,
    String? userId,
    String? houseLeaseId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Favourite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      houseLeaseId: houseLeaseId ?? this.houseLeaseId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
