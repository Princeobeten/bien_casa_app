import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/kyc_controller.dart';
import '../../services/account_status_service.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class CompleteBiodataScreen extends StatefulWidget {
  const CompleteBiodataScreen({super.key});

  @override
  State<CompleteBiodataScreen> createState() => _CompleteBiodataScreenState();
}

class _CompleteBiodataScreenState extends State<CompleteBiodataScreen> {
  final _isLoading = false.obs;
  final _isFetchingFields = true.obs;
  final _formKey = GlobalKey<FormState>();
  final kycController = Get.find<KYCController>();
  
  final Map<String, dynamic> _formData = {};
  List<dynamic> _bioDataFields = [];

  @override
  void initState() {
    super.initState();
    _fetchBioDataFields();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      print('📤 Fetching user profile...');
      final token = await StorageService.getToken();
      final response = await ApiService.getUserProfile(token: token!);
      
      print('📥 User profile response: $response');
      
      if (response['data'] != null) {
        final data = response['data'];
        
        // Pre-populate form data from user profile
        setState(() {
          // Map common fields from user profile to biodata form
          if (data['firstName'] != null) {
            _formData['firstName'] = data['firstName'];
          }
          if (data['lastName'] != null) {
            _formData['lastName'] = data['lastName'];
          }
          if (data['middleName'] != null) {
            _formData['middleName'] = data['middleName'];
          }
          if (data['email'] != null) {
            _formData['email'] = data['email'];
          }
          if (data['phone'] != null) {
            _formData['phone'] = data['phone'];
          }
          if (data['phoneNumber'] != null) {
            _formData['phoneNumber'] = data['phoneNumber'];
          }
          if (data['gender'] != null) {
            _formData['gender'] = data['gender'];
          }
          
          // Check for bioData in biodataRecord.bioData (nested structure)
          if (data['biodataRecord'] != null && data['biodataRecord'] is Map) {
            final biodataRecord = data['biodataRecord'] as Map<String, dynamic>;
            
            // Get bioData from the nested structure
            if (biodataRecord['bioData'] != null && biodataRecord['bioData'] is Map) {
              final bioData = biodataRecord['bioData'] as Map<String, dynamic>;
              bioData.forEach((key, value) {
                if (value != null && value.toString().isNotEmpty) {
                  _formData[key] = value;
                }
              });
            }
            
            // Also check for direct fields in biodataRecord
            if (biodataRecord['gender'] != null) {
              _formData['gender'] = biodataRecord['gender'];
            }
            if (biodataRecord['dob'] != null) {
              _formData['dob'] = biodataRecord['dob'].toString().split('T')[0]; // Extract date part
            }
            if (biodataRecord['age'] != null) {
              _formData['age'] = biodataRecord['age'];
            }
          }
          
          // Fallback: If bioData exists directly in the response
          if (data['bioData'] != null && data['bioData'] is Map) {
            final bioData = data['bioData'] as Map<String, dynamic>;
            bioData.forEach((key, value) {
              if (value != null && value.toString().isNotEmpty) {
                _formData[key] = value;
              }
            });
          }
        });
        
        print('✅ Pre-populated form data: $_formData');
      }
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      // Don't show error snackbar, just continue with empty form
    }
  }

  Future<void> _fetchBioDataFields() async {
    _isFetchingFields.value = true;

    try {
      print('📤 Fetching biodata fields...');
      final response = await AccountStatusService.getDataFields('biodata');
      
      print('📥 Biodata fields response: $response');
      
      if (response['data'] != null) {
        final fields = response['data'] is List ? response['data'] : [];
        print('📋 Total fields received: ${fields.length}');
        
        setState(() {
          _bioDataFields = fields;
        });
        
        // Print each field for debugging
        for (var field in fields) {
          print('Field: ${field['name']} (${field['sKey']}) - Type: ${field['fieldDataType']} - Required: ${field['isRequired']}');
        }
      }
    } catch (e) {
      print('❌ Error fetching biodata fields: $e');
      Get.snackbar(
        'Error',
        'Failed to load bio data fields',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isFetchingFields.value = false;
    }
  }

  Future<void> _submitBioData() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    _isLoading.value = true;

    try {
      // Prepare bioData object
      final bioData = <String, dynamic>{};
      _formData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          bioData[key] = value;
        }
      });

      print('📤 Submitting biodata...');
      print('📤 Payload: $bioData');

      // Submit to API
      final response = await AccountStatusService.updateUserProfile({
        'bioData': bioData,
      });

      print('📥 Submit response: $response');

      // Update KYC status first
      kycController.bioDataCompleted.value = true;
      await kycController.fetchAccountStatus();

      // Show success message
      Get.snackbar(
        'Success',
        response['message'] ?? 'Bio data updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate back to home with result
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pop(true);
    } catch (e) {
      print('❌ Error submitting biodata: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _skipBioData() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Skip Bio Data?',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'You can complete this later from your profile settings.',
          style: TextStyle(
            fontFamily: 'ProductSans Light',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'ProductSans',
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              print('🔄 Skip button pressed');
              
              // Close dialog first
              Navigator.of(context).pop();
              print('✅ Dialog closed');
              
              // Wait a moment for dialog to close
              await Future.delayed(const Duration(milliseconds: 200));
              
              // Mark as skipped (completed) so user can move to next step
              kycController.bioDataCompleted.value = true;
              print('✅ bioDataCompleted set to true');
              
              // Show snackbar
              Get.snackbar(
                'Skipped',
                'You can complete bio data later from your profile',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
              
              // Close the biodata screen and return to home
              print('🔄 Closing biodata screen...');
              Navigator.of(context).pop(true);
              print('✅ Biodata screen closed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontFamily: 'ProductSans',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Get.back(),
            padding: const EdgeInsets.only(left: 18),
          ),
          title: const Text(
            'Complete Bio Data',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: _skipBioData,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (_isFetchingFields.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          if (_bioDataFields.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No bio data fields available',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'ProductSans',
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _fetchBioDataFields,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: Get.width * 0.06,
                        vertical: Get.height * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tell us about yourself',
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'ProductSans',
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This information helps us provide better matches',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'ProductSans Light',
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Dynamic form fields
                          ..._bioDataFields.map((field) => _buildFormField(field)).toList(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Submit Button
                  Container(
                    padding: EdgeInsets.all(Get.width * 0.06),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading.value ? null : _submitBioData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Bio Data',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'ProductSans',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFormField(dynamic field) {
    // Map API response fields correctly
    final fieldName = field['sKey'] ?? field['fieldName'] ?? '';
    final fieldLabel = field['name'] ?? field['fieldLabel'] ?? fieldName;
    final fieldType = field['fieldDataType'] ?? field['fieldType'] ?? 'text';
    final isRequired = field['isRequired'] ?? false;
    
    // Parse options from 'value' field (comma-separated string)
    List<String> options = [];
    if (field['value'] != null && field['value'].toString().isNotEmpty) {
      options = field['value'].toString().split(',').map((e) => e.trim()).toList();
    }
    
    // Add default income range options if field is incomeRange and has no options
    if (fieldName == 'incomeRange' && options.isEmpty) {
      options = [
        'Below NGN50,000',
        'NGN50,000 - NGN100,000',
        'NGN100,000 - NGN200,000',
        'NGN200,000 - NGN500,000',
        'NGN500,000 - NGN1,000,000',
        'Above NGN1,000,000',
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fieldType == 'select' || fieldType == 'dropdown')
            options.isEmpty
                ? _buildTextField(fieldName, fieldLabel, isRequired)
                : _buildDropdownField(fieldName, fieldLabel, options, isRequired)
          else if (fieldType == 'radio')
            _buildRadioField(fieldName, fieldLabel, options, isRequired)
          else if (fieldType == 'textarea')
            _buildTextAreaField(fieldName, fieldLabel, isRequired)
          else if (fieldType == 'number')
            _buildNumberField(fieldName, fieldLabel, isRequired)
          else if (fieldType == 'date')
            _buildDateField(fieldName, fieldLabel, isRequired)
          else
            _buildTextField(fieldName, fieldLabel, isRequired),
        ],
      ),
    );
  }

  Widget _buildTextField(String fieldName, String fieldLabel, bool isRequired) {
    return TextFormField(
      initialValue: _formData[fieldName]?.toString(),
      decoration: InputDecoration(
        labelText: '$fieldLabel${isRequired ? ' *' : ''}',
        labelStyle: const TextStyle(
          fontFamily: 'ProductSans',
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      validator: isRequired
          ? (value) => value == null || value.isEmpty ? '$fieldLabel is required' : null
          : null,
      onSaved: (value) => _formData[fieldName] = value,
      onChanged: (value) => _formData[fieldName] = value,
    );
  }

  Widget _buildTextAreaField(String fieldName, String fieldLabel, bool isRequired) {
    return TextFormField(
      initialValue: _formData[fieldName]?.toString(),
      maxLines: 4,
      decoration: InputDecoration(
        labelText: '$fieldLabel${isRequired ? ' *' : ''}',
        labelStyle: const TextStyle(
          fontFamily: 'ProductSans',
          color: Colors.grey,
        ),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      validator: isRequired
          ? (value) => value == null || value.isEmpty ? '$fieldLabel is required' : null
          : null,
      onSaved: (value) => _formData[fieldName] = value,
      onChanged: (value) => _formData[fieldName] = value,
    );
  }

  Widget _buildNumberField(String fieldName, String fieldLabel, bool isRequired) {
    return TextFormField(
      initialValue: _formData[fieldName]?.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '$fieldLabel${isRequired ? ' *' : ''}',
        labelStyle: const TextStyle(
          fontFamily: 'ProductSans',
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      validator: isRequired
          ? (value) => value == null || value.isEmpty ? '$fieldLabel is required' : null
          : null,
      onSaved: (value) => _formData[fieldName] = value != null ? int.tryParse(value) : null,
      onChanged: (value) => _formData[fieldName] = value.isNotEmpty ? int.tryParse(value) : null,
    );
  }

  Widget _buildDateField(String fieldName, String fieldLabel, bool isRequired) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _formData[fieldName]),
      style: const TextStyle(
        fontFamily: 'ProductSans',
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: '$fieldLabel${isRequired ? ' *' : ''}',
        labelStyle: const TextStyle(
          fontFamily: 'ProductSans',
          color: Colors.grey,
        ),
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          setState(() {
            _formData[fieldName] = formattedDate;
          });
        }
      },
      validator: isRequired
          ? (value) => value == null || value.isEmpty ? '$fieldLabel is required' : null
          : null,
    );
  }

  Widget _buildDropdownField(String fieldName, String fieldLabel, List<String> options, bool isRequired) {
    // Only use initial value if it exists in the options list
    final initialValue = _formData[fieldName]?.toString();
    final validInitialValue = (initialValue != null && options.contains(initialValue)) ? initialValue : null;
    
    return DropdownButtonFormField<String>(
      value: validInitialValue,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: '$fieldLabel${isRequired ? ' *' : ''}',
        labelStyle: const TextStyle(
          fontFamily: 'ProductSans',
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: const TextStyle(fontFamily: 'ProductSans'),
          ),
        );
      }).toList(),
      validator: isRequired
          ? (value) => value == null || value.isEmpty ? '$fieldLabel is required' : null
          : null,
      onChanged: (value) => _formData[fieldName] = value,
      onSaved: (value) => _formData[fieldName] = value,
    );
  }

  Widget _buildRadioField(String fieldName, String fieldLabel, List<String> options, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$fieldLabel${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) {
          return RadioListTile<String>(
            activeColor: Colors.black,
            title: Text(
              option,
              style: const TextStyle(fontFamily: 'ProductSans'),
            ),
            value: option,
            groupValue: _formData[fieldName],
            onChanged: (value) {
              setState(() {
                _formData[fieldName] = value;
              });
            },
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ],
    );
  }
}
