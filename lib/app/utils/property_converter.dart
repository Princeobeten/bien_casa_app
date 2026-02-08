import '../models/lease/house_lease.dart';

/// Utility class to convert old property format to HouseLease format
class PropertyConverter {
  /// Convert old property map format to HouseLease compatible format
  static Map<String, dynamic> convertToHouseLeaseFormat(
    Map<String, dynamic> oldProperty,
  ) {
    // If already in new format with all required fields, return as is
    if (oldProperty.containsKey('id') &&
        oldProperty.containsKey('title') &&
        oldProperty.containsKey('photos') &&
        oldProperty.containsKey('location') is Map) {
      return oldProperty;
    }

    // Convert old format to new format
    return {
      'id':
          oldProperty['id'] ??
          'lease_temp_${DateTime.now().millisecondsSinceEpoch}',
      'title': oldProperty['name'] ?? oldProperty['title'] ?? 'Property',
      'description': oldProperty['description'] ?? 'No description available',
      'category': oldProperty['type'] ?? 'House',
      'propertyType': 'Rent',
      'price': _parsePrice(oldProperty['price']),
      'depositAmount': _parsePrice(oldProperty['price']) * 0.2, // 20% of price
      'holdAmount': _parsePrice(oldProperty['price']) * 0.05, // 5% of price
      'leaseDuration': 'Yearly',
      'location': {
        'address': oldProperty['address'] ?? 'Address not available',
        'city': _extractCity(oldProperty['address']),
        'state': _extractState(oldProperty['address']),
        'district': 'District',
        'coordinates':
            oldProperty['mapCoordinates'] ??
            {'latitude': 0.0, 'longitude': 0.0},
      },
      'photos': oldProperty['images'] ?? oldProperty['photos'] ?? [],
      'videoUrl': null,
      'negotiationRange': null,
      'status': 'Active',
      'propertyStatus': 'Available',
      'ownerId': oldProperty['sellerProfile']?['name'] ?? 'owner_001',
      'realtorId': 'realtor_001',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'deletedAt': null,
      'bedrooms': _extractBedrooms(oldProperty),
      'bathrooms': _extractBathrooms(oldProperty),
      'squareFeet': _parseSquareFeet(oldProperty['size']),
      'amenities': _extractAmenities(oldProperty['features']),
      'features': {
        'size': oldProperty['size'] ?? '0 sqm',
        'type': oldProperty['type'] ?? 'Residential',
        'landmarks': oldProperty['landmarks'] ?? [],
      },

      // Keep UI fields
      'sellerProfile': oldProperty['sellerProfile'],
      'rating': oldProperty['rating'],
      'reviews': oldProperty['reviews'],
      'discount': oldProperty['discount'],
    };
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) {
      // Remove commas and convert
      final cleanPrice = price.replaceAll(',', '').replaceAll('NGN', '').trim();
      return double.tryParse(cleanPrice) ?? 0.0;
    }
    return 0.0;
  }

  static String _extractCity(String? address) {
    if (address == null) return 'City';
    // Try to extract city from address (usually after comma)
    final parts = address.split(',');
    if (parts.length >= 2) {
      return parts[parts.length - 2].trim();
    }
    return 'City';
  }

  static String _extractState(String? address) {
    if (address == null) return 'State';
    // Try to extract state from address (usually last part)
    final parts = address.split(',');
    if (parts.isNotEmpty) {
      final lastPart = parts.last.trim();
      // Extract state code or name
      final stateMatch = RegExp(
        r'[A-Z]{2,}|\b[A-Z][a-z]+\b',
      ).firstMatch(lastPart);
      if (stateMatch != null) {
        return stateMatch.group(0) ?? 'State';
      }
    }
    return 'State';
  }

  static int? _extractBedrooms(Map<String, dynamic> property) {
    // Try to find bedroom count in features
    final features = property['features'];
    if (features is List) {
      for (var feature in features) {
        if (feature is Map && feature['name'] != null) {
          final name = feature['name'].toString().toLowerCase();
          if (name.contains('bedroom')) {
            final match = RegExp(r'\d+').firstMatch(name);
            if (match != null) {
              return int.tryParse(match.group(0)!);
            }
          }
        }
      }
    }
    return null;
  }

  static int? _extractBathrooms(Map<String, dynamic> property) {
    // Try to find bathroom count in features
    final features = property['features'];
    if (features is List) {
      for (var feature in features) {
        if (feature is Map && feature['name'] != null) {
          final name = feature['name'].toString().toLowerCase();
          if (name.contains('bathroom')) {
            final match = RegExp(r'\d+').firstMatch(name);
            if (match != null) {
              return int.tryParse(match.group(0)!);
            }
          }
        }
      }
    }
    return null;
  }

  static double? _parseSquareFeet(dynamic size) {
    if (size == null) return null;
    if (size is num) return size.toDouble();
    if (size is String) {
      // Extract number from string like "500 sqm"
      final match = RegExp(r'\d+').firstMatch(size);
      if (match != null) {
        final sqm = double.tryParse(match.group(0)!);
        if (sqm != null) {
          // Convert sqm to sqft (1 sqm = 10.764 sqft)
          return sqm * 10.764;
        }
      }
    }
    return null;
  }

  static List<String> _extractAmenities(dynamic features) {
    if (features == null) return [];
    if (features is List) {
      return features
          .where((f) => f is Map && f['name'] != null)
          .map((f) => f['name'].toString())
          .toList();
    }
    return [];
  }

  /// Convert and create HouseLease from old format
  static HouseLease convertToHouseLease(Map<String, dynamic> oldProperty) {
    final converted = convertToHouseLeaseFormat(oldProperty);
    return HouseLease.fromJson(converted);
  }
}
