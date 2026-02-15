import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../controllers/user_profile_controller.dart';
import '../../../services/account_status_service.dart';
import '../../../services/dio_client.dart';
import '../../../widgets/skeleton_loader.dart';

class PersonalInformationScreen extends StatefulWidget {
  final bool isEditMode;

  const PersonalInformationScreen({super.key, this.isEditMode = false});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditMode;
  late UserProfileController _profileController;

  // Controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ninController = TextEditingController();
  final _bioController = TextEditingController();

  // Biodata (from misc/datafields/biodata + user/profile)
  List<Map<String, dynamic>> _biodataFields = [];
  final Map<String, dynamic> _biodataValues = {};
  final Map<String, TextEditingController> _biodataControllers = {};
  bool _biodataFieldsLoading = true;
  String? _biodataFieldsError;

  static const List<String> _defaultIncomeRangeOptions = [
    'Below NGN50,000',
    'NGN50,000 - NGN100,000',
    'NGN100,000 - NGN200,000',
    'NGN200,000 - NGN500,000',
    'NGN500,000 - NGN1,000,000',
    'Above NGN1,000,000',
  ];

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditMode;

    // Initialize or get existing controller
    if (Get.isRegistered<UserProfileController>()) {
      _profileController = Get.find<UserProfileController>();
    } else {
      _profileController = Get.put(UserProfileController());
    }

