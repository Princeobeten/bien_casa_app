import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlatmateLanguageSection extends StatelessWidget {
  final Map<String, dynamic> match;

  const FlatmateLanguageSection({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    // Get languages from match data or provide default
    final List<String> languages =
        match['languages'] != null
            ? List<String>.from(match['languages'])
            : ['English', 'Hausa', 'Yoruba'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Language',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // List all languages
        _buildInfoRow('assets/icons/language.svg', languages.join(', ')),
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
