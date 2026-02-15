import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/create_campaign_controller.dart';
import '../../../../widgets/city_town_picker_bottom_sheet.dart';
import '../../../../widgets/location_picker_bottom_sheet.dart';

// Custom formatter to add commas to numbers
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    final number = int.parse(digitsOnly);
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class SteppedCreateCampaignPage extends StatelessWidget {
  const SteppedCreateCampaignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateCampaignController>(
      init: CreateCampaignController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                if (controller.currentStep > 0) {
                  controller.previousStep();
                } else {
                  Get.back();
                }
              },
            ),
            title: const Text(
              'Create Campaign',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          body: Column(
            children: [
              // Step Indicator
              _buildStepIndicator(controller),
              // Separator between heading and body
              Divider(height: 1, thickness: 1, color: Colors.grey[300]),
              // Form Content
              Expanded(
                child: Form(
                  key: controller.formKey,
                  child: _buildStepContent(context, controller),
                ),
              ),

              // Navigation Buttons
              _buildNavigationButtons(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(CreateCampaignController controller) {
    final stepTitles = [
      'Basic Campaign Details',
      'Homeowner Details',
      'Your Profile',
      'Preferred Flatmate Personality',
      'Apartment Preference',
      'Review',
    ];
    final stepSubtitles = [
      'Max flatmates, city/area, budget, homeowner toggle',
      'Location and house features',
      'Your biodata',
      'Personality traits, lifestyle, smoking & pets',
      controller.creatorIsHomeOwner ? 'Not applicable (homeowner)' : 'Location, budget, property type',
      'Confirm and submit',
    ];
    final stepTitle = stepTitles[controller.currentStep];
    final stepSubtitle = stepSubtitles[controller.currentStep];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Step title on the left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${controller.displayStepNumber} of ${controller.effectiveTotalSteps}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'ProductSans',
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (stepSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    stepSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'ProductSans',
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Circular progress indicator on the right
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[200]!,
                    ),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: controller.displayStepNumber / controller.effectiveTotalSteps,
                    strokeWidth: 4,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.black,
                    ),
                  ),
                ),
                // Step number in center
                Text(
                  '${controller.displayStepNumber}/${controller.effectiveTotalSteps}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    CreateCampaignController controller,
  ) {
    Widget content;
    switch (controller.currentStep) {
      case 0:
        content = _buildBasicInfoStep(context, controller);
        break;
      case 1:
        content = _buildHomeownerStep(context, controller);
        break;
      case 2:
        content = _buildBiodataStep(controller);
        break;
      case 3:
        content = _buildPreferencesStep(context, controller);
        break;
      case 4:
        content = _buildApartmentPreferenceStep(controller);
        break;
      case 5:
        content = _buildReviewStep(controller);
        break;
      default:
        content = const SizedBox();
    }
    if (controller.stepDataLoading) {
      return Column(
        children: [
          const LinearProgressIndicator(color: Colors.black),
          Expanded(child: content),
        ],
      );
    }
    return content;
  }

  Widget _buildBasicInfoStep(
    BuildContext context,
    CreateCampaignController controller,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Goal'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: controller.goal,
            items: controller.goals,
            onChanged: (value) => controller.updateGoal(value!),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Budget Range (NGN)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.campaignStartBudgetController,
                  hintText: 'Min: 100,000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  validator:
                      (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('to', style: TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: _buildTextField(
                  controller: controller.campaignEndBudgetController,
                  hintText: 'Max: 250,000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Required';
                    final maxVal = int.tryParse(value.replaceAll(',', ''));
                    final minStr = controller.campaignStartBudgetController.text.replaceAll(',', '');
                    final minVal = int.tryParse(minStr);
                    if (minVal != null && maxVal != null && maxVal < minVal) {
                      return 'Max must be ≥ min';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Budget Plan'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: controller.campaignBudgetPlan,
            items: controller.budgetPlans,
            onChanged: (value) => controller.updateBudgetPlan(value!),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Max Number of Flatmates'),
          const SizedBox(height: 8),
          _buildNumberField(
            label: 'Maximum flatmates',
            value: controller.maxNumberOfFlatmates,
            min: 1,
            max: 5,
            onChanged: controller.updateMaxNumberOfFlatmates,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('City/Town'),
          const SizedBox(height: 8),
          if (controller.statesLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (controller.statesError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.statesError!,
                  style: TextStyle(color: Colors.red[700], fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => controller.fetchStates(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            )
          else
            _buildTextField(
              controller: controller.campaignCityTownController,
              hintText: 'Tap to choose state then city',
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onTap: () async {
                final result = await showStateCityPicker(
                  context: context,
                  states: controller.states,
                  loadCities: controller.loadCitiesForState,
                  loadAreas: controller.loadAreasForCity,
                  selectedCityName:
                      controller.campaignCityTownController.text.isEmpty
                          ? null
                          : controller.campaignCityTownController.text,
                  title: 'Choose city/town',
                );
                if (result != null && result['cityName'] != null) {
                  controller.selectedCityId =
                      result['cityId'] is int
                          ? result['cityId'] as int
                          : int.tryParse(result['cityId']?.toString() ?? '');
                  controller.selectedAreaId =
                      result['areaId'] is int
                          ? result['areaId'] as int
                          : int.tryParse(result['areaId']?.toString() ?? '');
                  final areaName = result['areaName']?.toString();
                  controller.campaignCityTownController.text =
                      areaName != null && areaName.isNotEmpty
                          ? '${result['cityName']}, $areaName'
                          : result['cityName'] as String;
                  controller.update();
                }
              },
            ),
          const SizedBox(height: 24),

          // _buildSectionTitle('Location'),
          // const SizedBox(height: 8),
          // _buildTextField(
          //   controller: controller.locationController,
          //   hintText: 'Tap to search address on map...',
          //   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          //   onTap: () async {
          //     final result = await showLocationPicker(
          //       context: context,
          //       initialAddress: controller.locationController.text.isEmpty
          //           ? null
          //           : controller.locationController.text,
          //       hintText: 'Search address...',
          //       confirmLabel: 'Use this location',
          //       countries: ['NG'],
          //     );
          //     if (result != null) {
          //       controller.locationController.text = result.address;
          //     }
          //   },
          // ),
          // const SizedBox(height: 24),
          _buildSwitchField(
            label: 'I am a Home Owner',
            value: controller.creatorIsHomeOwner,
            onChanged: controller.updateCreatorIsHomeOwner,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHomeownerStep(
    BuildContext context,
    CreateCampaignController controller,
  ) {
    if (controller.creatorHouseFeaturesFieldsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSectionTitle('Neighboring location'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.creatorNeighboringLocationController,
            hintText: 'Tap to search neighboring location (required)',
            onTap: () async {
              final result = await showLocationPicker(
                context: context,
                initialAddress:
                    controller.creatorNeighboringLocationController.text.isEmpty
                        ? null
                        : controller.creatorNeighboringLocationController.text,
                hintText: 'Search neighboring location...',
                confirmLabel: 'Use this location',
                countries: ['NG'],
              );
              if (result != null) {
                controller.creatorNeighboringLocationController.text =
                    result.address;
                controller.update();
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Your home city / area (optional)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.creatorHomeCityController,
            hintText: 'Tap to choose city and area',
            onTap: () async {
              final result = await showStateCityPicker(
                context: context,
                states: controller.states,
                loadCities: controller.loadCitiesForState,
                loadAreas: controller.loadAreasForCity,
                selectedCityName:
                    controller.creatorHomeCityController.text.isEmpty
                        ? null
                        : controller.creatorHomeCityController.text,
                title: 'Choose home city',
              );
              if (result != null && result['cityName'] != null) {
                controller.creatorSelectedCityId =
                    result['cityId'] is int
                        ? result['cityId'] as int
                        : int.tryParse(result['cityId']?.toString() ?? '');
                controller.creatorSelectedAreaId =
                    result['areaId'] is int
                        ? result['areaId'] as int
                        : int.tryParse(result['areaId']?.toString() ?? '');
                final areaName = result['areaName']?.toString();
                controller.creatorHomeCityController.text =
                    areaName != null && areaName.isNotEmpty
                        ? '${result['cityName']}, $areaName'
                        : result['cityName'] as String;
                controller.update();
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('House features'),
          const SizedBox(height: 12),
          ...controller.creatorHouseFeaturesFields.map((field) {
            final skey = field['skey']?.toString() ?? '';
            final name = field['name']?.toString() ?? skey;
            final dataType = field['fieldDataType']?.toString() ?? 'text';
            final isRequired = field['isRequired'] == true;
            final valueStr = field['value']?.toString() ?? '';
            if (dataType == 'file') {
              return _buildHousePhotosSection(context, controller, name, isRequired);
            }
            if (dataType == 'number') {
              final textController = controller.creatorHouseFeatureControllers[skey];
              if (textController == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(name, style: const TextStyle(fontFamily: 'ProductSans', fontSize: 14, fontWeight: FontWeight.w500)),
                            if (isRequired) const Text(' *', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    TextFormField(
                      controller: textController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter $name',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
                      onChanged: (v) {
                        final numVal = num.tryParse(v.trim());
                        controller.updateCreatorHouseFeature(skey, numVal);
                      },
                    ),
                  ],
                ),
              );
            }
            if (dataType == 'check') {
              final options = valueStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
              final current = controller.creatorHouseFeatureValues[skey];
              List<String> selected = [];
              if (current is List) selected = current.map((e) => e.toString()).toList();
              else if (current != null && current.toString().isNotEmpty) selected = [current.toString()];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(name, style: const TextStyle(fontFamily: 'ProductSans', fontSize: 14, fontWeight: FontWeight.w500)),
                            if (isRequired) const Text(' *', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.map((opt) {
                        final isSelected = selected.contains(opt);
                        return FilterChip(
                          label: Text(opt, style: const TextStyle(fontFamily: 'ProductSans')),
                          selected: isSelected,
                          onSelected: (_) {
                            if (options.length <= 2 && options.every((o) => o == 'true' || o == 'false')) {
                              controller.updateCreatorHouseFeature(skey, opt == 'true');
                            } else {
                              final newList = List<String>.from(selected);
                              if (isSelected) newList.remove(opt);
                              else newList.add(opt);
                              controller.updateCreatorHouseFeature(skey, newList);
                            }
                          },
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontFamily: 'ProductSans'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHousePhotosSection(
    BuildContext context,
    CreateCampaignController controller,
    String label,
    bool isRequired,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired) const Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload photos of your house (tap + to add)',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = (constraints.maxWidth - 24) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...controller.creatorHousePhotos.asMap().entries.map((e) {
                    return SizedBox(
                      width: size,
                      height: size,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              e.value,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                controller.removeCreatorHousePhoto(e.key);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () => _pickHousePhoto(context, controller),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: const Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickHousePhoto(BuildContext context, CreateCampaignController controller) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        controller.addCreatorHousePhoto(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Widget _buildBiodataStep(CreateCampaignController controller) {
    if (controller.biodataFieldsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (controller.biodataFieldsError != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Could not load biodata fields',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
                fontFamily: 'ProductSans',
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                controller.biodataFieldsError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => controller.fetchBiodataFields(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => controller.nextStep(),
              child: const Text('Continue without biodata'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This information helps us match you better',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 24),

          ...controller.biodataFields.map((field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBiodataField(controller, field),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBiodataField(
    CreateCampaignController controller,
    dynamic field,
  ) {
    final isRequired = field['isRequired'] == true;
    final fieldName = field['name']?.toString() ?? '';
    final fieldType = field['fieldDataType']?.toString() ?? 'text';
    final fieldKey = field['skey']?.toString() ?? '';
    if (fieldKey.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              fieldName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'ProductSans',
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
        if (field['description'] != null &&
            field['description'].toString().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            field['description'].toString(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'ProductSans',
            ),
          ),
        ],
        const SizedBox(height: 8),

        if (fieldType == 'select')
          _buildBiodataDropdown(controller, field, fieldKey)
        else if (fieldType == 'date')
          _buildBiodataDatePicker(controller, field, fieldKey)
        else
          _buildBiodataTextField(controller, field, fieldKey),
      ],
    );
  }

  Widget _buildBiodataTextField(
    CreateCampaignController controller,
    dynamic field,
    String fieldKey,
  ) {
    final textController = controller.biodataControllers[fieldKey];
    final label = field['name']?.toString() ?? '';

    return TextFormField(
      controller: textController,
      onChanged: (value) => controller.updateBiodataValue(fieldKey, value),
      decoration: InputDecoration(
        hintText: label.isEmpty ? 'Enter value' : 'Enter $label',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontFamily: 'ProductSans',
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
    );
  }

  static const List<String> _defaultIncomeRangeOptions = [
    'Below NGN50,000',
    'NGN50,000 - NGN100,000',
    'NGN100,000 - NGN200,000',
    'NGN200,000 - NGN500,000',
    'NGN500,000 - NGN1,000,000',
    'Above NGN1,000,000',
  ];

  Widget _buildBiodataDropdown(
    CreateCampaignController controller,
    dynamic field,
    String fieldKey,
  ) {
    final rawValue = controller.biodataValues[fieldKey];
    final value = rawValue != null ? rawValue.toString() : null;
    List<String> options =
        (field['value']?.toString() ?? '')
            .split(',')
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.trim())
            .toList();
    if (fieldKey == 'incomeRange' && options.isEmpty) {
      options = List.from(_defaultIncomeRangeOptions);
    }
    final label = field['name']?.toString() ?? '';

    if (options.isEmpty) {
      return TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: label.isEmpty ? 'No options' : 'Select $label (no options)',
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
      );
    }

    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: value != null && options.contains(value) ? value : null,
      hint: Text(label.isEmpty ? 'Select' : 'Select $label'),
      items:
          options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
              ),
            );
          }).toList(),
      onChanged:
          (newValue) => controller.updateBiodataValue(fieldKey, newValue),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(
        fontFamily: 'ProductSans',
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }

  Widget _buildBiodataDatePicker(
    CreateCampaignController controller,
    dynamic field,
    String fieldKey,
  ) {
    final value = controller.biodataValues[fieldKey];
    String displayDate = 'Select date';
    if (value != null && value.toString().trim().isNotEmpty) {
      try {
        displayDate = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.parse(value.toString()));
      } catch (_) {}
    }

    return InkWell(
      onTap: () async {
        DateTime initial = DateTime.now();
        if (value != null && value.toString().trim().isNotEmpty) {
          try {
            initial = DateTime.parse(value.toString());
          } catch (_) {}
        }
        final date = await showDatePicker(
          context: Get.context!,
          initialDate: initial,
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          controller.updateBiodataValue(fieldKey, date.toIso8601String());
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Text(
              displayDate,
              style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep(
    BuildContext context,
    CreateCampaignController controller,
  ) {
    // Step 3 = Preferred Flatmate Personality only (apartment preference removed from this step)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.goal == 'Flatmate')
            ..._buildMatePersonalityFields(controller),
          if (controller.goal != 'Flatmate')
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No additional preferences needed',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApartmentPreferenceStep(CreateCampaignController controller) {
    if (controller.creatorIsHomeOwner) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              "You're a homeowner — apartment preference is not required. Tap Next to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'ProductSans',
              ),
            ),
          ),
        ),
      );
    }
    if (controller.apartmentPreferenceFieldsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }
    if (controller.apartmentPreferenceFieldsError != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              controller.apartmentPreferenceFieldsError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontFamily: 'ProductSans',
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => controller.fetchApartmentPreferenceFields(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: Colors.black87),
            ),
          ],
        ),
      );
    }
    final children = <Widget>[
      _buildSectionTitle('Apartment Preference'),
      const SizedBox(height: 16),
    ];
    for (final field in controller.apartmentPreferenceFields) {
      final skey = field['skey']?.toString() ?? '';
      final name = field['name']?.toString() ?? skey;
      final dataType = field['fieldDataType']?.toString() ?? 'text';
      final isRequired = field['isRequired'] == true;
      final options =
          field['options'] is List
              ? (field['options'] as List).map((e) => e.toString()).toList()
              : <String>[];
      if (skey == 'location') {
        children.add(
          _buildTextField(
            controller: controller.apartmentLocationController,
            hintText:
                isRequired
                    ? 'Preferred Location (Required)'
                    : 'Preferred Location',
            validator:
                isRequired
                    ? (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null
                    : null,
          ),
        );
      } else if (skey == 'budgetMin') {
        children.add(
          _buildTextField(
            controller: controller.apartmentBudgetMinController,
            hintText:
                isRequired ? 'Minimum Budget (Required)' : 'Minimum Budget',
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            validator:
                isRequired
                    ? (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = num.tryParse(v.replaceAll(',', ''));
                      if (n == null) return 'Enter a valid number';
                      return null;
                    }
                    : null,
          ),
        );
      } else if (skey == 'budgetMax') {
        children.add(
          _buildTextField(
            controller: controller.apartmentBudgetMaxController,
            hintText:
                isRequired ? 'Maximum Budget (Required)' : 'Maximum Budget',
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            validator:
                isRequired
                    ? (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = num.tryParse(v.replaceAll(',', ''));
                      if (n == null) return 'Enter a valid number';
                      return null;
                    }
                    : null,
          ),
        );
      } else if ((dataType == 'select' || dataType == 'dropdown') &&
          options.isNotEmpty) {
        children.add(
          _buildOptionalDropdown(
            label: name,
            value: controller.apartmentPreference[skey]?.toString(),
            items: options,
            onChanged: (v) => controller.updateApartmentPreference(skey, v),
          ),
        );
      }
      children.add(const SizedBox(height: 16));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildReviewStep(CreateCampaignController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Campaign',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 24),

          _buildReviewSection('Basic Information', [
            _buildReviewItem('Goal', controller.goal),
            _buildReviewItem(
              'Budget Range',
              'NGN${controller.campaignStartBudgetController.text} - NGN${controller.campaignEndBudgetController.text}',
            ),
            _buildReviewItem('Budget Plan', controller.campaignBudgetPlan),
            // _buildReviewItem('Location',
            //   '${controller.locationController.text}, ${controller.campaignCityTownController.text}'),
            _buildReviewItem(
              'Max Flatmates',
              controller.maxNumberOfFlatmates.toString(),
            ),
          ]),

          if (controller.biodataValues.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildReviewSection(
              'Biodata',
              controller.biodataFields.map((field) {
                final skey = field['skey']?.toString();
                if (skey == null || skey.isEmpty)
                  return const SizedBox.shrink();
                final value = controller.biodataValues[skey];
                if (value != null && value.toString().isNotEmpty) {
                  String displayValue = value.toString();
                  if (field['fieldDataType']?.toString() == 'date') {
                    try {
                      displayValue = DateFormat(
                        'dd/MM/yyyy',
                      ).format(DateTime.parse(value.toString()));
                    } catch (_) {}
                  }
                  final label = field['name']?.toString() ?? 'Field';
                  return _buildReviewItem(label, displayValue);
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ],

          // Home Owner Details (from homeowner step)
          if (controller.creatorIsHomeOwner) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Home Owner Details', [
              if (controller.creatorNeighboringLocationController.text.isNotEmpty)
                _buildReviewItem(
                  'Neighboring Location',
                  controller.creatorNeighboringLocationController.text,
                ),
              if (controller.creatorHomeCityController.text.isNotEmpty)
                _buildReviewItem(
                  'Home City / Area',
                  controller.creatorHomeCityController.text,
                ),
              ...controller.creatorHouseFeaturesFields.map((field) {
                final skey = field['skey']?.toString() ?? '';
                final name = field['name']?.toString() ?? skey;
                dynamic value = controller.creatorHouseFeatureValues[skey];
                if (value == null) {
                  final c = controller.creatorHouseFeatureControllers[skey];
                  if (c != null && c.text.trim().isNotEmpty) value = c.text.trim();
                }
                if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
                final str = value is List ? value.join(', ') : value.toString();
                return _buildReviewItem(name, str);
              }),
            ]),
          ],

          // Flatmate Preferences
          if (controller.matePersonalityTraitPreference.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildReviewSection(
              'Flatmate Preferences',
              controller.matePersonalityTraitPreference.entries.map((entry) {
                if (entry.value == null) return const SizedBox.shrink();
                final v = entry.value;
                final str =
                    v is List
                        ? v.map((e) => e.toString()).join(', ')
                        : v.toString();
                if (str.isEmpty) return const SizedBox.shrink();
                final label =
                    entry.key
                        .replaceAllMapped(
                          RegExp(r'([A-Z])'),
                          (match) => ' ${match.group(0)}',
                        )
                        .trim();
                final capitalizedLabel =
                    label.isNotEmpty
                        ? label[0].toUpperCase() + label.substring(1)
                        : entry.key;
                return _buildReviewItem(capitalizedLabel, str);
              }).toList(),
            ),
          ],

          // Apartment Preferences (from form when non-homeowner)
          if (!controller.creatorIsHomeOwner &&
              (controller.apartmentLocationController.text.isNotEmpty ||
                  controller.apartmentBudgetMinController.text.isNotEmpty ||
                  controller.apartmentBudgetMaxController.text.isNotEmpty ||
                  controller.apartmentPreference.isNotEmpty)) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Apartment Preferences', [
              if (controller.apartmentLocationController.text.isNotEmpty)
                _buildReviewItem(
                  'Preferred Location',
                  controller.apartmentLocationController.text,
                ),
              if (controller.apartmentBudgetMinController.text.isNotEmpty)
                _buildReviewItem(
                  'Minimum Budget',
                  'NGN${controller.apartmentBudgetMinController.text}',
                ),
              if (controller.apartmentBudgetMaxController.text.isNotEmpty)
                _buildReviewItem(
                  'Maximum Budget',
                  'NGN${controller.apartmentBudgetMaxController.text}',
                ),
              if (controller.apartmentPreference['propertyType'] != null)
                _buildReviewItem(
                  'Property Type',
                  controller.apartmentPreference['propertyType'].toString(),
                ),
              if (controller.apartmentPreference['furnishing'] != null)
                _buildReviewItem(
                  'Furnishing',
                  controller.apartmentPreference['furnishing'].toString(),
                ),
            ]),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'ProductSans',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'ProductSans',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontFamily: 'ProductSans'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(CreateCampaignController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (controller.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          if (controller.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    controller.campaignController.isLoading
                        ? null
                        : () async {
                          if (controller.currentStep <
                              controller.totalSteps - 1) {
                            await controller.nextStep();
                          } else {
                            controller.createCampaign();
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    controller.campaignController.isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          controller.currentStep < controller.totalSteps - 1
                              ? 'Next'
                              : 'Create Campaign',
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable widgets
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'ProductSans',
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontFamily: 'ProductSans',
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
        suffixIcon:
            suffixIcon ??
            (onTap != null
                ? const Icon(Icons.map_outlined, color: Colors.grey)
                : null),
      ),
      style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
    String? firstItemLabel,
  }) {
    final effectiveValue =
        items.contains(value) ? value : (items.isNotEmpty ? items.first : '');
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: items.isEmpty ? null : effectiveValue,
      items:
          items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.isEmpty && firstItemLabel != null ? firstItemLabel : item,
                style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
              ),
            );
          }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(
        fontFamily: 'ProductSans',
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    int min = 1,
    int max = 5,
    required void Function(int) onChanged,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontFamily: 'ProductSans'),
        ),
        const Spacer(),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontFamily: 'ProductSans',
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'ProductSans',
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.black),
      ],
    );
  }

  List<Widget> _buildMatePersonalityFields(
    CreateCampaignController controller,
  ) {
    if (controller.matePersonalityFieldsLoading) {
      return [
        _buildSectionTitle('Preferred Flatmate Personality'),
        const SizedBox(height: 24),
        const Center(child: CircularProgressIndicator(color: Colors.black)),
        const SizedBox(height: 24),
      ];
    }
    if (controller.matePersonalityFieldsError != null) {
      return [
        _buildSectionTitle('Preferred Flatmate Personality'),
        const SizedBox(height: 16),
        Text(
          controller.matePersonalityFieldsError!,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontFamily: 'ProductSans',
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => controller.fetchMatePersonalityFields(),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Retry'),
          style: TextButton.styleFrom(foregroundColor: Colors.black87),
        ),
        const SizedBox(height: 24),
      ];
    }
    final children = <Widget>[
      _buildSectionTitle('Preferred Flatmate Personality'),
      const SizedBox(height: 16),
    ];
    for (final field in controller.matePersonalityFields) {
      final skey = field['skey']?.toString() ?? '';
      final name = field['name']?.toString() ?? skey;
      final options =
          field['options'] is List
              ? (field['options'] as List).map((e) => e.toString()).toList()
              : <String>[];
      final dataType = field['fieldDataType']?.toString() ?? 'radio';
      if (options.isEmpty) continue;
      if (dataType == 'check') {
        children.add(
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'ProductSans',
            ),
          ),
        );
        children.add(const SizedBox(height: 8));
        final selected = controller.matePersonalityTraitPreference[skey];
        final selectedList =
            selected is List
                ? selected.map((e) => e.toString()).toList()
                : (selected != null ? [selected.toString()] : <String>[]);
        children.add(
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                options.map((option) {
                  final isSelected = selectedList.contains(option);
                  return FilterChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                    selected: isSelected,
                    onSelected:
                        (_) => controller.toggleMatePersonalityTraitOption(
                          skey,
                          option,
                        ),
                    backgroundColor: Colors.grey[100],
                    selectedColor: Colors.black,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color:
                          isSelected
                              ? Colors.black
                              : (Colors.grey[400] ?? Colors.grey),
                      width: isSelected ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontFamily: 'ProductSans',
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: true,
                  );
                }).toList(),
          ),
        );
      } else {
        final value =
            controller.matePersonalityTraitPreference[skey]?.toString();
        children.add(
          _buildOptionalDropdown(
            label: name,
            value: value,
            items: options,
            onChanged: (v) => controller.updateMatePersonalityTrait(skey, v),
          ),
        );
      }
      children.add(const SizedBox(height: 16));
    }
    children.add(const SizedBox(height: 24));
    return children;
  }

  Widget _buildOptionalDropdown({
    required String label,
    required dynamic value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'ProductSans',
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: value,
          hint: const Text('Select (Optional)'),
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