    // Load profile data into controllers
    _loadProfileData();
    _loadBiodataFieldsAndProfile();
  }

  Future<void> _loadBiodataFields() async {
    setState(() {
      _biodataFieldsLoading = true;
      _biodataFieldsError = null;
    });
    try {
      final res = await DioClient.get('misc/datafields/biodata');
      final data = res['data'];
      if (data != null && data is List) {
        _biodataFields = [];
        for (var raw in data) {
          final m = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
          final skey = m['sKey']?.toString() ?? m['skey']?.toString();
          if (skey == null || skey.isEmpty) continue;
          _biodataFields.add({
            'skey': skey,
            'name': m['name']?.toString(),
            'value': m['value']?.toString(),
            'description': m['description']?.toString(),
            'fieldDataType': m['fieldDataType']?.toString() ?? 'text',
            'isRequired': m['isRequired'] == true,
            'sortOrder': m['sortOrder'] is num ? (m['sortOrder'] as num).toInt() : 0,
          });
        }
        _biodataFields.sort((a, b) => ((a['sortOrder'] ?? 0) as int).compareTo((b['sortOrder'] ?? 0) as int));
        for (var field in _biodataFields) {
          final skey = field['skey']?.toString();
          final dataType = field['fieldDataType']?.toString() ?? 'text';
          if (skey != null && skey.isNotEmpty && (dataType == 'text' || dataType == 'number')) {
            _biodataControllers[skey] = TextEditingController();
          }
        }
        _biodataFieldsError = null;
      }
    } catch (e) {
      _biodataFieldsError = e.toString().replaceAll('Exception: ', '');
    }
    if (mounted) setState(() => _biodataFieldsLoading = false);
  }

  Future<void> _loadBiodataFieldsAndProfile() async {
    await _loadBiodataFields();
    await _loadBiodataFromProfile();
  }

  void _applyBioDataToForm(Map<String, dynamic> bioData) {
    for (var e in bioData.entries) {
      final key = e.key.toString();
      final value = e.value;
      _biodataValues[key] = value;
      final c = _biodataControllers[key];
      if (c != null) c.text = value?.toString() ?? '';
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadBiodataFromProfile() async {
    Map<String, dynamic>? bioData;

    // 1. Try GET /user/profile (AccountStatusService)
    try {
      final profileRes = await AccountStatusService.getProfile();
      final data = profileRes['data'];
      if (data is Map) {
        if (data['bioData'] is Map) {
          bioData = Map<String, dynamic>.from(data['bioData'] as Map);
        } else if (data['user'] is Map && (data['user'] as Map)['bioData'] is Map) {
          bioData = Map<String, dynamic>.from((data['user'] as Map)['bioData'] as Map);
        } else if (data['biodataRecord'] is Map && (data['biodataRecord'] as Map)['bioData'] is Map) {
          bioData = Map<String, dynamic>.from((data['biodataRecord'] as Map)['bioData'] as Map);
        }
      }
    } catch (_) {
      // 2. Fallback: use cached profile from UserProfileController (e.g. when API returns 404)
      final cached = _profileController.userProfile;
      if (cached['bioData'] is Map) {
        bioData = Map<String, dynamic>.from(cached['bioData'] as Map);
      } else if (cached['biodataRecord'] is Map && (cached['biodataRecord'] as Map)['bioData'] is Map) {
        bioData = Map<String, dynamic>.from((cached['biodataRecord'] as Map)['bioData'] as Map);
      }
    }

    if (bioData != null && bioData.isNotEmpty) {
      _applyBioDataToForm(bioData);
    }
  }

  void _loadProfileData() {
    final profile = _profileController.userProfile;

    print('📋 Loading profile data into form fields...');
    print('Profile data: $profile');

    // Load individual name fields
    _firstNameController.text = profile['firstName']?.toString() ?? '';
    _middleNameController.text = profile['middleName']?.toString() ?? '';
    _lastNameController.text = profile['lastName']?.toString() ?? '';

    _emailController.text = profile['email']?.toString() ?? '';
    _phoneController.text = profile['phone']?.toString() ?? '';
    _ninController.text = profile['nin']?.toString() ?? '';
    _bioController.text = ''; // Bio not in API response

    print('✅ Form fields loaded:');
    print('  First Name: ${_firstNameController.text}');
    print('  Middle Name: ${_middleNameController.text}');
    print('  Last Name: ${_lastNameController.text}');
    print('  Email: ${_emailController.text}');
    print('  Phone: ${_phoneController.text}');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ninController.dispose();
    _bioController.dispose();
    for (var c in _biodataControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      // Clear selected image when canceling edit
      if (!_isEditMode) {
        _selectedImage = null;
      }
    });
  }

  Future<bool> _requestPermission(Permission permission) async {
    // Check current status first
    var status = await permission.status;

    print('📋 Permission status for $permission: $status');

    // If already granted, return true
    if (status.isGranted) {
      return true;
    }

    // If permanently denied, show settings dialog
    if (status.isPermanentlyDenied) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Permission Required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ProductSans',
                ),
              ),
              content: Text(
                'This app needs ${permission == Permission.camera ? 'camera' : 'photo library'} access to update your profile picture. Please grant permission in settings.',
                style: const TextStyle(fontFamily: 'ProductSans'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontFamily: 'ProductSans'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Open Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
              ],
            ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      return false;
    }

    // Request permission
    status = await permission.request();
    print('📋 Permission status after request: $status');

    return status.isGranted;
  }

  Future<void> _pickImage() async {
    try {
      // Show options: Camera or Gallery
      final source = await showModalBottomSheet<ImageSource>(
        backgroundColor: Colors.white,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder:
            (context) => Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose Profile Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text(
                      'Take Photo',
                      style: TextStyle(fontFamily: 'ProductSans'),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text(
                      'Choose from Gallery',
                      style: TextStyle(fontFamily: 'ProductSans'),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
      );

      if (source == null) return;

      // Request appropriate permission
      bool hasPermission = false;
      if (source == ImageSource.camera) {
        hasPermission = await _requestPermission(Permission.camera);
      } else {
        // For gallery, request photos permission
        if (Platform.isAndroid) {
          // Android 13+ uses READ_MEDIA_IMAGES
          if (await Permission.photos.request().isGranted) {
            hasPermission = true;
          } else {
            hasPermission = await _requestPermission(Permission.storage);
          }
        } else {
          hasPermission = await _requestPermission(Permission.photos);
        }
      }

      if (!hasPermission) {
        print('⚠️ Permission not granted, cannot proceed');
        return;
      }

      // Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Upload image immediately
        await _uploadProfilePhoto();
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadProfilePhoto() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // TODO: Implement actual image upload to your server/cloud storage
      // For now, we'll simulate an upload and use a placeholder URL

      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, you would:
      // 1. Upload image to cloud storage (e.g., AWS S3, Cloudinary, Firebase Storage)
      // 2. Get the public URL
      // 3. Update profile with the URL

      final imageUrl =
          'https://example.com/profile-photos/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Update profile with new photo URL
      await _profileController.updateProfile(profilePhoto: imageUrl);

      Get.snackbar(
        'Success',
        'Profile photo updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error uploading image: $e');
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Map<String, dynamic> _buildBioDataPayload() {
    final bioData = <String, dynamic>{};
    for (var e in _biodataValues.entries) {
      final key = e.key.toString();
      final v = e.value;
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isEmpty) continue;
      if (key == 'age') {
        final n = int.tryParse(s);
        if (n != null) {
          bioData[key] = n;
        } else {
          bioData[key] = s;
        }
      } else if (key == 'dob') {
        bioData[key] = s.length >= 10 ? s.substring(0, 10) : s;
      } else {
        bioData[key] = v;
      }
    }
    for (var e in _biodataControllers.entries) {
      final txt = e.value.text.trim();
      if (txt.isNotEmpty && !bioData.containsKey(e.key)) {
        bioData[e.key] = txt;
      }
    }
    return bioData;
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final middleName = _middleNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      // Update basic profile
      await _profileController.updateProfile(
        firstName: firstName.isNotEmpty ? firstName : null,
        middleName: middleName.isNotEmpty ? middleName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
      );

      // Update biodata via PATCH /user/update
      final bioData = _buildBioDataPayload();
      if (bioData.isNotEmpty) {
        try {
          await AccountStatusService.updateUserProfile({'bioData': bioData});
          _profileController.fetchUserProfile();
        } catch (e) {
          Get.snackbar(
            'Error',
            e.toString().replaceAll('Exception: ', ''),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      setState(() {
        _isEditMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show skeleton loader while loading
      if (_profileController.isLoading.value &&
          _profileController.userProfile.isEmpty) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Get.back(),
              padding: const EdgeInsets.only(left: 18),
            ),
            centerTitle: true,
            title: const Text(
              'Personal Information',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'ProductSans',
              ),
            ),
          ),
          body: const PersonalInfoSkeletonLoader(),
        );
      }

      // Reload data when profile changes
      if (_profileController.userProfile.isNotEmpty && !_isEditMode) {
        _loadProfileData();
      }

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Get.back(),
                  padding: const EdgeInsets.only(left: 18),
                ),
                centerTitle: true,
                title: const Text(
                  'Personal Information',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ProductSans',
                  ),
                ),
                actions: [
                  if (!_isEditMode)
                    TextButton(
                      onPressed: _toggleEditMode,
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.06,
                    vertical: Get.height * 0.02,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFFB6C1),
                                  border:
                                      _isUploadingImage
                                          ? Border.all(
                                            color: Colors.blue,
                                            width: 3,
                                          )
                                          : null,
                                ),
                                child: ClipOval(
                                  child:
                                      _selectedImage != null
                                          ? Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          )
                                          : (_profileController
                                                  .profilePhoto
                                                  .isNotEmpty
                                              ? Image.network(
                                                _profileController.profilePhoto,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return _buildPlaceholderAvatar();
                                                },
                                              )
                                              : _buildPlaceholderAvatar()),
                                ),
                              ),
                              if (_isUploadingImage)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black54,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_isEditMode && !_isUploadingImage)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: Get.height * 0.04),

                        // First Name
                        _buildTextField(
                          label: 'First Name *',
                          controller: _firstNameController,
                          enabled: _isEditMode,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: Get.height * 0.02),

                        // Middle Name
                        _buildTextField(
                          label: 'Middle Name (Optional)',
                          controller: _middleNameController,
                          enabled: _isEditMode,
                        ),

                        SizedBox(height: Get.height * 0.02),

                        // Last Name
                        _buildTextField(
                          label: 'Last Name *',
                          controller: _lastNameController,
                          enabled: _isEditMode,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: Get.height * 0.02),

                        // Email
                        _buildTextField(
                          label: 'Email *',
                          controller: _emailController,
                          enabled: _isEditMode,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!GetUtils.isEmail(value.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: Get.height * 0.02),

                        // Phone Number (Read-only)
                        _buildTextField(
                          label: 'Phone Number *',
                          controller: _phoneController,
                          enabled: false,
                          keyboardType: TextInputType.phone,
                          suffixIcon: const Icon(
                            Icons.check_circle,
                            color: Color(0xff29BCA2),
                          ),
                        ),

                        SizedBox(height: Get.height * 0.02),

                        // NIN (Read-only)
                        _buildTextField(
                          label: 'National Identification Number (NIN) *',
                          controller: _ninController,
                          enabled: false,
                          keyboardType: TextInputType.number,
                          suffixIcon: const Icon(
                            Icons.verified,
                            color: Color(0xff29BCA2),
                          ),
                        ),

                        SizedBox(height: Get.height * 0.03),

                        // Biodata section
                        const Text(
                          'Additional Information',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: Get.height * 0.02),
                        ..._buildBiodataFields(),

                        SizedBox(height: Get.height * 0.04),

                        // Save Button (only visible in edit mode)
                        if (_isEditMode)
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 70,
                                child: ElevatedButton(
                                  onPressed: _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: Get.width * 0.055,
                                      fontFamily: 'ProductSans',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 70,
                                child: OutlinedButton(
                                  onPressed: _toggleEditMode,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: Get.width * 0.055,
                                      fontFamily: 'ProductSans',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        SizedBox(height: Get.height * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (_profileController.isLoading.value)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization:
          maxLines > 1
              ? TextCapitalization.sentences
              : TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'ProductSans',
          color: enabled ? Colors.grey : Colors.grey[600],
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF8F8F8) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  List<Widget> _buildBiodataFields() {
    if (_biodataFieldsLoading) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ];
    }
    if (_biodataFieldsError != null) {
      return [
        Text(
          _biodataFieldsError!,
          style: TextStyle(color: Colors.red[700], fontSize: 14, fontFamily: 'ProductSans'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _loadBiodataFields,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Retry', style: TextStyle(fontFamily: 'ProductSans')),
        ),
      ];
    }
    return _biodataFields.map((field) {
      final skey = field['skey']?.toString() ?? '';
      final fieldType = field['fieldDataType']?.toString() ?? 'text';
      final isRequired = field['isRequired'] == true;
      if (skey.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: Get.height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  field['name']?.toString() ?? skey,
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isRequired) const Text(' *', style: TextStyle(color: Colors.red)),
              ],
            ),
            if (field['description']?.toString().isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                field['description'].toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontFamily: 'ProductSans'),
              ),
            ],
            const SizedBox(height: 8),
            if (fieldType == 'select')
              _buildBiodataDropdown(field, skey)
            else if (fieldType == 'date')
              _buildBiodataDatePicker(field, skey)
            else
              _buildBiodataTextField(field, skey),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildBiodataTextField(dynamic field, String fieldKey) {
    final controller = _biodataControllers[fieldKey];
    if (controller == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          _biodataValues[fieldKey]?.toString() ?? '',
          style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
        ),
      );
    }
    return TextFormField(
      controller: controller,
      enabled: _isEditMode,
      onChanged: (value) {
        _biodataValues[fieldKey] = value;
      },
      decoration: InputDecoration(
        hintText: 'Enter ${field['name'] ?? fieldKey}',
        hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'ProductSans'),
        filled: true,
        fillColor: _isEditMode ? const Color(0xFFF8F8F8) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
    );
  }

  Widget _buildBiodataDropdown(dynamic field, String fieldKey) {
    final value = _biodataValues[fieldKey]?.toString();
    List<String> options = (field['value']?.toString() ?? '')
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.trim())
        .toList();
    if (fieldKey == 'incomeRange' && options.isEmpty) {
      options = List.from(_defaultIncomeRangeOptions);
    }
    final label = field['name']?.toString() ?? fieldKey;
    if (options.isEmpty) {
      return _buildTextField(
        label: '',
        controller: TextEditingController(text: value ?? ''),
        enabled: false,
      );
    }
    return DropdownButtonFormField<String>(
      value: value != null && options.contains(value) ? value : null,
      hint: Text('Select $label', style: const TextStyle(fontFamily: 'ProductSans')),
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontFamily: 'ProductSans')))).toList(),
      onChanged: _isEditMode ? (v) => setState(() => _biodataValues[fieldKey] = v) : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: _isEditMode ? const Color(0xFFF8F8F8) : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16, color: Colors.black),
    );
  }

  Widget _buildBiodataDatePicker(dynamic field, String fieldKey) {
    final value = _biodataValues[fieldKey];
    String displayDate = 'Select date';
    if (value != null && value.toString().trim().isNotEmpty) {
      try {
        displayDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(value.toString()));
      } catch (_) {}
    }
    return InkWell(
      onTap: _isEditMode
          ? () async {
              DateTime initial = DateTime.now();
              if (value != null && value.toString().trim().isNotEmpty) {
                try {
                  initial = DateTime.parse(value.toString());
                } catch (_) {}
              }
              final date = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _biodataValues[fieldKey] = date.toIso8601String());
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isEditMode ? const Color(0xFFF8F8F8) : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Text(displayDate, style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Image.asset(
      'assets/image/profile_placeholder.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFFFB6C1),
          child: const Icon(Icons.person, size: 50, color: Colors.white),
        );
      },
    );
  }
}
