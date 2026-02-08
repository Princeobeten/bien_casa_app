import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FlatOwnerSection extends StatelessWidget {
  final Map<String, dynamic> flat;

  const FlatOwnerSection({super.key, required this.flat});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Image
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            width: 55,
            height: 55,
            child:
                flat['ownerImage'] != null && flat['ownerImage'].toString().isNotEmpty
                    ? Image.network(
                      flat['ownerImage'],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              color: Color(0xff6B6B6B),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                    )
                    : const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
        ),

        const SizedBox(width: 16),

        // Name and Verification
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                flat['ownerName'] ?? 'Property Owner',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 3),

              // Verification text
              Row(
                children: [
                  Text(
                    flat['ownerVerified'] == true ? 'Verified' : 'Not Verified',
                    style: TextStyle(
                      fontFamily: 'ProductSansLight',
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(width: 6),
                  if (flat['ownerVerified'] == true)
                    Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: SvgPicture.asset(
                        'assets/icons/verified.svg',
                        width: 16,
                        height: 16,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        SvgPicture.asset('assets/icons/phone.svg', width: 24, height: 24),

        const SizedBox(width: 20),

        // Message Button
        SvgPicture.asset('assets/icons/message.svg', width: 24, height: 24),
      ],
    );
  }
}
