import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlatmateBasicSection extends StatelessWidget {
  final Map<String, dynamic> match;

  const FlatmateBasicSection({super.key, required this.match});

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

        // Gender
        _buildInfoRow('assets/icons/gender.svg', match['gender'] ?? 'Male'),

        const SizedBox(height: 12),

        // Age/Birthday
        _buildInfoRow('assets/icons/birthday.svg', '${match['age']} years old'),

        const SizedBox(height: 12),

        // Religion
        _buildInfoRow(
          'assets/icons/faith.svg',
          match['religion'] ?? 'Not specified',
        ),

        const SizedBox(height: 12),

        // Location
        _buildInfoRow(
          'assets/icons/map pin.svg',
          match['location'] ?? 'Not specified',
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
