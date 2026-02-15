import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/campaign/campaign.dart';
import '../routes/app_routes.dart';
import '../services/account_status_service.dart';
import '../services/api/campaign_service.dart';
import '../services/dio_client.dart';
import '../widgets/wallet_pin_confirm_bottom_sheet.dart';
import 'campaign/campaign_enhanced_controller.dart';

class CreateCampaignController extends GetxController {
  CampaignEnhancedController get campaignController => Get.find<CampaignEnhancedController>();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Step management: 0=Basic, 1=Homeowner (conditional), 2=Biodata, 3=Personality, 4=Apartment, 5=Review
  int currentStep = 0;
  final int totalSteps = 6;
  int get effectiveTotalSteps => creatorIsHomeOwner ? 6 : 5;
  int get displayStepNumber => creatorIsHomeOwner ? currentStep + 1 : (currentStep <= 1 ? currentStep + 1 : currentStep);
  /// Draft campaign id after step 0 is saved (createStep1). Used to fetch step data via GET campaign/data/{step}/{id}.
  int? draftCampaignId;
  bool stepDataLoading = false;

  /// When true (opened with Campaign for view), no PATCH/PUT/POST - read-only.
  bool isViewMode = false;

  /// Unpublished (draft) campaigns from GET /campaign/user/unpublished. Fetched after creating draft.
  List<Map<String, dynamic>> unpublishedCampaigns = [];
  
  // Biodata fields
  final Map<String, TextEditingController> biodataControllers = {};
  final Map<String, dynamic> biodataValues = {};
  List<dynamic> biodataFields = [];
  bool biodataFieldsLoading = true;
  String? biodataFieldsError;
  
  // Required fields matching backend spec
  final titleController = TextEditingController();
  final campaignStartBudgetController = TextEditingController();
  final campaignEndBudgetController = TextEditingController();
  final campaignCityTownController = TextEditingController();
  final locationController = TextEditingController();
  
  String goal = 'Flatmate';
  String campaignBudgetPlan = 'Month'; // Month, Quarter, Year (display); API uses lowercase
  DateTime moveDate = DateTime.now().add(const Duration(days: 30));
  String country = 'Nigeria';
  int maxNumberOfFlatmates = 1;

  // Creator home owner: step 1 (conditional) uses these + creatorHouseFeaturesFields
  bool creatorIsHomeOwner = false;
  final creatorHomeDistrictController = TextEditingController();
  final creatorHomeCityController = TextEditingController();
  final creatorNeighboringLocationController = TextEditingController();
  final creatorAdditionalPreferenceNoteController = TextEditingController();
  List<String> creatorHouseFeatures = [];
  /// GET /misc/datafields/creatorHouseFeatures — house features for homeowner step (bedrooms, bathrooms, parking, furnished, amenities, housephoto).
  List<Map<String, dynamic>> creatorHouseFeaturesFields = [];
  bool creatorHouseFeaturesFieldsLoading = true;
  String? creatorHouseFeaturesFieldsError;
  static const String creatorHouseFeaturesCategoryName = 'creatorHouseFeatures';
  /// Values keyed by sKey for dynamic house features (number, check, file).
  Map<String, dynamic> creatorHouseFeatureValues = {};
  final Map<String, TextEditingController> creatorHouseFeatureControllers = {};
  /// House photos for creatorHouseFeatures (file-type fields like housephoto).
  List<File> creatorHousePhotos = [];
  int? creatorSelectedCityId;
  int? creatorSelectedAreaId;
  
  // Mate personality trait preferences. Keys/options from GET /misc/datafields/matePersonalityTraitPreference.
  Map<String, dynamic> matePersonalityTraitPreference = {};
  List<Map<String, dynamic>> matePersonalityFields = [];
  bool matePersonalityFieldsLoading = true;
  String? matePersonalityFieldsError;
  static const String matePersonalityCategoryName = 'matePersonalityTraitPreference';
  
  // Apartment preference step (GET /misc/datafields/apartmentPreference). Only for non-homeowners.
  Map<String, dynamic> apartmentPreference = {};
  List<Map<String, dynamic>> apartmentPreferenceFields = [];
  bool apartmentPreferenceFieldsLoading = true;
  String? apartmentPreferenceFieldsError;
  static const String apartmentPreferenceCategoryName = 'apartmentPreference';
  final apartmentLocationController = TextEditingController();
  final apartmentBudgetMinController = TextEditingController();
  final apartmentBudgetMaxController = TextEditingController();

  // Dropdown options (display: Normal Case; API expects lowercase)
  final List<String> goals = ['Flatmate', 'Flat', 'Short-stay'];
  final List<String> budgetPlans = ['Month', 'Quarter', 'Year'];
  final List<String> budgetPlansApiValues = ['month', 'quarter', 'year'];
  final List<String> countries = ['Nigeria'];
  
  // Apartment preference options
  final List<String> types = ['Flat', 'Duplex', 'Apartment'];
  final List<String> aesthetics = ['Furnished', 'Semi-Furnished', 'Unfurnished'];
  
  // House features options
  final List<String> availableHouseFeatures = [
    'WiFi',
    'Parking',
    'Security',
    'Generator',
    'Water Supply',
    'Air Conditioning',
    'Furnished',
    'Kitchen',
    'Laundry',
  ];

  /// States from GET /misc/states. Cities loaded via GET /misc/cities/{stateId} when user picks state.
  List<Map<String, dynamic>> states = [];
  bool statesLoading = true;
  String? statesError;

  /// Selected city and area IDs for campaign (required for step1 API).
  int? selectedCityId;
  int? selectedAreaId;

