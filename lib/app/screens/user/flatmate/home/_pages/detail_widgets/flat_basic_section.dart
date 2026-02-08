import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlatBasicSection extends StatelessWidget {
  final Map<String, dynamic> flat;

  const FlatBasicSection({super.key, required this.flat});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Bedrooms
        _buildInfoRow('assets/icons/home.svg', '${flat['bedrooms']} bedrooms'),

        const SizedBox(height: 12),

        // Bathrooms
        _buildInfoRow('assets/icons/home.svg', '${flat['bathrooms'] ?? 2} bathrooms'),

        const SizedBox(height: 12),

        // Size
        _buildInfoRow(
          'assets/icons/map pin.svg',
          '${flat['size'] ?? 120} sqm',
        ),

        const SizedBox(height: 12),

        // Location
        _buildInfoRow(
          'assets/icons/map pin.svg',
          flat['location'] ?? 'Not specified',
        ),
      ],
    );
  }

  Widget _buildInfoRow(String iconPath, String text) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'ProductSansLight',
              color: Color.fromARGB(255, 107, 107, 107),
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}
