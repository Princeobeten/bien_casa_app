import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/create_campaign_controller.dart';
import '../../../../models/campaign/campaign.dart';

/// View-only version of SteppedCreateCampaignPage. Same UI, fields, layout. No PATCH/PUT/POST.
class SteppedCampaignViewPage extends StatelessWidget {
  const SteppedCampaignViewPage({super.key});

  Campaign? get _campaign => Get.arguments is Campaign ? Get.arguments as Campaign : null;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateCampaignController>(
      init: CreateCampaignController(),
      builder: (controller) {
        if (_campaign == null && !controller.stepDataLoading) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Get.back()),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: const Center(child: Text('Campaign not found', style: TextStyle(fontFamily: 'ProductSans'))),
          );
        }
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
              'Campaign Details',
              style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
          body: Column(
            children: [
              if (_campaign?.status != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildStatusBadge(_campaign!.status!),
                ),
              ],
              _buildStepIndicator(controller),
              Divider(height: 1, thickness: 1, color: Colors.grey[300]),
              Expanded(
                child: controller.stepDataLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : _buildStepContent(context, controller),
              ),
              _buildNavigationButtons(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: _statusColor(status)),
          const SizedBox(width: 8),
          Text(status, style: TextStyle(fontFamily: 'ProductSans', fontSize: 14, fontWeight: FontWeight.w600, color: _statusColor(status))),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green.shade600;
      case 'inactive':
      case 'paused': return Colors.orange.shade600;
      case 'closed':
      case 'completed': return Colors.red.shade600;
      case 'draft': return Colors.blueGrey.shade600;
      default: return Colors.grey.shade600;
    }
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step ${controller.displayStepNumber} of ${controller.effectiveTotalSteps}', style: TextStyle(fontSize: 12, fontFamily: 'ProductSans', color: Colors.grey[600], fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                Text(stepTitle, style: const TextStyle(fontSize: 18, fontFamily: 'ProductSans', fontWeight: FontWeight.w500, color: Colors.black)),
                if (stepSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(stepSubtitle, style: TextStyle(fontSize: 12, fontFamily: 'ProductSans', color: Colors.grey[600])),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 60, height: 60, child: CircularProgressIndicator(value: 1.0, strokeWidth: 4, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[200]!))),
                SizedBox(width: 60, height: 60, child: CircularProgressIndicator(value: controller.displayStepNumber / controller.effectiveTotalSteps, strokeWidth: 4, backgroundColor: Colors.transparent, valueColor: const AlwaysStoppedAnimation<Color>(Colors.black))),
                Text('${controller.displayStepNumber}/${controller.effectiveTotalSteps}', style: const TextStyle(fontSize: 16, fontFamily: 'ProductSans', fontWeight: FontWeight.w400, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, CreateCampaignController controller) {
    switch (controller.currentStep) {
      case 0: return _buildBasicInfoStep(context, controller);
      case 1: return _buildHomeownerStep(context, controller);
      case 2: return _buildBiodataStep(controller);
      case 3: return _buildPreferencesStep(context, controller);
      case 4: return _buildApartmentPreferenceStep(controller);
      case 5: return _buildReviewStep(controller);
      default: return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep(BuildContext context, CreateCampaignController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Goal'),
          const SizedBox(height: 8),
          _buildReadOnlyDropdown(value: controller.goal, items: controller.goals),
          const SizedBox(height: 24),
          _buildSectionTitle('Budget Range (NGN)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildReadOnlyTextField(controller.campaignStartBudgetController.text, hintText: 'Min: 100,000')),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('to', style: TextStyle(fontSize: 16))),
              Expanded(child: _buildReadOnlyTextField(controller.campaignEndBudgetController.text, hintText: 'Max: 250,000')),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Budget Plan'),
          const SizedBox(height: 8),
          _buildReadOnlyDropdown(value: controller.campaignBudgetPlan, items: controller.budgetPlans),
          const SizedBox(height: 24),
          _buildSectionTitle('Max Number of Flatmates'),
          const SizedBox(height: 8),
          _buildReadOnlyNumberField(label: 'Maximum flatmates', value: controller.maxNumberOfFlatmates),
          const SizedBox(height: 24),
          _buildSectionTitle('City/Town'),
          const SizedBox(height: 8),
          _buildReadOnlyTextField(controller.campaignCityTownController.text, hintText: 'Tap to choose state then city'),
          const SizedBox(height: 24),
          _buildReadOnlySwitchField(label: 'I am a Home Owner', value: controller.creatorIsHomeOwner),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHomeownerStep(BuildContext context, CreateCampaignController controller) {
    if (controller.creatorHouseFeaturesFieldsLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSectionTitle('Neighboring location'),
          const SizedBox(height: 8),
          _buildReadOnlyTextField(controller.creatorNeighboringLocationController.text, hintText: 'Tap to search neighboring location (required)'),
          const SizedBox(height: 24),
          _buildSectionTitle('Your home city / area (optional)'),
          const SizedBox(height: 8),
          _buildReadOnlyTextField(controller.creatorHomeCityController.text, hintText: 'Tap to choose city and area'),
          const SizedBox(height: 24),
          _buildSectionTitle('House features'),
          const SizedBox(height: 12),
          ...controller.creatorHouseFeaturesFields.map((field) {
            final skey = field['skey']?.toString() ?? '';
            final name = field['name']?.toString() ?? skey;
            final dataType = field['fieldDataType']?.toString() ?? 'text';
            final isRequired = field['isRequired'] == true;
            final valueStr = field['value']?.toString() ?? '';
            if (dataType == 'file') return _buildHousePhotosSectionReadOnly(controller, name, isRequired);
            if (dataType == 'number') {
              final textController = controller.creatorHouseFeatureControllers[skey];
              if (textController == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Text(name, style: const TextStyle(fontFamily: 'ProductSans', fontSize: 14, fontWeight: FontWeight.w500)), if (isRequired) const Text(' *', style: TextStyle(color: Colors.red))])),
                    _buildReadOnlyTextField(textController.text, hintText: 'Enter $name'),
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
                    if (name.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Text(name, style: const TextStyle(fontFamily: 'ProductSans', fontSize: 14, fontWeight: FontWeight.w500)), if (isRequired) const Text(' *', style: TextStyle(color: Colors.red))])),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.map((opt) {
                        final isSelected = selected.contains(opt);
                        return FilterChip(
                          label: Text(opt, style: const TextStyle(fontFamily: 'ProductSans')),
                          selected: isSelected,
                          onSelected: null,
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

  Widget _buildHousePhotosSectionReadOnly(CreateCampaignController controller, String label, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Text(label, style: const TextStyle(fontFamily: 'ProductSans', fontSize: 14, fontWeight: FontWeight.w500)), if (isRequired) const Text(' *', style: TextStyle(color: Colors.red))]),
          const SizedBox(height: 8),
          Text('Upload photos of your house (tap + to add)', style: TextStyle(fontFamily: 'ProductSans', fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 12),
          controller.creatorHousePhotos.isEmpty
              ? Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: Text('No photos', style: TextStyle(fontFamily: 'ProductSans', color: Colors.grey[600])))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final size = (constraints.maxWidth - 24) / 3;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.creatorHousePhotos.asMap().entries.map((e) => SizedBox(
                        width: size,
                        height: size,
                        child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(e.value, fit: BoxFit.cover)),
                      )).toList(),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildBiodataStep(CreateCampaignController controller) {
    if (controller.biodataFieldsLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));
    if (controller.biodataFieldsError != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(height: 40),
          Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Could not load biodata fields', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey[700], fontFamily: 'ProductSans')),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(controller.biodataFieldsError!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontFamily: 'ProductSans'))),
        ]),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about yourself', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, fontFamily: 'ProductSans')),
          const SizedBox(height: 8),
          const Text('This information helps us match you better', style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'ProductSans')),
          const SizedBox(height: 24),
          ...controller.biodataFields.map((field) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildBiodataFieldReadOnly(controller, field), const SizedBox(height: 24)])),
        ],
      ),
    );
  }

  Widget _buildBiodataFieldReadOnly(CreateCampaignController controller, dynamic field) {
    final fieldName = field['name']?.toString() ?? '';
    final fieldType = field['fieldDataType']?.toString() ?? 'text';
    final fieldKey = field['skey']?.toString() ?? '';
    if (fieldKey.isEmpty) return const SizedBox.shrink();

    final value = controller.biodataValues[fieldKey];
    String displayValue = value?.toString() ?? '';
    if (fieldType == 'date' && displayValue.isNotEmpty) {
      try { displayValue = DateFormat('dd/MM/yyyy').format(DateTime.parse(displayValue)); } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text(fieldName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'ProductSans')), if (field['isRequired'] == true) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16))]),
        if (field['description'] != null && field['description'].toString().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(field['description'].toString(), style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'ProductSans')),
        ],
        const SizedBox(height: 8),
        _buildReadOnlyTextField(displayValue, hintText: fieldName.isEmpty ? 'Enter value' : 'Enter $fieldName'),
      ],
    );
  }

  Widget _buildPreferencesStep(BuildContext context, CreateCampaignController controller) {
    if (controller.goal != 'Flatmate') {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No additional preferences needed',
            style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'ProductSans'),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildMatePersonalityFieldsReadOnly(controller)),
    );
  }

  List<Widget> _buildMatePersonalityFieldsReadOnly(CreateCampaignController controller) {
    if (controller.matePersonalityFieldsLoading) {
      return [_buildSectionTitle('Preferred Flatmate Personality'), const SizedBox(height: 24), const Center(child: CircularProgressIndicator(color: Colors.black)), const SizedBox(height: 24)];
    }
    if (controller.matePersonalityFieldsError != null) {
      return [_buildSectionTitle('Preferred Flatmate Personality'), const SizedBox(height: 16), Text(controller.matePersonalityFieldsError!, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontFamily: 'ProductSans')), const SizedBox(height: 24)];
    }
    final children = <Widget>[_buildSectionTitle('Preferred Flatmate Personality'), const SizedBox(height: 16)];
    for (final field in controller.matePersonalityFields) {
      final skey = field['skey']?.toString() ?? '';
      final name = field['name']?.toString() ?? skey;
      final options = field['options'] is List ? (field['options'] as List).map((e) => e.toString()).toList() : <String>[];
      final dataType = field['fieldDataType']?.toString() ?? 'radio';
      if (options.isEmpty) continue;
      if (dataType == 'check') {
        children.add(Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'ProductSans')));
        children.add(const SizedBox(height: 8));
        final selected = controller.matePersonalityTraitPreference[skey];
        final selectedList = selected is List ? selected.map((e) => e.toString()).toList() : (selected != null ? [selected.toString()] : <String>[]);
        children.add(Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = selectedList.contains(option);
            return FilterChip(
              label: Text(option, style: TextStyle(fontFamily: 'ProductSans', fontSize: 14, fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400)),
              selected: isSelected,
              onSelected: null,
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.black,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontFamily: 'ProductSans'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ));
      } else {
        final value = controller.matePersonalityTraitPreference[skey]?.toString();
        children.add(_buildReadOnlyOptionalDropdown(label: name, value: value, items: options));
      }
      children.add(const SizedBox(height: 16));
    }
    children.add(const SizedBox(height: 24));
    return children;
  }

  Widget _buildApartmentPreferenceStep(CreateCampaignController controller) {
    if (controller.creatorIsHomeOwner) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(child: Padding(padding: const EdgeInsets.all(40), child: Text("You're a homeowner — apartment preference is not required. Tap Next to continue.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[700], fontFamily: 'ProductSans')))),
      );
    }
    if (controller.apartmentPreferenceFieldsLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));
    if (controller.apartmentPreferenceFieldsError != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(height: 40),
          Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(controller.apartmentPreferenceFieldsError!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontFamily: 'ProductSans')),
        ]),
      );
    }
    final children = <Widget>[_buildSectionTitle('Apartment Preference'), const SizedBox(height: 16)];
    for (final field in controller.apartmentPreferenceFields) {
      final skey = field['skey']?.toString() ?? '';
      final name = field['name']?.toString() ?? skey;
      final dataType = field['fieldDataType']?.toString() ?? 'text';
      final isRequired = field['isRequired'] == true;
      final options = field['options'] is List ? (field['options'] as List).map((e) => e.toString()).toList() : <String>[];
      if (skey == 'location') {
        children.add(_buildReadOnlyTextField(controller.apartmentLocationController.text, hintText: isRequired ? 'Preferred Location (Required)' : 'Preferred Location'));
      } else if (skey == 'budgetMin') {
        children.add(_buildReadOnlyTextField(controller.apartmentBudgetMinController.text, hintText: isRequired ? 'Minimum Budget (Required)' : 'Minimum Budget'));
      } else if (skey == 'budgetMax') {
        children.add(_buildReadOnlyTextField(controller.apartmentBudgetMaxController.text, hintText: isRequired ? 'Maximum Budget (Required)' : 'Maximum Budget'));
      } else if ((dataType == 'select' || dataType == 'dropdown') && options.isNotEmpty) {
        children.add(_buildReadOnlyOptionalDropdown(label: name, value: controller.apartmentPreference[skey]?.toString(), items: options));
      }
      children.add(const SizedBox(height: 16));
    }
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }

  Widget _buildReviewStep(CreateCampaignController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review Your Campaign', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'ProductSans')),
          const SizedBox(height: 24),
          _buildReviewSection('Basic Information', [
            _buildReviewItem('Goal', controller.goal),
            _buildReviewItem('Budget Range', 'NGN${controller.campaignStartBudgetController.text} - NGN${controller.campaignEndBudgetController.text}'),
            _buildReviewItem('Budget Plan', controller.campaignBudgetPlan),
            _buildReviewItem('Max Flatmates', controller.maxNumberOfFlatmates.toString()),
          ]),
          if (controller.biodataValues.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Biodata', controller.biodataFields.map((field) {
              final skey = field['skey']?.toString();
              if (skey == null || skey.isEmpty) return const SizedBox.shrink();
              final value = controller.biodataValues[skey];
              if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
              String displayValue = value.toString();
              if (field['fieldDataType']?.toString() == 'date') { try { displayValue = DateFormat('dd/MM/yyyy').format(DateTime.parse(displayValue)); } catch (_) {} }
              return _buildReviewItem(field['name']?.toString() ?? 'Field', displayValue);
            }).toList()),
          ],
          if (controller.creatorIsHomeOwner) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Home Owner Details', [
              if (controller.creatorNeighboringLocationController.text.isNotEmpty) _buildReviewItem('Neighboring Location', controller.creatorNeighboringLocationController.text),
              if (controller.creatorHomeCityController.text.isNotEmpty) _buildReviewItem('Home City / Area', controller.creatorHomeCityController.text),
              ...controller.creatorHouseFeaturesFields.map((field) {
                final skey = field['skey']?.toString() ?? '';
                final name = field['name']?.toString() ?? skey;
                dynamic value = controller.creatorHouseFeatureValues[skey];
                if (value == null) { final c = controller.creatorHouseFeatureControllers[skey]; if (c != null && c.text.trim().isNotEmpty) value = c.text.trim(); }
                if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
                return _buildReviewItem(name, value is List ? value.join(', ') : value.toString());
              }),
            ]),
          ],
          if (controller.matePersonalityTraitPreference.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Flatmate Preferences', controller.matePersonalityTraitPreference.entries.map((entry) {
              if (entry.value == null) return const SizedBox.shrink();
              final v = entry.value;
              final str = v is List ? v.map((e) => e.toString()).join(', ') : v.toString();
              if (str.isEmpty) return const SizedBox.shrink();
              final label = entry.key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim();
              final cap = label.isNotEmpty ? label[0].toUpperCase() + label.substring(1) : entry.key;
              return _buildReviewItem(cap, str);
            }).toList()),
          ],
          if (!controller.creatorIsHomeOwner && (controller.apartmentLocationController.text.isNotEmpty || controller.apartmentBudgetMinController.text.isNotEmpty || controller.apartmentBudgetMaxController.text.isNotEmpty || controller.apartmentPreference.isNotEmpty)) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Apartment Preferences', [
              if (controller.apartmentLocationController.text.isNotEmpty) _buildReviewItem('Preferred Location', controller.apartmentLocationController.text),
              if (controller.apartmentBudgetMinController.text.isNotEmpty) _buildReviewItem('Minimum Budget', 'NGN${controller.apartmentBudgetMinController.text}'),
              if (controller.apartmentBudgetMaxController.text.isNotEmpty) _buildReviewItem('Maximum Budget', 'NGN${controller.apartmentBudgetMaxController.text}'),
              if (controller.apartmentPreference['propertyType'] != null) _buildReviewItem('Property Type', controller.apartmentPreference['propertyType'].toString()),
              if (controller.apartmentPreference['furnishing'] != null) _buildReviewItem('Furnishing', controller.apartmentPreference['furnishing'].toString()),
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
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'ProductSans')),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Column(children: items)),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'ProductSans'))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 14, fontFamily: 'ProductSans'))),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(CreateCampaignController controller) {
    final isLastStep = controller.currentStep >= controller.totalSteps - 1;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          if (controller.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Back', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
              ),
            ),
          if (controller.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: isLastStep
                ? OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Done', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
                  )
                : ElevatedButton(
                    onPressed: () => controller.nextStep(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Next', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w400)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'ProductSans', color: Colors.black));
  }

  Widget _buildReadOnlyTextField(String value, {String hintText = ''}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.transparent)),
      child: Row(
        children: [
          Expanded(child: Text(value.isEmpty ? hintText : value, style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, color: value.isEmpty ? Colors.grey[500] : Colors.black))),
          if (value.isEmpty) const Icon(Icons.map_outlined, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildReadOnlyDropdown({required String value, required List<String> items}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(child: Text(items.contains(value) ? value : (items.isNotEmpty ? items.first : ''), style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16, color: Colors.black))),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildReadOnlyNumberField({required String label, required int value}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontFamily: 'ProductSans')),
        const Spacer(),
        Text(value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, fontFamily: 'ProductSans')),
      ],
    );
  }

  Widget _buildReadOnlySwitchField({required String label, required bool value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'ProductSans')),
        Text(value ? 'Yes' : 'No', style: const TextStyle(fontSize: 16, fontFamily: 'ProductSans')),
      ],
    );
  }

  Widget _buildReadOnlyOptionalDropdown({required String label, required String? value, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'ProductSans')),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(child: Text(value ?? 'Select (Optional)', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, color: value != null ? Colors.black : Colors.grey[500]))),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
