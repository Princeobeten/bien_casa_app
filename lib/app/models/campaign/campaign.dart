/// Campaign Model - Matches API spec
/// Represents a flatmate/flat/short-stay campaign
class Campaign {
  final int? id;
  final String title;
  final String goal; // 'Flatmate', 'Flat', 'Short-stay'
  final double budget;
  final String duration; // '1 Month', '3 Months', '6 Months', '1 Year'
  final DateTime moveDate;
  final String country;
  final String city;
  final String? gender;
  final String? religion;
  final String? maritalStatus;
  final String? personality;
  final String? habit;
  final int? noOfFlatmates;
  final String? type;
  final int? noOfRooms;
  final String? aesthetic;
  final String location;
  final String? status;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Campaign({
    this.id,
    required this.title,
    required this.goal,
    required this.budget,
    required this.duration,
    required this.moveDate,
    required this.country,
    required this.city,
    this.gender,
    this.religion,
    this.maritalStatus,
    this.personality,
    this.habit,
    this.noOfFlatmates,
    this.type,
    this.noOfRooms,
    this.aesthetic,
    required this.location,
    this.status,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Campaign from JSON
  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as int?,
      title: json['title'] as String,
      goal: json['goal'] as String,
      budget: (json['budget'] as num).toDouble(),
      duration: json['duration'] as String,
      moveDate: DateTime.parse(json['move_date'] as String),
      country: json['country'] as String,
      city: json['city'] as String,
      gender: json['gender'] as String?,
      religion: json['religion'] as String?,
      maritalStatus: json['marital_status'] as String?,
      personality: json['personality'] as String?,
      habit: json['habit'] as String?,
      noOfFlatmates: json['no_of_flatmates'] as int?,
      type: json['type'] as String?,
      noOfRooms: json['no_of_rooms'] as int?,
      aesthetic: json['aesthetic'] as String?,
      location: json['location'] as String,
      status: json['status'] as String?,
      userId: json['user_id'] as int?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Campaign to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'goal': goal,
      'budget': budget,
      'duration': duration,
      'move_date': moveDate.toIso8601String(),
      'country': country,
      'city': city,
      if (gender != null) 'gender': gender,
      if (religion != null) 'religion': religion,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (personality != null) 'personality': personality,
      if (habit != null) 'habit': habit,
      if (noOfFlatmates != null) 'no_of_flatmates': noOfFlatmates,
      if (type != null) 'type': type,
      if (noOfRooms != null) 'no_of_rooms': noOfRooms,
      if (aesthetic != null) 'aesthetic': aesthetic,
      'location': location,
    };
  }

  /// Create a copy with updated fields
  Campaign copyWith({
    int? id,
    String? title,
    String? goal,
    double? budget,
    String? duration,
    DateTime? moveDate,
    String? country,
    String? city,
    String? gender,
    String? religion,
    String? maritalStatus,
    String? personality,
    String? habit,
    int? noOfFlatmates,
    String? type,
    int? noOfRooms,
    String? aesthetic,
    String? location,
    String? status,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      budget: budget ?? this.budget,
      duration: duration ?? this.duration,
      moveDate: moveDate ?? this.moveDate,
      country: country ?? this.country,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      personality: personality ?? this.personality,
      habit: habit ?? this.habit,
      noOfFlatmates: noOfFlatmates ?? this.noOfFlatmates,
      type: type ?? this.type,
      noOfRooms: noOfRooms ?? this.noOfRooms,
      aesthetic: aesthetic ?? this.aesthetic,
      location: location ?? this.location,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted budget
  String get formattedBudget => 'NGN ${budget.toStringAsFixed(0)}';

  /// Check if this is a flatmate campaign
  bool get isFlatmateCampaign => goal == 'Flatmate';

  /// Check if this is a flat campaign
  bool get isFlatCampaign => goal == 'Flat';

  /// Check if this is a short-stay campaign
  bool get isShortStayCampaign => goal == 'Short-stay';
}

/// Campaign Application Model
class CampaignApplication {
  final int? id;
  final int campaignId;
  final int userId;
  final String status; // 'PENDING', 'ACCEPTED', 'REJECTED'
  final DateTime? createdAt;
  final Map<String, dynamic>? userDetails;

  CampaignApplication({
    this.id,
    required this.campaignId,
    required this.userId,
    required this.status,
    this.createdAt,
    this.userDetails,
  });

  factory CampaignApplication.fromJson(Map<String, dynamic> json) {
    return CampaignApplication(
      id: json['id'] as int?,
      campaignId: json['campaign_id'] as int,
      userId: json['user_id'] as int,
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      userDetails: json['user_details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'user_id': userId,
      'status': status,
    };
  }
}
