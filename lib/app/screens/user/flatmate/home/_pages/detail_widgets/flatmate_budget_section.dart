import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlatmateBudgetSection extends StatelessWidget {
  final Map<String, dynamic> match;

  const FlatmateBudgetSection({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SvgPicture.asset('assets/icons/naira.svg', width: 16, height: 16),
            const SizedBox(width: 8),
            Text(
              match['budget'] ?? match['income'] ?? '400,000 - 600,000/year',
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
