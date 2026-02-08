import 'package:get/get.dart';
import '../controllers/flatmate_controller.dart';
import '../controllers/campaign/campaign_enhanced_controller.dart';

class FlatmateBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FlatmateController());
    Get.put(CampaignEnhancedController());
  }
}
