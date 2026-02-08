import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PropertySpecificationsRow extends StatelessWidget {
  final List<dynamic> features;

  const PropertySpecificationsRow({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < features.length; i++) ...[
            _buildSvgSpecItem(
              features[i]['icon'] ?? 'assets/icons/sqm.svg',
              features[i]['name'] ?? '',
              '',
            ),
            if (i < features.length - 1) const SizedBox(width: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildSvgSpecItem(String svgPath, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgPath,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'ProductSans Light',
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'ProductSans Light',
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
