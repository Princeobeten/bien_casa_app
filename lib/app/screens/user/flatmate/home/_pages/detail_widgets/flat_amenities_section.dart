import 'package:flutter/material.dart';

class FlatAmenitiesSection extends StatelessWidget {
  final Map<String, dynamic> flat;

  const FlatAmenitiesSection({super.key, required this.flat});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features & Amenities',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (flat['amenities'] as List).map((amenity) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                amenity,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontFamily: 'ProductSans',
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
