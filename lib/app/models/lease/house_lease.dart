/// HouseLease Model - Main property listing model
/// Represents a property available for rent/lease
class HouseLease {
  final String id;
  final String title;
  final String description;
  final String
  category; // 'Apartment', 'Room', 'Flatshare', 'Studio', 'House', 'Condo', 'Townhouse'
  final String propertyType; // 'Rent', 'Lease', 'Short Stay'
  final double price;
  final double depositAmount;
  final double holdAmount;
  final String leaseDuration; // 'Daily', 'Weekly', 'Monthly', 'Yearly'
  final Map<String, dynamic>
  location; // JSON: {address, city, state, coordinates}
  final List<String> photos;
  final String? videoUrl;
  final Map<String, dynamic>? negotiationRange; // JSON: {min, max}
  final String status; // 'Draft', 'Active', 'Closed'
  final String propertyStatus; // 'Available', 'Occupied', 'Under_maintenance'
  final String ownerId;
  final String? realtorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Additional property details
  final int? bedrooms;
  final int? bathrooms;
  final double? squareFeet;
  final List<String>? amenities;
  final Map<String, dynamic>? features; // JSON: additional features

  HouseLease({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.propertyType,
    required this.price,
    required this.depositAmount,
    required this.holdAmount,
    required this.leaseDuration,
    required this.location,
    required this.photos,
    this.videoUrl,
    this.negotiationRange,
    required this.status,
    required this.propertyStatus,
    required this.ownerId,
    this.realtorId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
    this.amenities,
    this.features,
  });

  /// Create HouseLease from JSON
  factory HouseLease.fromJson(Map<String, dynamic> json) {
    return HouseLease(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      propertyType: json['propertyType'] as String,
      price: (json['price'] as num).toDouble(),
      depositAmount: (json['depositAmount'] as num).toDouble(),
      holdAmount: (json['holdAmount'] as num).toDouble(),
      leaseDuration: json['leaseDuration'] as String,
      location: json['location'] as Map<String, dynamic>,
      photos: List<String>.from(json['photos'] as List),
      videoUrl: json['videoUrl'] as String?,
      negotiationRange: json['negotiationRange'] as Map<String, dynamic>?,
      status: json['status'] as String,
      propertyStatus: json['propertyStatus'] as String,
      ownerId: json['ownerId'] as String,
      realtorId: json['realtorId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt:
          json['deletedAt'] != null
              ? DateTime.parse(json['deletedAt'] as String)
              : null,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      squareFeet:
          json['squareFeet'] != null
              ? (json['squareFeet'] as num).toDouble()
              : null,
      amenities:
          json['amenities'] != null
              ? List<String>.from(json['amenities'] as List)
              : null,
      features: json['features'] as Map<String, dynamic>?,
    );
  }

  /// Convert HouseLease to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'propertyType': propertyType,
      'price': price,
      'depositAmount': depositAmount,
      'holdAmount': holdAmount,
      'leaseDuration': leaseDuration,
      'location': location,
      'photos': photos,
      'videoUrl': videoUrl,
      'negotiationRange': negotiationRange,
      'status': status,
      'propertyStatus': propertyStatus,
      'ownerId': ownerId,
      'realtorId': realtorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'squareFeet': squareFeet,
      'amenities': amenities,
      'features': features,
    };
  }

  /// Create a copy with updated fields
  HouseLease copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? propertyType,
    double? price,
    double? depositAmount,
    double? holdAmount,
    String? leaseDuration,
    Map<String, dynamic>? location,
    List<String>? photos,
    String? videoUrl,
    Map<String, dynamic>? negotiationRange,
    String? status,
    String? propertyStatus,
    String? ownerId,
    String? realtorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? bedrooms,
    int? bathrooms,
    double? squareFeet,
    List<String>? amenities,
    Map<String, dynamic>? features,
  }) {
    return HouseLease(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      propertyType: propertyType ?? this.propertyType,
      price: price ?? this.price,
      depositAmount: depositAmount ?? this.depositAmount,
      holdAmount: holdAmount ?? this.holdAmount,
      leaseDuration: leaseDuration ?? this.leaseDuration,
      location: location ?? this.location,
      photos: photos ?? this.photos,
      videoUrl: videoUrl ?? this.videoUrl,
      negotiationRange: negotiationRange ?? this.negotiationRange,
      status: status ?? this.status,
      propertyStatus: propertyStatus ?? this.propertyStatus,
      ownerId: ownerId ?? this.ownerId,
      realtorId: realtorId ?? this.realtorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      squareFeet: squareFeet ?? this.squareFeet,
      amenities: amenities ?? this.amenities,
      features: features ?? this.features,
    );
  }

  /// Check if lease is available
  bool get isAvailable => status == 'Active' && propertyStatus == 'Available';

  /// Check if lease is occupied
  bool get isOccupied => propertyStatus == 'Occupied';

  /// Check if lease is draft
  bool get isDraft => status == 'Draft';

  /// Check if negotiation is allowed
  bool get isNegotiable => negotiationRange != null;

  /// Get formatted price
  String get formattedPrice => 'NGN${price.toStringAsFixed(2)}';

  /// Get formatted deposit
  String get formattedDeposit => 'NGN${depositAmount.toStringAsFixed(2)}';

  /// Get formatted hold amount
  String get formattedHoldAmount => 'NGN${holdAmount.toStringAsFixed(2)}';
}

/// Enum for lease status
enum LeaseStatus {
  draft,
  active,
  closed;

  String get value {
    switch (this) {
      case LeaseStatus.draft:
        return 'Draft';
      case LeaseStatus.active:
        return 'Active';
      case LeaseStatus.closed:
        return 'Closed';
    }
  }
}

/// Enum for property status
enum PropertyStatus {
  available,
  occupied,
  underMaintenance;

  String get value {
    switch (this) {
      case PropertyStatus.available:
        return 'Available';
      case PropertyStatus.occupied:
        return 'Occupied';
      case PropertyStatus.underMaintenance:
        return 'Under_maintenance';
    }
  }
}

/// Enum for property category
enum PropertyCategory {
  apartment,
  room,
  flatshare,
  studio,
  house,
  condo,
  townhouse;

  String get value {
    switch (this) {
      case PropertyCategory.apartment:
        return 'Apartment';
      case PropertyCategory.room:
        return 'Room';
      case PropertyCategory.flatshare:
        return 'Flatshare';
      case PropertyCategory.studio:
        return 'Studio';
      case PropertyCategory.house:
        return 'House';
      case PropertyCategory.condo:
        return 'Condo';
      case PropertyCategory.townhouse:
        return 'Townhouse';
    }
  }
}

/// Enum for property type
enum PropertyType {
  rent,
  lease,
  shortStay;

  String get value {
    switch (this) {
      case PropertyType.rent:
        return 'Rent';
      case PropertyType.lease:
        return 'Lease';
      case PropertyType.shortStay:
        return 'Short Stay';
    }
  }
}

/// Enum for lease duration
enum LeaseDuration {
  daily,
  weekly,
  monthly,
  yearly;

  String get value {
    switch (this) {
      case LeaseDuration.daily:
        return 'Daily';
      case LeaseDuration.weekly:
        return 'Weekly';
      case LeaseDuration.monthly:
        return 'Monthly';
      case LeaseDuration.yearly:
        return 'Yearly';
    }
  }
}
