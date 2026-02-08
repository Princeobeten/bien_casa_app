import 'package:flutter/material.dart';

class FlatmateSpecificationsRow extends StatelessWidget {
  final Map<String, dynamic> match;

  const FlatmateSpecificationsRow({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Gender
          _buildSpecItem(Icons.person, match['gender'] ?? 'Male'),
          const SizedBox(width: 20),

          // Religion
          _buildSpecItem(Icons.mosque, match['religion'] ?? 'Not specified'),
          const SizedBox(width: 20),

          // Occupation
          _buildSpecItem(Icons.work, match['occupation'] ?? 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'ProductSans Light',
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
