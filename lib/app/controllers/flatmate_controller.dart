import 'package:get/get.dart';
import '../models/campaign/campaign.dart';
import 'campaign/campaign_enhanced_controller.dart';

class FlatmateController extends GetxController {
  // Use CampaignEnhancedController for campaign management
  CampaignEnhancedController get _campaignController => Get.find<CampaignEnhancedController>();

  // Current index of the top card
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch campaigns on init
    fetchCampaigns();
  }

  // Fetch campaigns from API using CampaignEnhancedController
  Future<void> fetchCampaigns({String? goal}) async {
    await _campaignController.fetchCampaigns(goal: goal);
  }
  
  // Get campaigns from CampaignEnhancedController
  List<Campaign> get campaigns => _campaignController.campaigns;
  bool get isLoading => _campaignController.isLoading;
  String get errorMessage => _campaignController.errorMessage;

  // Get the current card data
  Campaign? get currentCard =>
      campaigns.isNotEmpty && currentIndex.value < campaigns.length
          ? campaigns[currentIndex.value]
          : null;

  // Check if there are more cards
  bool get hasMoreCards => currentIndex.value < campaigns.length - 1;

  // Get the tilt angle based on card position
  double getCardTilt(int index) {
    // Convert degrees to radians for Flutter's rotation
    return index % 2 == 0 ? 0.1316 : -0.105; // -6.02° and 7.54° in radians
  }

  // Navigate to next card
  void nextCard() {
    if (hasMoreCards) {
      currentIndex.value++;
    }
  }

  // Navigate to previous card
  void previousCard() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  // Apply to campaign using CampaignEnhancedController
  Future<bool> applyToCampaign(int campaignId) async {
    return await _campaignController.applyToCampaign(campaignId);
  }
}
