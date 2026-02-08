import 'package:get/get.dart';
import '../controllers/flatmate_survey_controller.dart';

class FlatmateSurveyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlatmateSurveyController>(
      () => FlatmateSurveyController(),
    );
  }
}
