import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'campaign/campaign_enhanced_controller.dart';

class CreateCampaignController extends GetxController {
  CampaignEnhancedController get campaignController => Get.find<CampaignEnhancedController>();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Step management
  int currentStep = 0;
  final int totalSteps = 4; // Basic Info, Biodata, Preferences, Review
  
  // Biodata fields
  final Map<String, TextEditingController> biodataControllers = {};
  final Map<String, dynamic> biodataValues = {};
  List<dynamic> biodataFields = [];
  
  // Required fields matching backend spec
  final titleController = TextEditingController();
  final campaignStartBudgetController = TextEditingController();
  final campaignEndBudgetController = TextEditingController();
  final campaignCityTownController = TextEditingController();
  final locationController = TextEditingController();
  
  String goal = 'Flatmate';
  String campaignBudgetPlan = 'month'; // year, month, quarter
  DateTime moveDate = DateTime.now().add(const Duration(days: 30));
  String country = 'Nigeria';
  int maxNumberOfFlatmates = 1;
  bool isAcceptingRequest = true;
  
  // Creator home owner fields
  bool creatorIsHomeOwner = false;
  final creatorHomeDistrictController = TextEditingController();
  final creatorHomeCityController = TextEditingController();
  final creatorNeighboringLocationController = TextEditingController();
  final creatorAdditionalPreferenceNoteController = TextEditingController();
  List<String> creatorHouseFeatures = [];
  
  // Mate personality trait preferences (JSON)
  Map<String, dynamic> matePersonalityTraitPreference = {};
  
  // Apartment preferences (JSON)
  Map<String, dynamic> apartmentPreference = {};

  // Dropdown options
  final List<String> goals = ['Flatmate', 'Flat', 'Short-stay'];
  final List<String> budgetPlans = ['month', 'quarter', 'year'];
  final List<String> countries = ['Nigeria'];
  
  // Personality trait options
  final List<String> genders = ['Male', 'Female'];
  final List<String> religions = ['Christian', 'Muslim', 'Other'];
  final List<String> maritalStatuses = ['Single', 'Married'];
  final List<String> personalities = ['Introvert', 'Extrovert', 'Ambivert'];
  final List<String> habits = ['Yes, smokes', 'No smoking', 'Drinks occasionally'];
  
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

  @override
  void onInit() {
    super.onInit();
    fetchBiodataFields();
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
    // Dispose biodata controllers
    for (var controller in biodataControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  // Fetch biodata fields from API
  Future<void> fetchBiodataFields() async {
    try {
      final response = await GetConnect().get(
        'https://bien-casa-be-mvp.up.railway.app/api/misc/datafields/biodata',
      );
      
      if (response.statusCode == 200 && response.body['data'] != null) {
        biodataFields = response.body['data'];
        // Sort by sortOrder
        biodataFields.sort((a, b) => (a['sortOrder'] ?? 0).compareTo(b['sortOrder'] ?? 0));
        
        // Initialize controllers for text fields
        for (var field in biodataFields) {
          if (field['fieldDataType'] == 'text') {
            biodataControllers[field['skey']] = TextEditingController();
          }
        }
        update();
      }
    } catch (e) {
      print('Error fetching biodata fields: $e');
    }
  }

  // Step navigation
  void nextStep() {
    if (currentStep < totalSteps - 1) {
      // Validate current step before moving
      if (_validateCurrentStep()) {
        currentStep++;
        update();
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      update();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep = step;
      update();
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0: // Basic Info
        return formKey.currentState?.validate() ?? false;
      case 1: // Biodata
        // Validate required biodata fields
        for (var field in biodataFields) {
          if (field['isRequired'] == true) {
            final value = biodataValues[field['skey']];
            if (value == null || value.toString().isEmpty) {
              Get.snackbar('Required Field', '${field['name']} is required');
              return false;
            }
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
    if (titleController.text.isEmpty ||
        campaignStartBudgetController.text.isEmpty ||
        campaignEndBudgetController.text.isEmpty ||
        campaignCityTownController.text.isEmpty ||
        locationController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    // Remove commas from budget values before parsing
    final startBudget = _removeCommas(campaignStartBudgetController.text);
    final endBudget = _removeCommas(campaignEndBudgetController.text);

    // Build campaign data matching backend spec
    final campaignData = {
      'title': titleController.text,
      'goal': goal,
      'campaignStartBudget': double.parse(startBudget),
      'campaignEndBudget': double.parse(endBudget),
      'campaignBudgetPlan': campaignBudgetPlan,
      'maxNumberOfFlatmates': maxNumberOfFlatmates,
      'campaignCityTown': campaignCityTownController.text,
      'location': locationController.text,
      'creatorIsHomeOwner': creatorIsHomeOwner,
      'isAcceptingRequest': isAcceptingRequest,
      // Note: paymentReference causes backend error due to missing DB column
      // Commenting out for now until backend is fixed
      // 'paymentReference': 'PENDING',
      // Biodata
      if (biodataValues.isNotEmpty) 'biodata': biodataValues,
      // Creator home owner fields (if applicable)
      if (creatorIsHomeOwner) ...{
        if (creatorHomeDistrictController.text.isNotEmpty)
          'creatorHomeDistrict': creatorHomeDistrictController.text,
        if (creatorHomeCityController.text.isNotEmpty)
          'creatorHomeCity': creatorHomeCityController.text,
        if (creatorNeighboringLocationController.text.isNotEmpty)
          'creatorNeighboringLocation': creatorNeighboringLocationController.text,
        if (creatorHouseFeatures.isNotEmpty)
          'creatorHouseFeatures': {
            'features': creatorHouseFeatures,
          },
        if (creatorAdditionalPreferenceNoteController.text.isNotEmpty)
          'creatorAdditionalPreferenceNote': creatorAdditionalPreferenceNoteController.text,
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
      final success = await campaignController.createCampaign(campaignData);
      print('Campaign creation result: $success');
      if (success) {
        Get.back();
        // Refresh campaigns
        await campaignController.fetchMyCampaigns();
      } else {
        print('Campaign creation failed - success was false');
      }
    } catch (e) {
      print('Error creating campaign: $e');
      Get.snackbar('Error', 'Failed to create campaign: ${e.toString()}');
    }
  }

  void updateGoal(String value) {
    goal = value;
    update();
  }

  void updateBudgetPlan(String value) {
    campaignBudgetPlan = value;
    update();
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
    maxNumberOfFlatmates = value;
    update();
  }

  void updateIsAcceptingRequest(bool value) {
    isAcceptingRequest = value;
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

  void updateApartmentPreference(String key, dynamic value) {
    apartmentPreference[key] = value;
    update();
  }
}