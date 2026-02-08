import 'package:get/get.dart';

class FlatmateSurveyController extends GetxController {
  // Store survey responses
  final responses = <int, String>{}.obs;

  // Add response
  void addResponse(int questionIndex, String response) {
    responses[questionIndex] = response;
    update();
  }

  // Get all responses
  Map<String, String> getAllResponses() {
    final Map<String, String> formattedResponses = {};

    // Map of question texts
    final questionTexts = {
      0: 'What do you value most in a living environment?',
      1: 'How would you describe your personality?',
      2: 'How would you describe your religion?',
      3: 'Do you drink or smoke?',
    };

    // Format responses with question text as key
    responses.forEach((index, answer) {
      formattedResponses[questionTexts[index] ?? 'Question $index'] = answer;
    });

    return formattedResponses;
  }

  // Print all responses
  void printResponses() {
    final allResponses = getAllResponses();
    print('===== FLATMATE SURVEY RESPONSES =====');
    allResponses.forEach((question, answer) {
      print('$question: $answer');
    });
    print('====================================');
  }

  // Clear all responses
  void clearResponses() {
    responses.clear();
    update();
  }
}