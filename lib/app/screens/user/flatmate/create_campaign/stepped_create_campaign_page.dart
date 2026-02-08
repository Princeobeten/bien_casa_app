import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/create_campaign_controller.dart';

// Custom formatter to add commas to numbers
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          body: Column(
            children: [
              // Step Indicator
              _buildStepIndicator(controller),
              
              // Form Content
              Expanded(
                child: Form(
                  key: controller.formKey,
                  child: _buildStepContent(controller),
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
    final steps = ['Basic Info', 'Biodata', 'Preferences', 'Review'];
    
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
                  'Step ${controller.currentStep + 1} of ${controller.totalSteps}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'ProductSans',
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[controller.currentStep],
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[200]!),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: (controller.currentStep + 1) / controller.totalSteps,
                    strokeWidth: 4,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
                // Step number in center
                Text(
                  '${controller.currentStep + 1}/${controller.totalSteps}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w700,
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

  Widget _buildStepContent(CreateCampaignController controller) {
    switch (controller.currentStep) {
      case 0:
        return _buildBasicInfoStep(controller);
      case 1:
        return _buildBiodataStep(controller);
      case 2:
        return _buildPreferencesStep(controller);
      case 3:
        return _buildReviewStep(controller);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep(CreateCampaignController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Campaign Title'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.titleController,
            hintText: 'e.g., Looking for flatmate in Lekki',
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 24),

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
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
            onChanged: controller.updateMaxNumberOfFlatmates,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('City/Town'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.campaignCityTownController,
            hintText: 'e.g., Lagos',
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Location'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.locationController,
            hintText: 'e.g., Lekki Phase 1',
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          _buildSwitchField(
            label: 'I am a Home Owner',
            value: controller.creatorIsHomeOwner,
            onChanged: controller.updateCreatorIsHomeOwner,
          ),
          
          // Home Owner Fields (shown conditionally)
          if (controller.creatorIsHomeOwner) ...[
            const SizedBox(height: 24),
            _buildTextField(
              controller: controller.creatorHomeDistrictController,
              hintText: 'Home District (Optional)',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.creatorHomeCityController,
              hintText: 'Home City (Optional)',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.creatorNeighboringLocationController,
              hintText: 'Neighboring Location (Optional)',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('House Features'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableHouseFeatures.map((feature) {
                final isSelected = controller.creatorHouseFeatures.contains(feature);
                return FilterChip(
                  backgroundColor: Colors.white,
                  label: Text(feature),
                  selected: isSelected,
                  onSelected: (selected) => controller.toggleHouseFeature(feature),
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontFamily: 'ProductSans',
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.creatorAdditionalPreferenceNoteController,
              hintText: 'Additional Notes (Optional)',
              maxLines: 3,
            ),
          ],
          
          const SizedBox(height: 24),

          _buildSwitchField(
            label: 'Accept Requests',
            value: controller.isAcceptingRequest,
            onChanged: controller.updateIsAcceptingRequest,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBiodataStep(CreateCampaignController controller) {
    if (controller.biodataFields.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
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
              fontWeight: FontWeight.w600,
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

  Widget _buildBiodataField(CreateCampaignController controller, dynamic field) {
    final isRequired = field['isRequired'] == true;
    final fieldName = field['name'] ?? '';
    final fieldKey = field['skey'] ?? '';
    final fieldType = field['fieldDataType'] ?? 'text';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              fieldName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
        if (field['description'] != null) ...[
          const SizedBox(height: 4),
          Text(
            field['description'],
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'ProductSans',
            ),
          ),
        ],
        const SizedBox(height: 8),
        
        if (fieldType == 'select')
          _buildBiodataDropdown(controller, field)
        else if (fieldType == 'date')
          _buildBiodataDatePicker(controller, field)
        else
          _buildBiodataTextField(controller, field),
      ],
    );
  }

  Widget _buildBiodataTextField(CreateCampaignController controller, dynamic field) {
    final fieldKey = field['skey'] as String;
    final textController = controller.biodataControllers[fieldKey];
    
    return TextFormField(
      controller: textController,
      onChanged: (value) => controller.updateBiodataValue(fieldKey, value),
      decoration: InputDecoration(
        hintText: 'Enter ${field['name']}',
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
      style: const TextStyle(
        fontFamily: 'ProductSans',
        fontSize: 16,
      ),
    );
  }

  Widget _buildBiodataDropdown(CreateCampaignController controller, dynamic field) {
    final fieldKey = field['skey'];
    final value = controller.biodataValues[fieldKey];
    final options = (field['value'] as String?)?.split(',') ?? [];
    
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: value,
      hint: Text('Select ${field['name']}'),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(
            option,
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: (newValue) => controller.updateBiodataValue(fieldKey, newValue),
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

  Widget _buildBiodataDatePicker(CreateCampaignController controller, dynamic field) {
    final fieldKey = field['skey'];
    final value = controller.biodataValues[fieldKey];
    final displayDate = value != null 
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(value))
        : 'Select date';
    
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: Get.context!,
          initialDate: value != null ? DateTime.parse(value) : DateTime.now(),
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
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep(CreateCampaignController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.goal == 'Flatmate') ..._buildMatePersonalityFields(controller),
          if (controller.goal == 'Flat') ..._buildApartmentPreferenceFields(controller),
          if (controller.goal != 'Flatmate' && controller.goal != 'Flat')
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
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 24),
          
          _buildReviewSection('Basic Information', [
            _buildReviewItem('Title', controller.titleController.text),
            _buildReviewItem('Goal', controller.goal),
            _buildReviewItem('Budget Range', 
              'NGN${controller.campaignStartBudgetController.text} - NGN${controller.campaignEndBudgetController.text}'),
            _buildReviewItem('Budget Plan', controller.campaignBudgetPlan),
            _buildReviewItem('Location', 
              '${controller.locationController.text}, ${controller.campaignCityTownController.text}'),
            _buildReviewItem('Max Flatmates', controller.maxNumberOfFlatmates.toString()),
          ]),
          
          if (controller.biodataValues.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Biodata', 
              controller.biodataFields.map((field) {
                final value = controller.biodataValues[field['skey']];
                if (value != null && value.toString().isNotEmpty) {
                  String displayValue = value.toString();
                  if (field['fieldDataType'] == 'date') {
                    displayValue = DateFormat('dd/MM/yyyy').format(DateTime.parse(value));
                  }
                  return _buildReviewItem(field['name'], displayValue);
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ],
          
          // Home Owner Details
          if (controller.creatorIsHomeOwner) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Home Owner Details', [
              if (controller.creatorHomeDistrictController.text.isNotEmpty)
                _buildReviewItem('Home District', controller.creatorHomeDistrictController.text),
              if (controller.creatorHomeCityController.text.isNotEmpty)
                _buildReviewItem('Home City', controller.creatorHomeCityController.text),
              if (controller.creatorNeighboringLocationController.text.isNotEmpty)
                _buildReviewItem('Neighboring Location', controller.creatorNeighboringLocationController.text),
              if (controller.creatorHouseFeatures.isNotEmpty)
                _buildReviewItem('House Features', controller.creatorHouseFeatures.join(', ')),
              if (controller.creatorAdditionalPreferenceNoteController.text.isNotEmpty)
                _buildReviewItem('Additional Notes', controller.creatorAdditionalPreferenceNoteController.text),
            ]),
          ],
          
          // Flatmate Preferences
          if (controller.matePersonalityTraitPreference.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Flatmate Preferences', 
              controller.matePersonalityTraitPreference.entries.map((entry) {
                if (entry.value != null && entry.value.toString().isNotEmpty) {
                  // Capitalize first letter of key
                  final label = entry.key.replaceAllMapped(
                    RegExp(r'([A-Z])'),
                    (match) => ' ${match.group(0)}',
                  ).trim();
                  final capitalizedLabel = label[0].toUpperCase() + label.substring(1);
                  return _buildReviewItem(capitalizedLabel, entry.value.toString());
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ],
          
          // Apartment Preferences
          if (controller.apartmentPreference.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Apartment Preferences', 
              controller.apartmentPreference.entries.map((entry) {
                if (entry.value != null && entry.value.toString().isNotEmpty) {
                  // Capitalize first letter of key
                  final label = entry.key[0].toUpperCase() + entry.key.substring(1);
                  return _buildReviewItem(label, entry.value.toString());
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
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
            fontWeight: FontWeight.w600,
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
          child: Column(
            children: items,
          ),
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
                fontWeight: FontWeight.w600,
                fontFamily: 'ProductSans',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'ProductSans',
              ),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          if (controller.currentStep > 0)
            const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(() => ElevatedButton(
              onPressed: controller.campaignController.isLoading
                  ? null
                  : () {
                      if (controller.currentStep < controller.totalSteps - 1) {
                        controller.nextStep();
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
              child: controller.campaignController.isLoading
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            )),
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
        fontWeight: FontWeight.w600,
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
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
      ),
      style: const TextStyle(
        fontFamily: 'ProductSans',
        fontSize: 16,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: value,
      items: items.map((item) {
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
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required void Function(int) onChanged,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'ProductSans',
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'ProductSans',
          ),
        ),
        IconButton(
          onPressed: () => onChanged(value + 1),
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
        ),
      ],
    );
  }

  List<Widget> _buildMatePersonalityFields(CreateCampaignController controller) {
    return [
      _buildSectionTitle('Flatmate Preferences (Optional)'),
      const SizedBox(height: 16),
      
      _buildOptionalDropdown(
        label: 'Gender',
        value: controller.matePersonalityTraitPreference['gender'],
        items: controller.genders,
        onChanged: (value) => controller.updateMatePersonalityTrait('gender', value),
      ),
      const SizedBox(height: 16),
      
      _buildOptionalDropdown(
        label: 'Religion',
        value: controller.matePersonalityTraitPreference['religion'],
        items: controller.religions,
        onChanged: (value) => controller.updateMatePersonalityTrait('religion', value),
      ),
      const SizedBox(height: 16),
      
      _buildOptionalDropdown(
        label: 'Marital Status',
        value: controller.matePersonalityTraitPreference['maritalStatus'],
        items: controller.maritalStatuses,
        onChanged: (value) => controller.updateMatePersonalityTrait('maritalStatus', value),
      ),
      const SizedBox(height: 16),
      
      _buildOptionalDropdown(
        label: 'Personality',
        value: controller.matePersonalityTraitPreference['personality'],
        items: controller.personalities,
        onChanged: (value) => controller.updateMatePersonalityTrait('personality', value),
      ),
      const SizedBox(height: 16),
      
      _buildOptionalDropdown(
        label: 'Habit',
        value: controller.matePersonalityTraitPreference['habit'],
        items: controller.habits,
        onChanged: (value) => controller.updateMatePersonalityTrait('habit', value),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildApartmentPreferenceFields(CreateCampaignController controller) {
    return [
      _buildSectionTitle('Apartment Preferences (Optional)'),
      const SizedBox(height: 16),
      
      _buildOptionalDropdown(
        label: 'Type',
        value: controller.apartmentPreference['type'],
        items: controller.types,
        onChanged: (value) => controller.updateApartmentPreference('type', value),
      ),
      const SizedBox(height: 16),
      
      _buildOptionalDropdown(
        label: 'Aesthetic',
        value: controller.apartmentPreference['aesthetic'],
        items: controller.aesthetics,
        onChanged: (value) => controller.updateApartmentPreference('aesthetic', value),
      ),
      const SizedBox(height: 24),
    ];
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
            fontWeight: FontWeight.w600,
            fontFamily: 'ProductSans',
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: value,
          hint: const Text('Select (Optional)'),
          items: items.map((item) {
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
