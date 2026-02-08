import 'package:get/get.dart';
import '../../models/campaign/campaign.dart';
import '../../services/api/campaign_service.dart';
import '../../services/api/api_exception.dart';

/// CampaignEnhancedController - Campaign management matching new API
class CampaignEnhancedController extends GetxController {
  final CampaignService _campaignService = CampaignService();

  // Campaigns
  final RxList<Campaign> _campaigns = <Campaign>[].obs;
  final RxList<Campaign> _myCampaigns = <Campaign>[].obs;
  final Rx<Campaign?> _selectedCampaign = Rx<Campaign?>(null);

  // Campaign applications
  final RxList<CampaignApplication> _applications = <CampaignApplication>[].obs;

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<Campaign> get campaigns => _campaigns;
  List<Campaign> get myCampaigns => _myCampaigns;
  Campaign? get selectedCampaign => _selectedCampaign.value;
  List<CampaignApplication> get applications => _applications;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  // ========== Campaign Operations ==========

  /// Fetch all campaigns (with optional goal filter)
  Future<void> fetchCampaigns({String? goal}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final campaigns = await _campaignService.getCampaigns(
        goal: goal, // 'Flatmate', 'Flat', 'Short-stay'
      );
      _campaigns.assignAll(campaigns);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch my campaigns
  Future<void> fetchMyCampaigns() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final campaigns = await _campaignService.getUserCampaigns();
      _myCampaigns.assignAll(campaigns);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create campaign
  Future<bool> createCampaign(Map<String, dynamic> campaignData) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      print('CampaignController: Creating campaign...');
      final campaign = await _campaignService.createCampaign(campaignData);
      print('CampaignController: Campaign created successfully: ${campaign.id}');
      _myCampaigns.insert(0, campaign);
      _campaigns.insert(0, campaign);
      Get.snackbar(
        'Success',
        'Campaign created successfully',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      print('CampaignController: ApiException - ${e.message}');
      print('CampaignController: Status code - ${e.statusCode}');
      print('CampaignController: Errors - ${e.errors}');
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } catch (e) {
      print('CampaignController: Unexpected error - $e');
      Get.snackbar('Error', 'Failed to create campaign: ${e.toString()}', snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update campaign
  Future<bool> updateCampaign(Map<String, dynamic> campaignData) async {
    try {
      _isLoading.value = true;
      final updated = await _campaignService.updateCampaign(campaignData);
      _updateCampaignInLists(updated);
      Get.snackbar(
        'Success',
        'Campaign updated',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete campaign
  Future<bool> deleteCampaign(int id) async {
    try {
      _isLoading.value = true;
      await _campaignService.deleteCampaign(id);
      _campaigns.removeWhere((c) => c.id == id);
      _myCampaigns.removeWhere((c) => c.id == id);
      Get.snackbar(
        'Success',
        'Campaign deleted',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // ========== Campaign Application Operations ==========

  /// Apply to a campaign
  Future<bool> applyToCampaign(int campaignId) async {
    try {
      _isLoading.value = true;
      await _campaignService.applyToCampaign(campaignId);
      Get.snackbar(
        'Success',
        'Application submitted successfully',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch campaign applications
  Future<void> fetchCampaignApplications() async {
    try {
      _isLoading.value = true;
      final applicationsData = await _campaignService.getCampaignApplications();
      _applications.assignAll(
        applicationsData.map((json) => CampaignApplication.fromJson(json)).toList(),
      );
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Respond to application (accept/reject)
  Future<bool> respondToApplication(int applicationId, String status) async {
    try {
      _isLoading.value = true;
      await _campaignService.respondToApplication(applicationId, status);
      Get.snackbar(
        'Success',
        'Application ${status.toLowerCase()}',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create campaign group chat
  Future<bool> createCampaignGroupChat(int campaignId) async {
    try {
      _isLoading.value = true;
      await _campaignService.createCampaignGroupChat(campaignId);
      Get.snackbar(
        'Success',
        'Group chat created successfully',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }



  // Helper methods
  void _updateCampaignInLists(Campaign updated) {
    final index = _campaigns.indexWhere((c) => c.id == updated.id);
    if (index != -1) _campaigns[index] = updated;

    final myIndex = _myCampaigns.indexWhere((c) => c.id == updated.id);
    if (myIndex != -1) _myCampaigns[myIndex] = updated;

    if (_selectedCampaign.value?.id == updated.id) {
      _selectedCampaign.value = updated;
    }
  }

  void setSelectedCampaign(Campaign? campaign) {
    _selectedCampaign.value = campaign;
  }

  /// Clear all data
  void clearData() {
    _campaigns.clear();
    _myCampaigns.clear();
    _selectedCampaign.value = null;
    _applications.clear();
    _errorMessage.value = '';
  }
}
