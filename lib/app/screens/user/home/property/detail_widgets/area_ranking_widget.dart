import 'package:flutter/material.dart';

class AreaRankingWidget extends StatelessWidget {
  final double rating;

  const AreaRankingWidget({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Area Ranking',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side with rating and stars
            Column(
              children: [
                Text(
                  rating.toString(),
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < 5; i++)
                      Icon(
                        i < rating.floor()
                            ? Icons.star
                            : Icons.star_border_rounded,
                        color: const Color(0xFFFBA01C),
                        size: 16,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Right side with ranking bars
            Expanded(
              child: Column(
                children: [
                  _buildRankingBar('Security', 0.9),
                  _buildRankingBar('Market', 0.7),
                  _buildRankingBar('School', 0.8),
                  _buildRankingBar('Police station', 0.6),
                  _buildRankingBar('Gas station', 0.75),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRankingBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Color(0xff6B6B6B),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBA01C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
