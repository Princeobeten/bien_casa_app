import 'package:bien_casa/app/controllers/flatmate_survey_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'survey_question.dart';

class FlatmateSurvey extends StatefulWidget {
  final VoidCallback onSurveyComplete;

  const FlatmateSurvey({super.key, required this.onSurveyComplete});

  @override
  State<FlatmateSurvey> createState() => _FlatmateSurveyState();
}

class _FlatmateSurveyState extends State<FlatmateSurvey> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Get the controller
  final FlatmateSurveyController _controller = Get.put(
    FlatmateSurveyController(),
  );

  // Store survey responses locally for UI updates
  final Map<int, String> _responses = {};

  // Survey questions and options
  final List<Map<String, dynamic>> _surveyQuestions = [
    {
      'question': 'What do you value most in a living environment?',
      'options': [
        'My privacy',
        'Spending time together',
        'Chill Vibes',
        'Never getting bored',
      ],
    },
    {
      'question': 'How would you describe your personality?',
      'options': ['Introvert', 'Extrovert', 'Ambivert', 'Not sure'],
    },
    {
      'question': 'How would you describe your religion?',
      'options': ['Christianity', 'Islam', 'Irreligion', 'Others'],
    },
    {
      'question': 'Do you drink or smoke?',
      'options': [
        'Yes, I smoke',
        'Yes, I drink',
        'I drink and smoke occasionally',
        'I don\'t drink, I don\'t smoke',
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectOption(int questionIndex, String option) {
    // Update both local state and controller
    setState(() {
      _responses[questionIndex] = option;
    });
    _controller.addResponse(questionIndex, option);

    // Auto-advance to next question after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (questionIndex < _surveyQuestions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Survey completed - last question
        _controller.printResponses(); // Print responses to console
        widget.onSurveyComplete();
      }
    });
  }

  // Auto-advance is now handled in _selectOption

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            SizedBox(height: 40),

            // Progress steps - one for each question
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _surveyQuestions.length,
                (index) => Container(
                  width: 76.57142639160156,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color:
                        index <= _currentPage
                            ? Colors.white
                            : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 72),

            // Survey questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _surveyQuestions.length,
                itemBuilder: (context, index) {
                  final question =
                      _surveyQuestions[index]['question'] as String;
                  final options =
                      _surveyQuestions[index]['options'] as List<String>;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SurveyQuestion(
                      question: question,
                      options: options,
                      selectedOption: _responses[index],
                      onOptionSelected:
                          (option) => _selectOption(index, option),
                    ),
                  );
                },
              ),
            ),

            // Skip button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: widget.onSurveyComplete,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 89),
          ],
        ),
      ),
    );
  }
}
