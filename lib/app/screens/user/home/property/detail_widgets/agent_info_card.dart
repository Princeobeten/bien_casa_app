import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AgentInfoCard extends StatelessWidget {
  final Map<String, dynamic>? sellerProfile;

  const AgentInfoCard({super.key, required this.sellerProfile});

  @override
  Widget build(BuildContext context) {
    final String name = sellerProfile?['name'] ?? '';
    final String level = sellerProfile?['level'] ?? '';
    final bool isVerified = sellerProfile?['isVerified'] ?? false;
    final String avatar =
        sellerProfile?['avatar'] ?? 'assets/image/agent_avatar.png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seller Information',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            avatar.startsWith('http')
                ? CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: Image.network(
                      avatar,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 30);
                      },
                    ),
                  ),
                )
                : CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(avatar),
                  backgroundColor: Colors.grey.shade300,
                ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Text(
                        level,
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),

                      if (isVerified)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
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
            SvgPicture.asset('assets/icons/message.svg', width: 20, height: 20),
          ],
        ),
      ],
    );
  }
}