  @override
  void onInit() {
    super.onInit();
    fetchBiodataFields();
    fetchMatePersonalityFields();
    fetchApartmentPreferenceFields();
    fetchStates();
    // Load draft after frame so Get.arguments is available when navigating with campaignId
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraftFromArguments());
  }

  /// Load states from GET /misc/states.
  Future<void> fetchStates() async {
    statesLoading = true;
    statesError = null;
    update();
    try {
      states = await AccountStatusService.getStates();
    } catch (e) {
      statesError = e.toString().replaceAll('Exception: ', '');
      states = [];
    }
    statesLoading = false;
    update();
  }

  /// Load cities for a state (GET /misc/cities/{stateId}). Used by state→city picker.
  Future<List<Map<String, dynamic>>> loadCitiesForState(int stateId) async {
    return AccountStatusService.getCities(stateId);
  }

  /// Load areas for a city (GET /misc/areas/{cityTownId}). Used by state→city→area picker.
  Future<List<Map<String, dynamic>>> loadAreasForCity(int cityTownId) async {
    return AccountStatusService.getAreas(cityTownId);
  }

  /// If opened with a campaign id (e.g. edit draft) or Campaign object (view), set draftCampaignId and fetch GET /campaign/data/{step}/{id} for all steps.
  Future<void> _loadDraftFromArguments() async {
    final args = Get.arguments;
    int? id;
    if (args is int) {
      id = args;
    } else if (args is Campaign && args.id != null) {
      id = args.id;
    } else if (args is Map && args['campaignId'] != null) {
      final v = args['campaignId'];
      id = v is int ? v : int.tryParse(v.toString());
    }
    if (id == null) return;
    draftCampaignId = id;
    isViewMode = args is Campaign;
    update();
    await fetchCreatorHouseFeaturesFields();
    for (int step = 0; step <= 4; step++) {
      await loadStepData(step);
    }
    // View mode: if homeowner fields are empty, treat as non-homeowner so homeowner section is not shown
    if (isViewMode && creatorIsHomeOwner) {
      final hasLocation = creatorNeighboringLocationController.text.trim().isNotEmpty;
      final hasHomeCity = creatorHomeCityController.text.trim().isNotEmpty;
      final hasHouseFeatures = creatorHouseFeatureValues.values.any((v) => v != null && v.toString().trim().isNotEmpty) ||
          creatorHouseFeatureControllers.values.any((c) => c.text.trim().isNotEmpty);
      final hasPhotos = creatorHousePhotos.isNotEmpty;
      if (!hasLocation && !hasHomeCity && !hasHouseFeatures && !hasPhotos) {
        creatorIsHomeOwner = false;
        update();
      }
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    campaignStartBudgetController.dispose();
    campaignEndBudgetController.dispose();
    campaignCityTownController.dispose();
    locationController.dispose();
    creatorHomeDistrictController.dispose();
    creatorHomeCityController.dispose();
    creatorNeighboringLocationController.dispose();
    creatorAdditionalPreferenceNoteController.dispose();
    apartmentLocationController.dispose();
    apartmentBudgetMinController.dispose();
    apartmentBudgetMaxController.dispose();
    for (var c in creatorHouseFeatureControllers.values) {
      c.dispose();
    }
    // Dispose biodata controllers
    for (var controller in biodataControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  /// Category name for data fields API: GET /misc/datafields/{categoryName}
  static const String biodataCategoryName = 'biodata';

  // Fetch biodata fields from API: GET /misc/datafields/biodata (uses app base URL + auth via DioClient).
  Future<void> fetchBiodataFields() async {
    biodataFieldsLoading = true;
    biodataFieldsError = null;
    update();

    try {
      final res = await DioClient.get('misc/datafields/${biodataCategoryName}');
      biodataFieldsLoading = false;

      final data = res['data'];
      if (data != null && data is List) {
        biodataFields = [];
        for (var raw in data) {
          final m = raw is Map ? Map.from(raw) : <String, dynamic>{};
          // API returns camelCase "sKey"; normalize so UI can use field['skey']
          final skey = m['sKey']?.toString() ?? m['skey']?.toString();
          if (skey == null || skey.isEmpty) continue;
          biodataFields.add({
            'skey': skey,
            'name': m['name']?.toString(),
            'value': m['value']?.toString(),
            'description': m['description']?.toString(),
            'fieldDataType': m['fieldDataType']?.toString() ?? 'text',
            'isRequired': m['isRequired'] == true,
            'sortOrder': m['sortOrder'] is num ? (m['sortOrder'] as num).toInt() : 0,
            'isJsonValue': m['isJsonValue'] == true,
          });
        }
        biodataFields.sort((a, b) => ((a['sortOrder'] ?? 0) as int).compareTo((b['sortOrder'] ?? 0) as int));
        for (var field in biodataFields) {
          final skey = field['skey']?.toString();
          final dataType = field['fieldDataType']?.toString() ?? 'text';
          if (skey != null && skey.isNotEmpty && (dataType == 'text' || dataType == 'number')) {
            biodataControllers[skey] = TextEditingController();
          }
        }
        biodataFieldsError = null;
      } else {
        biodataFields = [];
      }
    } catch (e) {
      biodataFieldsLoading = false;
      biodataFieldsError = e.toString().replaceAll('Exception: ', '');
      biodataFields = [];
    }
    update();
  }

  /// Fetch step 3 personality fields from GET /misc/datafields/matePersonalityTraitPreference.
  Future<void> fetchMatePersonalityFields() async {
    matePersonalityFieldsLoading = true;
    matePersonalityFieldsError = null;
    update();
    try {
      final res = await DioClient.get('misc/datafields/$matePersonalityCategoryName');
      matePersonalityFieldsLoading = false;
      final data = res['data'];
      if (data != null && data is List) {
        matePersonalityFields = [];
        for (var raw in data) {
          final m = raw is Map ? Map.from(raw) : <String, dynamic>{};
          final skey = m['sKey']?.toString() ?? m['skey']?.toString();
          if (skey == null || skey.isEmpty) continue;
          final valueStr = m['value']?.toString() ?? '';
          final options = valueStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          matePersonalityFields.add({
            'skey': skey,
            'name': m['name']?.toString(),
            'value': valueStr,
            'options': options,
            'fieldDataType': m['fieldDataType']?.toString() ?? 'radio',
            'isJsonValue': m['isJsonValue'] == true,
            'isRequired': m['isRequired'] == true,
            'sortOrder': m['sortOrder'] is num ? (m['sortOrder'] as num).toInt() : 0,
          });
        }
        matePersonalityFields.sort((a, b) => ((a['sortOrder'] ?? 0) as int).compareTo((b['sortOrder'] ?? 0) as int));
        matePersonalityFieldsError = null;
      } else {
        matePersonalityFields = [];
      }
    } catch (e) {
      matePersonalityFieldsLoading = false;
      matePersonalityFieldsError = e.toString().replaceAll('Exception: ', '');
      matePersonalityFields = [];
    }
    update();
  }

  /// Fetch creator house features from GET /misc/datafields/creatorHouseFeatures (for homeowner step).
  Future<void> fetchCreatorHouseFeaturesFields() async {
    creatorHouseFeaturesFieldsLoading = true;
    creatorHouseFeaturesFieldsError = null;
    update();
    try {
      final res = await DioClient.get('misc/datafields/$creatorHouseFeaturesCategoryName');
      creatorHouseFeaturesFieldsLoading = false;
      final data = res['data'];
      if (data != null && data is List) {
        creatorHouseFeaturesFields = [];
        for (var raw in data) {
          final m = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
          final skey = m['sKey']?.toString() ?? m['skey']?.toString();
          if (skey == null || skey.isEmpty) continue;
          final dataType = m['fieldDataType']?.toString() ?? 'text';
          creatorHouseFeaturesFields.add({
            'skey': skey,
            'name': m['name']?.toString(),
            'value': m['value']?.toString(),
            'fieldDataType': dataType,
            'isRequired': m['isRequired'] == true,
            'sortOrder': m['sortOrder'] is num ? (m['sortOrder'] as num).toInt() : 0,
          });
          if (dataType == 'number' && !creatorHouseFeatureControllers.containsKey(skey)) {
            creatorHouseFeatureControllers[skey] = TextEditingController();
          }
        }
        creatorHouseFeaturesFields.sort((a, b) => ((a['sortOrder'] ?? 0) as int).compareTo((b['sortOrder'] ?? 0) as int));
      }
    } catch (e) {
      creatorHouseFeaturesFieldsLoading = false;
      creatorHouseFeaturesFieldsError = e.toString().replaceAll('Exception: ', '');
    }
    update();
  }

  void updateCreatorHouseFeature(String sKey, dynamic value) {
    creatorHouseFeatureValues[sKey] = value;
    update();
  }

  void addCreatorHousePhoto(File file) {
    creatorHousePhotos.add(file);
    update();
  }

  void removeCreatorHousePhoto(int index) {
    if (index >= 0 && index < creatorHousePhotos.length) {
      creatorHousePhotos.removeAt(index);
      update();
    }
  }

  /// Fetch apartment preference fields from GET /misc/datafields/apartmentPreference.
  Future<void> fetchApartmentPreferenceFields() async {
    apartmentPreferenceFieldsLoading = true;
    apartmentPreferenceFieldsError = null;
    update();
    try {
      final res = await DioClient.get('misc/datafields/$apartmentPreferenceCategoryName');
      apartmentPreferenceFieldsLoading = false;
      final data = res['data'];
      if (data != null && data is List) {
        apartmentPreferenceFields = [];
        for (var raw in data) {
          final m = raw is Map ? Map.from(raw) : <String, dynamic>{};
          final skey = m['sKey']?.toString() ?? m['skey']?.toString();
          if (skey == null || skey.isEmpty) continue;
          final valueStr = m['value']?.toString() ?? '';
          final options = valueStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          apartmentPreferenceFields.add({
            'skey': skey,
            'name': m['name']?.toString(),
            'value': valueStr,
            'options': options,
            'fieldDataType': m['fieldDataType']?.toString() ?? 'text',
            'isRequired': m['isRequired'] == true,
            'sortOrder': m['sortOrder'] is num ? (m['sortOrder'] as num).toInt() : 0,
          });
        }
        apartmentPreferenceFields.sort((a, b) => ((a['sortOrder'] ?? 0) as int).compareTo((b['sortOrder'] ?? 0) as int));
        apartmentPreferenceFieldsError = null;
      } else {
        apartmentPreferenceFields = [];
      }
    } catch (e) {
      apartmentPreferenceFieldsLoading = false;
      apartmentPreferenceFieldsError = e.toString().replaceAll('Exception: ', '');
      apartmentPreferenceFields = [];
    }
    update();
  }

  // Step navigation
  Future<void> nextStep() async {
    if (currentStep >= totalSteps - 1) return;
    if (!isViewMode && !(_validateCurrentStep())) return;

    if (isViewMode) {
      currentStep++;
      update();
      if (draftCampaignId != null) await loadStepData(currentStep);
      return;
    }

    // Step 0 → Next: create draft or update existing, then go to step 1 (homeowner) or step 2 (biodata)
    if (currentStep == 0) {
      if (draftCampaignId == null) {
        final created = await _createDraftFromStep0();
        if (!created) return;
        await _fetchUnpublishedCampaigns();
      } else {
        // User went back and changed creatorIsHomeOwner — update backend
        final updated = await _updateStep1FromForm();
        if (!updated) return;
      }
      if (creatorIsHomeOwner) {
        currentStep = 1;
        update();
        await fetchCreatorHouseFeaturesFields();
        if (draftCampaignId != null) await loadStepData(1);
        return;
      }
      currentStep = 2;
      update();
      if (draftCampaignId != null) await loadStepData(2);
      return;
    }

    // Leaving step 1 (Homeowner): PUT /campaign/create/step2
    if (currentStep == 1 && draftCampaignId != null) {
      final saved = await _saveHomeownerStep();
      if (!saved) return;
      currentStep = 2;
      update();
      if (draftCampaignId != null) await loadStepData(2);
      return;
    }

    // Leaving step 2 (Biodata): PATCH /user/update only
    if (currentStep == 2 && draftCampaignId != null) {
      final saved = await _saveBiodataStep();
      if (!saved) return;
    }

    // Leaving step 3: PUT /campaign/create/step3 (personality)
    if (currentStep == 3 && draftCampaignId != null) {
      final saved = await _saveStep3();
      if (!saved) return;
    }

    // Leaving step 4: PUT /campaign/create/step4 (apartment preference)
    if (currentStep == 4 && draftCampaignId != null) {
      final saved = await _saveStep4();
      if (!saved) return;
    }

    if (currentStep < totalSteps - 1) {
      currentStep++;
      update();
      if (draftCampaignId != null) await loadStepData(currentStep);
    }
  }

  void previousStep() {
    if (currentStep <= 0) return;
    if (isViewMode) {
      currentStep--;
      update();
      if (draftCampaignId != null) loadStepData(currentStep);
      return;
    }
    if (currentStep == 2 && creatorIsHomeOwner) {
      currentStep = 1;
      update();
      if (draftCampaignId != null) loadStepData(1);
      return;
    }
    if (currentStep == 1) {
      currentStep = 0;
      update();
      return;
    }
    currentStep--;
    update();
    if (draftCampaignId != null) loadStepData(currentStep);
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep = step;
      update();
      if (draftCampaignId != null) {
        loadStepData(currentStep);
      }
    }
  }

  /// Update existing draft step1 when user changed creatorIsHomeOwner or other basic info.
  Future<bool> _updateStep1FromForm() async {
    if (draftCampaignId == null || selectedCityId == null || selectedAreaId == null) return false;
    try {
      final startBudget = _removeCommas(campaignStartBudgetController.text);
      final endBudget = _removeCommas(campaignEndBudgetController.text);
      await CampaignService.updateStep1(
        campaignId: draftCampaignId!,
        maxNumberOfFlatmates: maxNumberOfFlatmates,
        campaignCityTown: selectedCityId!,
        campaignArea: selectedAreaId!,
        campaignStartBudget: double.tryParse(startBudget) ?? 0,
        campaignEndBudget: double.tryParse(endBudget) ?? 0,
        campaignBudgetPlan: campaignBudgetPlanApiValue,
        creatorIsHomeOwner: creatorIsHomeOwner,
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Create draft via step1 API using current Basic Info form data.
  Future<bool> _createDraftFromStep0() async {
    try {
      final startBudget = _removeCommas(campaignStartBudgetController.text);
      final endBudget = _removeCommas(campaignEndBudgetController.text);
      if (selectedCityId == null || selectedAreaId == null) {
        Get.snackbar('Error', 'Please select city and area');
        return false;
      }
      final res = await CampaignService.createStep1(
        maxNumberOfFlatmates: maxNumberOfFlatmates,
        campaignCityTown: selectedCityId!,
        campaignArea: selectedAreaId!,
        campaignStartBudget: double.tryParse(startBudget) ?? 0,
        campaignEndBudget: double.tryParse(endBudget) ?? 0,
        campaignBudgetPlan: campaignBudgetPlanApiValue,
        creatorIsHomeOwner: creatorIsHomeOwner,
      );
      final data = res['data'];
      if (data is Map) {
        final id = data['id'];
        draftCampaignId = id is int ? id : int.tryParse(id?.toString() ?? '');
        if (draftCampaignId != null) {
          print('Campaign ID (step 1): ${draftCampaignId}');
        }
      }
      if (draftCampaignId == null) {
        Get.snackbar('Error', 'Could not create draft');
        return false;
      }
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// GET /campaign/user/unpublished — Fetch user's draft campaigns (including creator info).
  Future<void> _fetchUnpublishedCampaigns() async {
    try {
      final res = await CampaignService.getUnpublishedCampaigns(page: 1, limit: 20);
      final campaigns = res['campaigns'];
      if (campaigns is List) {
        unpublishedCampaigns = campaigns.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
      }
      update();
    } catch (_) {
      // Non-blocking: draft was created; unpublished list refresh failed
    }
  }

  /// Build bioData map for PATCH /user/update. Normalizes types: age as int, dob as date-only (YYYY-MM-DD).
  Map<String, dynamic> _buildUserUpdateBioData() {
    final bioData = <String, dynamic>{};
    for (var e in biodataValues.entries) {
      final key = e.key.toString();
      final v = e.value;
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isEmpty) continue;

      if (key == 'age') {
        final n = int.tryParse(s);
        if (n != null) bioData[key] = n;
        else bioData[key] = s;
      } else if (key == 'dob') {
        bioData[key] = s.length >= 10 ? s.substring(0, 10) : s;
      } else {
        bioData[key] = s;
      }
    }
    return bioData;
  }

  /// Save when leaving step 1 (Homeowner only). PUT /campaign/create/step2.
  Future<bool> _saveHomeownerStep() async {
    if (draftCampaignId == null) return true;
    try {
      final location = creatorNeighboringLocationController.text.trim();
      if (location.isEmpty) {
        Get.snackbar('Required', 'Neighboring location is required.');
        return false;
      }
      final houseFeatures = <String, dynamic>{};
      for (var e in creatorHouseFeatureValues.entries) {
        final v = e.value;
        if (v == null) continue;
        if (v is String && v.trim().isEmpty) continue;
        houseFeatures[e.key] = v;
      }
      for (var e in creatorHouseFeatureControllers.entries) {
        final txt = e.value.text.trim();
        if (txt.isNotEmpty) {
          final numVal = num.tryParse(txt);
          if (numVal != null) houseFeatures[e.key] = numVal;
        }
      }
      // TODO: Upload creatorHousePhotos to get URLs, then add housephoto: [urls] to houseFeatures
      await CampaignService.updateStep2(
        campaignId: draftCampaignId!,
        creatorCityTown: creatorSelectedCityId,
        creatorArea: creatorSelectedAreaId,
        location: location,
        creatorHouseFeatures: houseFeatures.isEmpty ? null : houseFeatures,
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Save when leaving step 2 (Biodata). PATCH /user/update only.
  Future<bool> _saveBiodataStep() async {
    try {
      if (biodataValues.isNotEmpty) {
        final bioData = _buildUserUpdateBioData();
        if (bioData.isNotEmpty) {
          await AccountStatusService.updateUserProfile({'bioData': bioData});
        }
      }
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// PUT /campaign/create/step3 — save when leaving step 2 (Personality). Retried once on failure.
  Future<bool> _saveStep3() async {
    if (draftCampaignId == null) return true;
    try {
      try {
        await CampaignService.updateStep3(
          campaignId: draftCampaignId!,
          matePersonalityTraitPreference: matePersonalityTraitPreference.isEmpty ? {} : Map<String, dynamic>.from(matePersonalityTraitPreference),
        );
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 800));
        await CampaignService.updateStep3(
          campaignId: draftCampaignId!,
          matePersonalityTraitPreference: matePersonalityTraitPreference.isEmpty ? {} : Map<String, dynamic>.from(matePersonalityTraitPreference),
        );
      }
      return true;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        msg,
        mainButton: TextButton(
          onPressed: () async {
            Get.closeCurrentSnackbar();
            await retrySaveStep3AndGoNext();
          },
          child: const Text('Retry'),
        ),
      );
      return false;
    }
  }

  /// Build apartmentPreference map from form (location, budgetMin, budgetMax, propertyType, furnishing) for PUT step4.
  Map<String, dynamic> _buildApartmentPreferencePayload() {
    final payload = <String, dynamic>{};
    final loc = apartmentLocationController.text.trim();
    if (loc.isNotEmpty) payload['location'] = loc;
    final minB = _removeCommas(apartmentBudgetMinController.text);
    final maxB = _removeCommas(apartmentBudgetMaxController.text);
    final minNum = num.tryParse(minB);
    final maxNum = num.tryParse(maxB);
    if (minNum != null) payload['budgetMin'] = minNum;
    if (maxNum != null) payload['budgetMax'] = maxNum;
    if (apartmentPreference['propertyType'] != null) payload['propertyType'] = apartmentPreference['propertyType'].toString();
    if (apartmentPreference['furnishing'] != null) payload['furnishing'] = apartmentPreference['furnishing'].toString();
    return payload;
  }

  /// PUT /campaign/create/step4 — save when leaving step 3 (Apartment Preference). Only for non-homeowners.
  Future<bool> _saveStep4() async {
    if (draftCampaignId == null) return true;
    if (creatorIsHomeOwner) return true;
    final payload = _buildApartmentPreferencePayload();
    if (payload.isEmpty) return true;
    try {
      try {
        await CampaignService.updateStep4(
          campaignId: draftCampaignId!,
          apartmentPreference: payload,
        );
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 800));
        await CampaignService.updateStep4(
          campaignId: draftCampaignId!,
          apartmentPreference: payload,
        );
      }
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Call from Retry snackbar: re-runs step3 save and advances to next step on success.
  Future<void> retrySaveStep3AndGoNext() async {
    final saved = await _saveStep3();
    if (saved) {
      currentStep++;
      update();
      await loadStepData(currentStep);
    }
  }

  /// GET campaign/data/{step}/{id} and apply to form. Step indices: 0=basic(step1), 1=homeowner(step2), 2=biodata(profile), 3=step3, 4=step4, 5=review.
  Future<void> loadStepData(int stepIndex) async {
    if (draftCampaignId == null || stepIndex < 0 || stepIndex > 5) return;
    stepDataLoading = true;
    update();
    try {
      // Step 2 (biodata): only fetch profile / account-status
      if (stepIndex == 2) {
        try {
          final profileRes = await AccountStatusService.getProfile();
          _applyProfileToBiodata(profileRes);
        } catch (_) {}
        try {
          final accountRes = await AccountStatusService.getAccountStatus();
          _applyUserBiodataFromAccountStatus(accountRes);
        } catch (_) {}
        stepDataLoading = false;
        update();
        return;
      }
      if (stepIndex == 5) {
        stepDataLoading = false;
        update();
        return;
      }
      // stepIndex 0->step1, 1->step2, 2->profile(skip), 3->step3, 4->step4
      final stepName = stepIndex < 2 ? 'step${stepIndex + 1}' : 'step$stepIndex';
      final res = await CampaignService.getCampaignStepData(
        step: stepName,
        campaignId: draftCampaignId!,
      );
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        applyStepData(stepIndex, data);
      }
    } catch (_) {
      // Non-blocking: user can still edit form
    } finally {
      stepDataLoading = false;
      update();
    }
  }

  /// Profile key → possible biodata field keys (from GET /misc/datafields/biodata sKey).
  static const Map<String, List<String>> _profileKeyToBiodataKeys = {
    'firstName': ['firstName', 'first_name', 'firstname'],
    'lastName': ['lastName', 'last_name', 'lastname'],
    'middleName': ['middleName', 'middle_name', 'middlename'],
    'email': ['email'],
    'phone': ['phone', 'phoneNumber', 'phone_number'],
    'profilePhoto': ['profilePhoto', 'profile_photo', 'profilePhotoUrl'],
  };

  /// Biodata key → possible form keys (camelCase / snake_case from datafields).
  static const Map<String, List<String>> _biodataKeyVariants = {
    'age': ['age'],
    'dob': ['dob', 'dateOfBirth', 'date_of_birth'],
    'gender': ['gender'],
    'incomeRange': ['incomeRange', 'income_range', 'incomeRangeId'],
    'nationality': ['nationality'],
    'religion': ['religion'],
    'tribe': ['tribe'],
    'stateOfOrigin': ['stateOfOrigin', 'state_of_origin'],
    'maritalStatus': ['maritalStatus', 'marital_status'],
    'haveChildren': ['haveChildren', 'have_children'],
    'educationLevel': ['educationLevel', 'education_level'],
    'occupation': ['occupation'],
    'cityTown': ['cityTown', 'city_town'],
    'area': ['area'],
  };

  /// Set a biodata value and the first matching controller (exact key or from _biodataKeyVariants).
  void _setBiodataKeyValue(String key, Object? value) {
    if (value == null) return;
    final str = value.toString().trim();
    biodataValues[key] = value;
    final variants = _biodataKeyVariants[key] ?? [key];
    for (final k in variants) {
      if (biodataControllers.containsKey(k)) {
        biodataControllers[k]!.text = str;
        biodataValues[k] = value;
        return;
      }
    }
    if (biodataControllers.containsKey(key)) {
      biodataControllers[key]!.text = str;
    }
  }

  /// Apply GET /user/profile to step 2 biodata: data.* (profile) + data.biodataRecord.bioData + data.biodataRecord.
  void _applyProfileToBiodata(Map<String, dynamic> response) {
    final raw = response['data'];
    if (raw is! Map) return;
    final data = raw;

    // 1) Top-level profile: firstName, lastName, middleName, email, phone, profilePhoto
    for (final entry in _profileKeyToBiodataKeys.entries) {
      if (!data.containsKey(entry.key)) continue;
      final value = data[entry.key];
      if (value == null || value.toString().trim().isEmpty) continue;
      final strValue = value.toString();
      biodataValues[entry.key] = value;
      bool set = false;
      for (final biodataKey in entry.value) {
        if (biodataControllers.containsKey(biodataKey)) {
          biodataValues[biodataKey] = value;
          biodataControllers[biodataKey]!.text = strValue;
          set = true;
          break;
        }
      }
      if (!set && biodataControllers.containsKey(entry.key)) {
        biodataControllers[entry.key]!.text = strValue;
      }
    }

    // 2) data.biodataRecord.bioData (age, dob, gender, incomeRange, nationality, etc.)
    final record = data['biodataRecord'];
    if (record is Map) {
      final bioData = record['bioData'];
      if (bioData is Map) {
        for (var e in bioData.entries) {
          final k = e.key.toString();
          _setBiodataKeyValue(k, e.value);
        }
      }
      // 3) data.biodataRecord top-level (gender, dob, age, religion, tribe, nationality, etc.) as fallback
      final recordKeys = [
        'gender', 'dob', 'age', 'religion', 'tribe', 'nationality', 'stateOfOrigin',
        'maritalStatus', 'haveChildren', 'educationLevel', 'occupation', 'incomeRange', 'cityTown', 'area',
      ];
      for (final k in recordKeys) {
        if (!record.containsKey(k)) continue;
        final v = record[k];
        if (v == null) continue;
        if (biodataValues.containsKey(k) && biodataValues[k] != null) continue;
        _setBiodataKeyValue(k, v);
      }
    }
  }

  /// Apply user bioData from account-status response to biodataValues and biodataControllers.
  /// Handles shapes: response['data'] then data['bioData'], data['user']['bioData'], data['biodataRecord']['bioData'].
  void _applyUserBiodataFromAccountStatus(Map<String, dynamic> response) {
    final data = response['data'] is Map ? response['data'] as Map<String, dynamic> : response;
    Map<String, dynamic>? bioData;
    if (data['bioData'] is Map) {
      bioData = Map<String, dynamic>.from(data['bioData'] as Map);
    } else if (data['user'] is Map && (data['user'] as Map)['bioData'] is Map) {
      bioData = Map<String, dynamic>.from((data['user'] as Map)['bioData'] as Map);
    } else if (data['biodataRecord'] is Map && (data['biodataRecord'] as Map)['bioData'] is Map) {
      bioData = Map<String, dynamic>.from((data['biodataRecord'] as Map)['bioData'] as Map);
    }
    if (bioData == null || bioData.isEmpty) return;
    for (var e in bioData.entries) {
      final key = e.key.toString();
      final value = e.value;
      biodataValues[key] = value;
      final c = biodataControllers[key];
      if (c != null) c.text = value?.toString() ?? '';
    }
  }

  /// Map API step data (from GET /campaign/data/{step}/{id}) into form controllers.
  void applyStepData(int stepIndex, Map<String, dynamic> data) {
    switch (stepIndex) {
      case 0: // step1 – basic info
        if (data['goal'] != null || data['campaignGoal'] != null) {
          final g = data['goal'] ?? data['campaignGoal'];
          if (goals.contains(g?.toString())) goal = g.toString();
        }
        final maxFlat = data['maxNumberOfFlatmates'] ?? data['maxFlatmates'];
        if (maxFlat != null) maxNumberOfFlatmates = maxFlat is int ? maxFlat : (int.tryParse(maxFlat.toString()) ?? maxNumberOfFlatmates);
        final cityVal = data['campaignCityTown'];
        final areaVal = data['campaignArea'];
        if (cityVal is int) {
          selectedCityId = cityVal;
        } else if (cityVal is Map) {
          selectedCityId = cityVal['id'] is int ? cityVal['id'] as int : int.tryParse(cityVal['id']?.toString() ?? '');
        } else if (cityVal != null) {
          selectedCityId = int.tryParse(cityVal.toString());
        }
        if (areaVal is int) {
          selectedAreaId = areaVal;
        } else if (areaVal is Map) {
          selectedAreaId = areaVal['id'] is int ? areaVal['id'] as int : int.tryParse(areaVal['id']?.toString() ?? '');
        } else if (areaVal != null) {
          selectedAreaId = int.tryParse(areaVal.toString());
        }
        final cityTownInfo = data['campaignCityTownInfo'] is Map ? data['campaignCityTownInfo'] as Map : null;
        final areaInfo = data['campaignAreaInfo'] is Map ? data['campaignAreaInfo'] as Map : null;
        String? cityName = data['campaignCityTownName']?.toString() ?? data['cityName']?.toString() ?? cityTownInfo?['name']?.toString();
        String? areaName = data['campaignAreaName']?.toString() ?? data['areaName']?.toString() ?? areaInfo?['name']?.toString();
        if (cityName == null && cityVal is Map) cityName = cityVal['name']?.toString();
        if (areaName == null && areaVal is Map) areaName = areaVal['name']?.toString();
        if (cityName != null || areaName != null) {
          campaignCityTownController.text = [cityName, areaName].where((e) => e != null && e.isNotEmpty).join(', ');
        }
        if (data['location'] != null) locationController.text = data['location'].toString();
        else if (data['creatorNeighboringLocation'] != null) locationController.text = data['creatorNeighboringLocation'].toString();
        else if (data['address'] != null) locationController.text = data['address'].toString();
        if (data['creatorIsHomeOwner'] != null) creatorIsHomeOwner = data['creatorIsHomeOwner'] == true;
        if (data['budget'] is Map) {
          final b = data['budget'] as Map;
          if (b['min'] != null) campaignStartBudgetController.text = formatNumberWithCommas((b['min'] is num ? (b['min'] as num).toInt() : int.tryParse(b['min'].toString()) ?? 0).toString());
          if (b['max'] != null) campaignEndBudgetController.text = formatNumberWithCommas((b['max'] is num ? (b['max'] as num).toInt() : int.tryParse(b['max'].toString()) ?? 0).toString());
          if (b['plan'] != null) campaignBudgetPlan = _budgetPlanFromApi(b['plan'].toString());
        } else {
          if (data['campaignStartBudget'] != null) campaignStartBudgetController.text = formatNumberWithCommas((data['campaignStartBudget'] is num ? (data['campaignStartBudget'] as num).toInt() : int.tryParse(data['campaignStartBudget'].toString()) ?? 0).toString());
          if (data['campaignEndBudget'] != null) campaignEndBudgetController.text = formatNumberWithCommas((data['campaignEndBudget'] is num ? (data['campaignEndBudget'] as num).toInt() : int.tryParse(data['campaignEndBudget'].toString()) ?? 0).toString());
          if (data['campaignBudgetPlan'] != null) campaignBudgetPlan = _budgetPlanFromApi(data['campaignBudgetPlan'].toString());
        }
        break;
      case 1: // step2 – homeowner only (location, creatorHouseFeatures, creatorCityTown, creatorArea)
        if (data['location'] != null) creatorNeighboringLocationController.text = data['location'].toString();
        final cityVal = data['creatorCityTown'];
        final areaVal = data['creatorArea'];
        if (cityVal is int) creatorSelectedCityId = cityVal;
        else if (cityVal != null) creatorSelectedCityId = int.tryParse(cityVal.toString());
        if (areaVal is int) creatorSelectedAreaId = areaVal;
        else if (areaVal != null) creatorSelectedAreaId = int.tryParse(areaVal.toString());
        final creatorCityInfo = data['creatorCityTownInfo'] is Map ? data['creatorCityTownInfo'] as Map : null;
        final creatorAreaInfo = data['creatorAreaInfo'] is Map ? data['creatorAreaInfo'] as Map : null;
        final creatorCityName = creatorCityInfo?['name']?.toString();
        final creatorAreaName = creatorAreaInfo?['name']?.toString();
        if (creatorCityName != null || creatorAreaName != null) {
          creatorHomeCityController.text = [creatorCityName, creatorAreaName].where((e) => e != null && e.isNotEmpty).join(', ');
        }
        if (data['creatorHouseFeatures'] is Map) {
          final f = data['creatorHouseFeatures'] as Map;
          for (var e in f.entries) {
            final k = e.key.toString();
            creatorHouseFeatureValues[k] = e.value;
            final c = creatorHouseFeatureControllers[k];
            if (c != null) c.text = e.value?.toString() ?? '';
          }
        }
        break;
      case 2: // biodata – applied from profile in loadStepData
        break;
      case 3: // step3 – mate preferences (from GET campaign/data/step3; values can be string or List for check-type)
        if (data['matePersonalityTraitPreference'] is Map) {
          final raw = data['matePersonalityTraitPreference'] as Map;
          matePersonalityTraitPreference = {};
          for (var e in raw.entries) {
            final k = e.key.toString();
            final v = e.value;
            if (v is List) {
              matePersonalityTraitPreference[k] = v.map((x) => x.toString()).toList();
            } else if (v != null) {
              matePersonalityTraitPreference[k] = v.toString();
            }
          }
        }
        break;
      case 4: // step4 – apartment preferences
        if (data['apartmentPreference'] is Map) {
          final ap = data['apartmentPreference'] as Map;
          apartmentPreference = Map<String, dynamic>.from(ap);
          if (ap['location'] != null) apartmentLocationController.text = ap['location'].toString();
          if (ap['budgetMin'] != null) apartmentBudgetMinController.text = formatNumberWithCommas((ap['budgetMin'] is num ? (ap['budgetMin'] as num).toInt() : int.tryParse(ap['budgetMin'].toString()) ?? 0).toString());
          if (ap['budgetMax'] != null) apartmentBudgetMaxController.text = formatNumberWithCommas((ap['budgetMax'] is num ? (ap['budgetMax'] as num).toInt() : int.tryParse(ap['budgetMax'].toString()) ?? 0).toString());
        }
        break;
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0: // Basic Info — no homeowner fields here
        return formKey.currentState?.validate() ?? false;
      case 1: // Homeowner step — location required
        if (creatorNeighboringLocationController.text.trim().isEmpty) {
          Get.snackbar('Required', 'Neighboring location is required.');
          return false;
        }
        for (var field in creatorHouseFeaturesFields) {
          if (field['isRequired'] == true) {
            final skey = field['skey']?.toString();
            if (skey == null || skey.isEmpty) continue;
            final value = creatorHouseFeatureValues[skey];
            if (value == null || value.toString().isEmpty) {
              Get.snackbar('Required', '${field['name'] ?? 'This field'} is required');
              return false;
            }
          }
        }
        return true;
      case 2: // Biodata
        for (var field in biodataFields) {
          if (field['isRequired'] == true) {
            final skey = field['skey']?.toString();
            if (skey == null || skey.isEmpty) continue;
            final value = biodataValues[skey];
            if (value == null || value.toString().isEmpty) {
              Get.snackbar('Required Field', '${field['name'] ?? 'This field'} is required');
              return false;
            }
          }
        }
        return true;
      case 4: // Apartment Preference (non-homeowner only): location, budgetMin, budgetMax required
        if (!creatorIsHomeOwner) {
          if (apartmentLocationController.text.trim().isEmpty) {
            Get.snackbar('Required', 'Preferred Location is required.');
            return false;
          }
          final minB = _removeCommas(apartmentBudgetMinController.text);
          final maxB = _removeCommas(apartmentBudgetMaxController.text);
          if (minB.isEmpty || num.tryParse(minB) == null) {
            Get.snackbar('Required', 'Minimum Budget is required.');
            return false;
          }
          if (maxB.isEmpty || num.tryParse(maxB) == null) {
            Get.snackbar('Required', 'Maximum Budget is required.');
            return false;
          }
        }
        return true;
      default:
        return true;
    }
  }

  void updateBiodataValue(String key, dynamic value) {
    biodataValues[key] = value;
    update();
  }

  // Helper to remove commas from number string
  String _removeCommas(String value) {
    return value.replaceAll(',', '');
  }

  // Helper to format number with commas
  String formatNumberWithCommas(String value) {
    // Remove existing commas
    String cleanValue = _removeCommas(value);
    
    // Return empty if no value
    if (cleanValue.isEmpty) return '';
    
    // Parse and format with commas
    try {
      final number = int.parse(cleanValue);
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return cleanValue;
    }
  }

  // Create campaign matching backend spec exactly
  Future<void> createCampaign() async {
    // Validate required fields
    if (campaignStartBudgetController.text.isEmpty ||
        campaignEndBudgetController.text.isEmpty ||
        campaignCityTownController.text.isEmpty) {
      // locationController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    // Remove commas from budget values before parsing
    final startBudget = _removeCommas(campaignStartBudgetController.text);
    final endBudget = _removeCommas(campaignEndBudgetController.text);

    // Build campaign data matching backend spec
    final campaignData = {
      'title': campaignCityTownController.text.isNotEmpty ? campaignCityTownController.text : 'Campaign',
      'goal': goal,
      'campaignStartBudget': double.parse(startBudget),
      'campaignEndBudget': double.parse(endBudget),
      'campaignBudgetPlan': campaignBudgetPlanApiValue,
      'maxNumberOfFlatmates': maxNumberOfFlatmates,
      'campaignCityTown': campaignCityTownController.text,
      // 'location': locationController.text,
      'location': locationController.text.isEmpty ? '' : locationController.text,
      'creatorIsHomeOwner': creatorIsHomeOwner,
      // Note: paymentReference causes backend error due to missing DB column
      // Commenting out for now until backend is fixed
      // 'paymentReference': 'PENDING',
      // Biodata
      if (biodataValues.isNotEmpty) 'biodata': biodataValues,
      // Creator home owner fields (if applicable) — from homeowner step
      if (creatorIsHomeOwner) ...{
        if (creatorSelectedCityId != null) 'creatorCityTown': creatorSelectedCityId,
        if (creatorSelectedAreaId != null) 'creatorArea': creatorSelectedAreaId,
        if (creatorNeighboringLocationController.text.isNotEmpty)
          'creatorNeighboringLocation': creatorNeighboringLocationController.text,
        if (creatorHouseFeatureValues.isNotEmpty || creatorHouseFeatureControllers.values.any((c) => c.text.trim().isNotEmpty))
          'creatorHouseFeatures': () {
            final h = <String, dynamic>{};
            for (var e in creatorHouseFeatureValues.entries) {
              final v = e.value;
              if (v != null && v.toString().trim().isNotEmpty) h[e.key] = v;
            }
            for (var e in creatorHouseFeatureControllers.entries) {
              final txt = e.value.text.trim();
              if (txt.isNotEmpty) {
                final n = num.tryParse(txt);
                if (n != null) h[e.key] = n;
              }
            }
            return h;
          }(),
      },
      // Mate personality trait preferences
      if (matePersonalityTraitPreference.isNotEmpty)
        'matePersonalityTraitPreference': matePersonalityTraitPreference,
      // Apartment preferences
      if (apartmentPreference.isNotEmpty)
        'apartmentPreference': apartmentPreference,
    };

    print('=== CREATING CAMPAIGN ===');
    print('Campaign Data: $campaignData');
    print('========================');

    try {
      final success = await campaignController.createCampaign(
        campaignData,
        existingDraftId: draftCampaignId,
      );
      print('Campaign creation result: $success');
      if (success) {
        await campaignController.fetchMyCampaigns();
        _showCampaignSuccessDialog();
      } else {
        print('Campaign creation failed - success was false');
      }
    } catch (e) {
      print('Error creating campaign: $e');
      Get.snackbar('Error', 'Failed to create campaign: ${e.toString()}');
    }
  }

  void _showCampaignSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Campaign saved',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const Text(
          'Your campaign is saved as draft. Pay ₦1,000 to activate it and make it visible to others.',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.FLATMATE);
            },
            child: const Text('Later', style: TextStyle(fontFamily: 'ProductSans')),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showPublishPaymentDialog();
            },
            child: const Text('Activate now (₦1,000)', style: TextStyle(fontFamily: 'ProductSans', fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showPublishPaymentDialog() {
    if (draftCampaignId == null) {
      Get.offAllNamed(AppRoutes.FLATMATE);
      return;
    }
    final campaignId = draftCampaignId!;
    Get.bottomSheet(
      WalletPinConfirmBottomSheet(
        title: 'Activate campaign',
        amountLabel: 'Amount to pay',
        amountText: '₦1,000',
        showBiometric: false,
        onPinEntered: (pin) async {
          await CampaignService.initiatePublishCampaign(
            campaignId: campaignId,
            paymentMethod: 'wallet',
            walletPin: pin,
          );
          await campaignController.fetchMyCampaigns();
          Get.snackbar(
            'Success',
            'Campaign activated successfully',
            snackPosition: SnackPosition.TOP,
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).then((success) {
      if (success == true) {
        Get.offAllNamed(AppRoutes.FLATMATE);
      }
    });
  }

  void updateGoal(String value) {
    goal = value;
    update();
  }

  void updateBudgetPlan(String value) {
    campaignBudgetPlan = value;
    update();
  }

  /// Returns lowercase value for API (month, quarter, year).
  String get campaignBudgetPlanApiValue {
    final idx = budgetPlans.indexOf(campaignBudgetPlan);
    if (idx >= 0 && idx < budgetPlansApiValues.length) {
      return budgetPlansApiValues[idx];
    }
    return campaignBudgetPlan.toLowerCase();
  }

  /// Map API value (lowercase) to display value (Normal Case).
  static String _budgetPlanFromApi(String apiValue) {
    final lower = apiValue.trim().toLowerCase();
    final idx = ['month', 'quarter', 'year'].indexOf(lower);
    if (idx >= 0 && idx < 3) return ['Month', 'Quarter', 'Year'][idx];
    if (apiValue.isEmpty) return 'Month';
    return apiValue.length == 1 ? apiValue.toUpperCase() : (apiValue[0].toUpperCase() + apiValue.substring(1).toLowerCase());
  }

  void updateMoveDate(DateTime value) {
    moveDate = value;
    update();
  }

  void updateCountry(String value) {
    country = value;
    update();
  }

  void updateMaxNumberOfFlatmates(int value) {
    maxNumberOfFlatmates = value.clamp(1, 5);
    update();
  }

  void updateCreatorIsHomeOwner(bool value) {
    creatorIsHomeOwner = value;
    update();
  }

  void toggleHouseFeature(String feature) {
    if (creatorHouseFeatures.contains(feature)) {
      creatorHouseFeatures.remove(feature);
    } else {
      creatorHouseFeatures.add(feature);
    }
    update();
  }

  void updateMatePersonalityTrait(String key, dynamic value) {
    matePersonalityTraitPreference[key] = value;
    update();
  }

  /// For check-type (multi-select): set selected list. Value sent as List or comma-separated per isJsonValue.
  void updateMatePersonalityTraitMulti(String key, List<String> selected) {
    if (selected.isEmpty) {
      matePersonalityTraitPreference.remove(key);
    } else {
      matePersonalityTraitPreference[key] = selected;
    }
    update();
  }

  /// Toggle one option in a check-type field.
  void toggleMatePersonalityTraitOption(String key, String option) {
    final current = matePersonalityTraitPreference[key];
    List<String> list = current is List ? List<String>.from(current.map((e) => e.toString())) : (current != null ? [current.toString()] : []);
    if (list.contains(option)) {
      list.remove(option);
    } else {
      list.add(option);
    }
    updateMatePersonalityTraitMulti(key, list);
  }

  void updateApartmentPreference(String key, dynamic value) {
    apartmentPreference[key] = value;
    update();
  }
}