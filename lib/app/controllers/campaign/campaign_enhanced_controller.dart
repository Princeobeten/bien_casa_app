import 'package:get/get.dart';
import '../../models/campaign/campaign.dart';
import '../../services/api/campaign_service.dart';

/// Campaign controller using CampaignService (DioClient).
class CampaignEnhancedController extends GetxController {
  final RxList<Map<String, dynamic>> _campaignsRaw = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _myCampaignsRaw = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _unpublishedCampaignsRaw = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> _selectedCampaignRaw = Rx<Map<String, dynamic>?>(null);
  final RxList<dynamic> _applications = <dynamic>[].obs;
  final RxMap<String, dynamic> _pagination = <String, dynamic>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _unpublishedLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  /// Order: Active first, then Inactive, then others. Draft last.
  static void _sortActiveFirst(List<Map<String, dynamic>> items) {
    const order = ['Active', 'Inactive', 'Closed', 'Completed', 'Draft'];
    items.sort((a, b) {
      final sa = a['status']?.toString() ?? '';
      final sb = b['status']?.toString() ?? '';
      final ia = order.indexOf(sa);
      final ib = order.indexOf(sb);
      if (ia >= 0 && ib >= 0) return ia.compareTo(ib);
      if (ia >= 0) return -1;
      if (ib >= 0) return 1;
      return sa.compareTo(sb);
    });
  }

