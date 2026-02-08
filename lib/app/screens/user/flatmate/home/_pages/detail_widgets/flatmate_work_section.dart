import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlatmateWorkSection extends StatelessWidget {
  final Map<String, dynamic> match;

  const FlatmateWorkSection({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Occupation
        _buildInfoRow(
          'assets/icons/briefcase.svg',
          match['occupation'] ?? 'Not specified',
        ),

        const SizedBox(height: 12),

        // Workplace/Company if available
        if (match['company'] != null)
          _buildInfoRow(
            'assets/icons/home_owner.svg', // Using home_owner icon as a company/business representation
            match['company'],
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
              color: Color(0xff6B6B6B),
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}
