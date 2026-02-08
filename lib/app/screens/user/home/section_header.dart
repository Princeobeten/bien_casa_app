import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? viewAllText;
  final Function()? onViewAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.viewAllText,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              color: Color(0xff1e1e1e),
              leadingDistribution: TextLeadingDistribution.even,
              letterSpacing: 0,
            ),
          ),
          if (viewAllText != null)
            GestureDetector(
              onTap: onViewAllTap,
              child: Text(
                viewAllText!,
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 15,
                  leadingDistribution: TextLeadingDistribution.even,
                  color: Color(0xff020202),
                  letterSpacing: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
