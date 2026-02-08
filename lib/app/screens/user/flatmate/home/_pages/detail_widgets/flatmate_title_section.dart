import 'package:flutter/material.dart';

class FlatmateTitleSection extends StatelessWidget {
  final Map<String, dynamic> match;

  const FlatmateTitleSection({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${match['name']}, ${match['age']}',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 24.0,
                  height: 1.0,
                  leadingDistribution: TextLeadingDistribution.even,
                  letterSpacing: -0.32,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xff6B6B6B),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match['location'] ?? 'Abuja, Nigeria',
                      style: const TextStyle(
                        fontFamily: 'ProductSans Light',
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        fontSize: 13,
                        leadingDistribution:
                            TextLeadingDistribution.proportional,
                        letterSpacing: 0,
                        color: Color(0xff6B6B6B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    match['isVerified'] == true
                        ? Icons.verified
                        : Icons.verified_outlined,
                    color:
                        match['isVerified'] == true
                            ? const Color(0xFF29BCA2)
                            : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    match['isVerified'] == true ? 'Verified' : 'Not Verified',
                    style: const TextStyle(
                      fontFamily: 'ProductSans Light',
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0,
                      color: Color(0xff6B6B6B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
