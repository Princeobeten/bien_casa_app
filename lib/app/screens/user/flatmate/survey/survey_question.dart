import 'package:flutter/material.dart';

class SurveyQuestion extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(String) onOptionSelected;
  final String? selectedOption;

  const SurveyQuestion({
    super.key,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    this.selectedOption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w400,
              fontFamily: 'ProductSans',
            ),
          ),
        ),
        const SizedBox(height: 71),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children:
                [
                  // Options
                  ...options.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => onOptionSelected(option),
                        child: Container(
                          height: 70,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedOption == option
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color:
                                  selectedOption == option
                                      ? Colors.black
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight:
                                  selectedOption == option
                                      ? FontWeight.w500
                                      : FontWeight.w300,
                              fontFamily: 'ProductSans',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ].toList(),
          ),
        ),
      ],
    );
  }
}