  List<Campaign> get campaigns => _campaignsRaw.map((m) => Campaign.fromApiMap(m)).toList();
  List<Campaign> get myCampaigns => _myCampaignsRaw.map((m) => Campaign.fromApiMap(m)).toList();
  List<Campaign> get unpublishedCampaigns => _unpublishedCampaignsRaw.map((m) => Campaign.fromApiMap(m)).toList();
  bool get unpublishedLoading => _unpublishedLoading.value;
  Campaign? get selectedCampaign => _selectedCampaignRaw.value != null ? Campaign.fromApiMap(_selectedCampaignRaw.value!) : null;
  List<dynamic> get applications => _applications;
  Map<String, dynamic> get pagination => _pagination;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  Future<void> fetchCampaigns({
    String? status,
    int? cityTownId,
    int? areaId,
    num? budgetMin,
    num? budgetMax,
    String? budgetPlan,
    int? maxFlatmates,
    bool? isAcceptingRequest,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final res = await CampaignService.getAllCampaigns(
        status: status,
        cityTownId: cityTownId,
        areaId: areaId,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        budgetPlan: budgetPlan,
        maxFlatmates: maxFlatmates,
        isAcceptingRequest: isAcceptingRequest,
        page: page,
        limit: limit,
      );
      final list = res['data'];
      final items = list is List ? list.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      _sortActiveFirst(items);
      _campaignsRaw.assignAll(items);
      if (res['pagination'] is Map) _pagination.assignAll(Map<String, dynamic>.from(res['pagination'] as Map));
    } catch (e) {
      _errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', _errorMessage.value, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create campaign (steps 1–4). Campaign remains Draft until publish (step 5) with payment.
  /// If [existingDraftId] is set, step1 is skipped and updates use this draft id (e.g. from GET campaign/data flow).
  Future<bool> createCampaign(Map<String, dynamic> data, {int? existingDraftId}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final maxFlatmates = data['maxNumberOfFlatmates'] is int ? data['maxNumberOfFlatmates'] as int : int.tryParse(data['maxNumberOfFlatmates']?.toString() ?? '1') ?? 1;
      final cityId = data['campaignCityTown'] is int ? data['campaignCityTown'] as int : int.tryParse(data['campaignCityTown']?.toString() ?? '');
      final areaId = data['campaignArea'] is int ? data['campaignArea'] as int : int.tryParse(data['campaignArea']?.toString() ?? '');
      final startBudget = (double.tryParse(data['campaignStartBudget']?.toString() ?? '0')) ?? 0;
      final endBudget = (double.tryParse(data['campaignEndBudget']?.toString() ?? '0')) ?? startBudget;
      final plan = data['campaignBudgetPlan']?.toString() ?? 'month';
      final creatorIsHomeOwner = data['creatorIsHomeOwner'] == true;

      int id;
      if (existingDraftId != null) {
        id = existingDraftId;
      } else {
        if (cityId == null || areaId == null) {
          throw Exception('Campaign city and area are required');
        }
        final res1 = await CampaignService.createStep1(
          maxNumberOfFlatmates: maxFlatmates,
          campaignCityTown: cityId,
          campaignArea: areaId,
          campaignStartBudget: startBudget,
          campaignEndBudget: endBudget,
          campaignBudgetPlan: plan,
          creatorIsHomeOwner: creatorIsHomeOwner,
        );
        final campaignId = res1['data'] is Map ? (res1['data'] as Map)['id'] : null;
        if (campaignId == null) throw Exception('No campaign id returned');
        id = campaignId is int ? campaignId : int.tryParse(campaignId.toString())!;
      }

      if (creatorIsHomeOwner && (data['creatorCityTown'] != null || data['creatorArea'] != null || data['creatorNeighboringLocation'] != null || (data['creatorHouseFeatures'] is Map && (data['creatorHouseFeatures'] as Map).isNotEmpty))) {
        await CampaignService.updateStep2(
          campaignId: id,
          creatorCityTown: data['creatorCityTown'] is int ? data['creatorCityTown'] as int : int.tryParse(data['creatorCityTown']?.toString() ?? ''),
          creatorArea: data['creatorArea'] is int ? data['creatorArea'] as int : int.tryParse(data['creatorArea']?.toString() ?? ''),
          location: data['creatorNeighboringLocation']?.toString(),
          creatorHouseFeatures: data['creatorHouseFeatures'] is Map ? data['creatorHouseFeatures'] as Map<String, dynamic> : null,
        );
      }
      if (data['matePersonalityTraitPreference'] is Map && (data['matePersonalityTraitPreference'] as Map).isNotEmpty) {
        await CampaignService.updateStep3(
          campaignId: id,
          matePersonalityTraitPreference: Map<String, dynamic>.from(data['matePersonalityTraitPreference'] as Map),
        );
      }
      if (!creatorIsHomeOwner && data['apartmentPreference'] is Map && (data['apartmentPreference'] as Map).isNotEmpty) {
        await CampaignService.updateStep4(
          campaignId: id,
          apartmentPreference: Map<String, dynamic>.from(data['apartmentPreference'] as Map),
        );
      }
      await fetchMyCampaigns();
      Get.snackbar('Success', 'Campaign created. Complete payment to activate.', snackPosition: SnackPosition.TOP);
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', _errorMessage.value, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  final RxBool _myCampaignsLoading = false.obs;
  bool get myCampaignsLoading => _myCampaignsLoading.value;

  Future<void> fetchMyCampaigns({
    String? status,
    int? cityTownId,
    int? areaId,
    num? budgetMin,
    num? budgetMax,
    String? budgetPlan,
    int? maxFlatmates,
    bool? isAcceptingRequest,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _myCampaignsLoading.value = true;
      _errorMessage.value = '';
      final res = await CampaignService.getMyCampaigns(
        status: status,
        cityTownId: cityTownId,
        areaId: areaId,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        budgetPlan: budgetPlan,
        maxFlatmates: maxFlatmates,
        isAcceptingRequest: isAcceptingRequest,
        page: page,
        limit: limit,
      );
      final list = res['data'];
      final items = list is List ? list.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      _sortActiveFirst(items);
      _myCampaignsRaw.assignAll(items);
    } catch (e) {
      _errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', _errorMessage.value, snackPosition: SnackPosition.TOP);
    } finally {
      _myCampaignsLoading.value = false;
    }
  }

  /// GET /campaign/user/unpublished — Fetch user's draft (unpublished) campaigns.
  /// Use fetchMyCampaigns for My Campaign tab (GET /campaign/user/my-campaigns).
  Future<void> fetchUnpublishedCampaigns({int page = 1, int limit = 20}) async {
    try {
      _unpublishedLoading.value = true;
      _errorMessage.value = '';
      final res = await CampaignService.getUnpublishedCampaigns(page: page, limit: limit);
      final list = res['campaigns'];
      _unpublishedCampaignsRaw.assignAll(list is List ? list.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[]);
    } catch (e) {
      _errorMessage.value = e.toString().replaceAll('Exception: ', '');
      // Don't snackbar on load so My Campaign tab doesn't annoy user; UI shows empty
    } finally {
      _unpublishedLoading.value = false;
    }
  }

  Future<bool> deleteCampaign(int id) async {
    try {
      _isLoading.value = true;
      await CampaignService.deleteCampaign(id);
      _campaignsRaw.removeWhere((c) => c['id'] == id);
      _myCampaignsRaw.removeWhere((c) => c['id'] == id);
      _unpublishedCampaignsRaw.removeWhere((c) => c['id'] == id);
      if (_selectedCampaignRaw.value?['id'] == id) _selectedCampaignRaw.value = null;
      Get.snackbar('Success', 'Campaign deleted', snackPosition: SnackPosition.TOP);
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Join campaign (N1,000 fee). Requires paymentReference from payment flow.
  Future<bool> joinCampaign({required int campaignId, required String paymentReference}) async {
    try {
      _isLoading.value = true;
      await CampaignService.joinCampaign(campaignId: campaignId, paymentReference: paymentReference);
      Get.snackbar('Success', 'Request submitted successfully', snackPosition: SnackPosition.TOP);
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Apply to join a campaign. Pass paymentReference when payment flow is done (API requires it for N1,000 fee).
  Future<bool> applyToCampaign(int campaignId, {String paymentReference = ''}) async {
    return joinCampaign(campaignId: campaignId, paymentReference: paymentReference);
  }

  Future<void> fetchMyFlatmateRequests() async {
    try {
      _isLoading.value = true;
      final res = await CampaignService.getMyFlatmateRequests();
      final list = res['data'];
      _applications.assignAll(list is List ? list : []);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createCampaignGroupChat(int campaignId) async {
    try {
      _isLoading.value = true;
      await CampaignService.createCampaignChat(campaignId);
      Get.snackbar('Success', 'Group chat created', snackPosition: SnackPosition.TOP);
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void setSelectedCampaign(Campaign? campaign) {
    if (campaign == null) {
      _selectedCampaignRaw.value = null;
      return;
    }
    final combined = <Map<String, dynamic>>[..._campaignsRaw, ..._myCampaignsRaw];
    final raw = combined.where((m) => m['id'] == campaign.id).firstOrNull;
    _selectedCampaignRaw.value = raw;
  }

  void setSelectedCampaignFromMap(Map<String, dynamic>? campaign) {
    _selectedCampaignRaw.value = campaign;
  }

  void clearData() {
    _campaignsRaw.clear();
    _myCampaignsRaw.clear();
    _selectedCampaignRaw.value = null;
    _applications.clear();
    _pagination.clear();
    _errorMessage.value = '';
  }
}
