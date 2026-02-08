import 'package:flutter/material.dart';
import 'section_header.dart';
import 'location_property_card.dart';

String formatPrice(String price) {
  // Remove non-digit characters
  final cleaned = price.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) return price;
  final value = int.tryParse(cleaned);
  if (value == null) return price;
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(value % 1000000000 == 0 ? 0 : 1)}b';
  } else if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}m';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
  } else {
    return '$value';
  }
}

class LocationPropertyList extends StatelessWidget {
  final String locationName;
  final List<Map<String, dynamic>> properties;
  final Function(int) onItemTap;
  final VoidCallback? onViewAllTap;

  const LocationPropertyList({
    super.key,
    required this.locationName,
    required this.properties,
    required this.onItemTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        SectionHeader(
          title: 'Most searched houses by location',
          viewAllText: 'View all',
          onViewAllTap: onViewAllTap ?? () {},
        ),

        // Location indicator
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: Color(0xff6B6B6B)),
            const SizedBox(width: 6),
            Text(
              locationName,
              style: const TextStyle(
                fontFamily: 'ProductSans Light',
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                fontSize: 15,
                height: 1.5,
                color: Color(0xff6B6B6B),
              ),
            ),
            const Spacer(),
          ],
        ),

        const SizedBox(height: 16),

        // Property list for this location with vertical cards
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return LocationPropertyCard(
                imageUrl:
                    property['images'] != null &&
                            (property['images'] as List).isNotEmpty
                        ? property['images'][0]
                        : 'assets/image/placeholder.png',
                name: property['name'] ?? '',
                address: property['address'] ?? '',
                price: property['price'] ?? '',
                size: property['size'] ?? '',
                type: property['type'] ?? '',
                onTap: () => onItemTap(index),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
