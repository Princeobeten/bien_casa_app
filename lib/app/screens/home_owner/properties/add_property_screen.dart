import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import '../../../controllers/home_owner_controller.dart';
import '../../../config/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _negotiationMinController = TextEditingController();
  final _negotiationMaxController = TextEditingController();
  final _leaseDurationValueController = TextEditingController(text: '1');
  final _holdDaysController = TextEditingController();

  // Multi-step form state
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  String _selectedCategory = 'Apartment';
  String _selectedSubCategory = 'Studio';
  String _selectedPropertyType = 'Rent';
  String _selectedLeaseDuration = 'Yearly';
  String _selectedPropertyStatus = 'Available';
  bool _enableHold = false;
  int _bedrooms = 1;
  int _bathrooms = 1;
  List<String> _selectedAmenities = [];
  
  // Step 2: Media
  List<File> _propertyPhotos = [];
  File? _propertyVideo;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Step 3: Geo-location
  double? _latitude;
  double? _longitude;
  gmaps.GoogleMapController? _mapController;
  Set<gmaps.Marker> _markers = {};
  final _locationSearchController = TextEditingController();
  
  // Google Places
  late FlutterGooglePlacesSdk _places;
  List<AutocompletePrediction> _placePredictions = [];
  bool _isSearchingPlaces = false;
  
  // Computed hold amount
  double get _calculatedHoldAmount {
    if (!_enableHold || _priceController.text.isEmpty || _holdDaysController.text.isEmpty) {
      return 0;
    }
    final price = double.tryParse(_priceController.text) ?? 0;
    final days = int.tryParse(_holdDaysController.text) ?? 0;
    return (price / 100 * 10 / 30) * days;
  }
  
  @override
  void initState() {
    super.initState();
    // Initialize Google Places with API key from AppConstants
    _places = FlutterGooglePlacesSdk(AppConstants.googleMapsApiKey);
    
    // Add listeners to update hold amount when price or days change
    _priceController.addListener(() {
      if (_enableHold) {
        setState(() {});
      }
    });
    _holdDaysController.addListener(() {
      if (_enableHold) {
        setState(() {});
      }
    });
  }

  final List<String> _categories = [
    'Apartment',
    'Room',
    'Flatshare',
    'House',
    'Condo',
    'Townhouse',
  ];
  
  final Map<String, List<String>> _subCategories = {
    'Apartment': ['Studio', '1 Bedroom', '2 Bedroom', '3 Bedroom', 'Penthouse'],
    'Room': ['Single Room', 'Shared Room', 'Master Room', 'En-suite'],
    'Flatshare': ['2 Bedroom Shared', '3 Bedroom Shared', '4 Bedroom Shared'],
    'House': ['Bungalow', 'Duplex', 'Detached', 'Semi-Detached', 'Terrace'],
    'Condo': ['Studio Condo', '1 Bedroom Condo', '2 Bedroom Condo', 'Luxury Condo'],
    'Townhouse': ['2 Story', '3 Story', 'End Unit', 'Middle Unit'],
  };

  final List<String> _propertyTypes = [
    'Rent',
    'Lease',
    'Service Apartment',
  ];

  final List<String> _leaseDurations = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  final List<String> _propertyStatuses = [
    'Available',
    'Occupied',
    'Under Maintenance',
    'Inactive',
  ];

  // Removed - Status will be Draft by default, can be changed to Active/Inactive later

  final List<String> _availableAmenities = [
    'Security',
    'Parking',
    'Generator',
    'Water Supply',
    'Internet',
    'Swimming Pool',
    'Gym',
    'Garden',
    'Elevator',
    'Air Conditioning',
    'Furnished',
    'Balcony',
  ];

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _placePredictions = [];
      });
      return;
    }

    setState(() {
      _isSearchingPlaces = true;
    });

    try {
      final predictions = await _places.findAutocompletePredictions(
        query,
        countries: ['NG'], // Restrict to Nigeria
      );
      
      setState(() {
        _placePredictions = predictions.predictions;
        _isSearchingPlaces = false;
      });
    } catch (e) {
      print('Error searching places: $e');
      setState(() {
        _isSearchingPlaces = false;
      });
    }
  }

  void _selectAddressPlace(AutocompletePrediction prediction) {
    setState(() {
      _addressController.text = prediction.fullText;
      _placePredictions = [];
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _negotiationMinController.dispose();
    _negotiationMaxController.dispose();
    _leaseDurationValueController.dispose();
    _holdDaysController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _currentStep > 0 ? _previousStep : () => Get.back(),
          child: Icon(
            _currentStep > 0 ? CupertinoIcons.back : CupertinoIcons.xmark,
            color: Colors.black,
            size: 28,
          ),
        ),
        title: Text(
          _currentStep == 0 ? 'Property Details' : 
          _currentStep == 1 ? 'Media Upload' : 'Location',
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          if (_currentStep == 0)
            TextButton(
              onPressed: _saveDraft,
              child: const Text(
                'Save Draft',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(),
          
          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1PropertyDetails(),
                _buildStep2MediaUpload(),
                _buildStep3Location(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive ? Colors.black : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1PropertyDetails() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Title
            _buildSectionTitle('Property Title'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hintText: 'e.g., Modern 3BR Apartment',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter property title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Category
              _buildSectionTitle('Category'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedCategory,
                items: _categories,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    // Reset subcategory when category changes
                    _selectedSubCategory = _subCategories[value]!.first;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Sub-Category
              _buildSectionTitle('Sub-Category'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedSubCategory,
                items: _subCategories[_selectedCategory]!,
                onChanged: (value) {
                  setState(() {
                    _selectedSubCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Property Type
              _buildSectionTitle('Property Type'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedPropertyType,
                items: _propertyTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedPropertyType = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Address with Google Places Autocomplete
              _buildSectionTitle('Address'),
              const SizedBox(height: 8),
              Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    onChanged: (value) {
                      _searchPlaces(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter property address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for address...',
                      hintStyle: TextStyle(
                        fontFamily: 'ProductSans',
                        color: Colors.grey[500],
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: _isSearchingPlaces
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : const Icon(Icons.location_on, color: Colors.grey),
                    ),
                    style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
                  ),
                  if (_placePredictions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _placePredictions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey[200],
                        ),
                        itemBuilder: (context, index) {
                          final prediction = _placePredictions[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 20,
                            ),
                            title: Text(
                              prediction.primaryText,
                              style: const TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              prediction.secondaryText,
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            onTap: () => _selectAddressPlace(prediction),
                          );
                        },
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Bedrooms and Bathrooms
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Bedrooms'),
                        const SizedBox(height: 8),
                        _buildCounterField(
                          value: _bedrooms,
                          onChanged: (value) {
                            setState(() {
                              _bedrooms = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Bathrooms'),
                        const SizedBox(height: 8),
                        _buildCounterField(
                          value: _bathrooms,
                          onChanged: (value) {
                            setState(() {
                              _bathrooms = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Price
              _buildSectionTitle('Price (NGN)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _priceController,
                hintText: '450,000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Negotiation Range
              _buildSectionTitle('Negotiation Range (Optional)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _negotiationMinController,
                      hintText: 'Min',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _negotiationMaxController,
                      hintText: 'Max',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Enable Hold Option
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Enable Property Hold'),
                        const SizedBox(height: 4),
                        Text(
                          'Allow tenants to hold this property',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enableHold,
                    onChanged: (value) {
                      setState(() {
                        _enableHold = value;
                      });
                    },
                    activeColor: Colors.black,
                  ),
                ],
              ),

              if (_enableHold) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Number of Hold Days'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _holdDaysController,
                  hintText: 'e.g., 7, 14, 30',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (_enableHold && (value == null || value.isEmpty)) {
                      return 'Please enter number of days';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hold Amount:',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        'NGN ${_calculatedHoldAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Lease Duration
              _buildSectionTitle('Lease Duration'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _leaseDurationValueController,
                      hintText: '1',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildDropdown(
                      value: _selectedLeaseDuration,
                      items: _leaseDurations,
                      onChanged: (value) {
                        setState(() {
                          _selectedLeaseDuration = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Property Status
              _buildSectionTitle('Property Status'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedPropertyStatus,
                items: _propertyStatuses,
                onChanged: (value) {
                  setState(() {
                    _selectedPropertyStatus = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Description
              _buildSectionTitle('Description'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Describe your property...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter property description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Amenities
              _buildSectionTitle('Amenities'),
              const SizedBox(height: 12),
              _buildAmenitiesGrid(),

              const SizedBox(height: 40),
              
              // Navigation Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Next: Media Upload',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'ProductSans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'ProductSans',
          color: Colors.grey[500],
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
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
      items:
          items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontFamily: 'ProductSans'),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildCounterField({
    required int value,
    required void Function(int) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
            color: value > 1 ? Colors.black : Colors.grey,
          ),
          Expanded(
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add),
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _availableAmenities.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAmenities.remove(amenity);
                  } else {
                    _selectedAmenities.add(amenity);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  amenity,
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // PHASE 5: Media Upload Methods
  Future<void> _addPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _propertyPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _propertyPhotos.removeAt(index);
    });
  }

  Future<void> _addVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      
      if (video != null) {
        setState(() {
          _propertyVideo = File(video.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick video: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _removeVideo() {
    setState(() {
      _propertyVideo = null;
    });
  }

  Widget _buildStep2MediaUpload() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Property Photos'),
          const SizedBox(height: 8),
          Text(
            'Upload at least 4 photos (maximum unlimited)',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _propertyPhotos.length + 1,
            itemBuilder: (context, index) {
              if (index == _propertyPhotos.length) {
                return _buildAddPhotoCard();
              }
              return _buildPhotoCard(_propertyPhotos[index], index);
            },
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Property Video (Optional)'),
          const SizedBox(height: 8),
          Text(
            'Upload one video to showcase your property (max 2 minutes)',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _propertyVideo == null
              ? _buildAddVideoCard()
              : _buildVideoCard(_propertyVideo!),
          const SizedBox(height: 40),
          
          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Next: Location',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(File photo, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(photo),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Cover',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddVideoCard() {
    return GestureDetector(
      onTap: _addVideo,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, size: 32, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Add Video',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(File video) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeVideo,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PHASE 6: Geo-location Methods
  Widget _buildStep3Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Property Location'),
          const SizedBox(height: 8),
          Text(
            'Search for your address or tap on the map',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Address Search Bar
          TextField(
            controller: _locationSearchController,
            decoration: InputDecoration(
              hintText: 'Search address...',
              hintStyle: TextStyle(
                fontFamily: 'ProductSans',
                color: Colors.grey[500],
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _locationSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _locationSearchController.clear();
                          _placePredictions = [];
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: _searchLocation,
            style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
          ),
          
          // Search Results
          if (_placePredictions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _placePredictions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final prediction = _placePredictions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.grey),
                    title: Text(
                      prediction.primaryText,
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      prediction.secondaryText,
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () => _selectPlace(prediction),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: gmaps.GoogleMap(
                initialCameraPosition: gmaps.CameraPosition(
                  target: _latitude != null && _longitude != null
                      ? gmaps.LatLng(_latitude!, _longitude!)
                      : const gmaps.LatLng(14.5995, 120.9842), // Manila default
                  zoom: 15,
                ),
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onTap: _onMapTapped,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_latitude != null && _longitude != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location pinned: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Use Current Location'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          const SizedBox(height: 40),
          
          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _publishProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Publish Property',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _onMapTapped(gmaps.LatLng position) {
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _markers = {
        gmaps.Marker(
          markerId: const gmaps.MarkerId('property_location'),
          position: position,
          infoWindow: const gmaps.InfoWindow(title: 'Property Location'),
        ),
      };
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _placePredictions = [];
      });
      return;
    }

    setState(() {
      _isSearchingPlaces = true;
    });

    try {
      final predictions = await _places.findAutocompletePredictions(
        query,
        countries: ['NG'], // Restrict to Nigeria
      );
      
      setState(() {
        _placePredictions = predictions.predictions;
        _isSearchingPlaces = false;
      });
    } catch (e) {
      print('Error searching location: $e');
      setState(() {
        _isSearchingPlaces = false;
        _placePredictions = [];
      });
    }
  }

  Future<void> _selectPlace(AutocompletePrediction prediction) async {
    try {
      // Fetch place details to get coordinates
      final place = await _places.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.Location, PlaceField.Address],
      );

      if (place.place?.latLng != null) {
        final location = place.place!.latLng!;
        
        setState(() {
          _latitude = location.lat;
          _longitude = location.lng;
          _locationSearchController.text = prediction.fullText;
          _placePredictions = [];
          _markers = {
            gmaps.Marker(
              markerId: const gmaps.MarkerId('property_location'),
              position: gmaps.LatLng(location.lat, location.lng),
              infoWindow: gmaps.InfoWindow(title: prediction.primaryText),
            ),
          };
        });

        // Animate camera to the selected location
        _mapController?.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(
            gmaps.LatLng(location.lat, location.lng),
            16,
          ),
        );
      }
    } catch (e) {
      print('Error selecting place: $e');
      Get.snackbar(
        'Error',
        'Failed to get location details',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is required',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _markers = {
          gmaps.Marker(
            markerId: const gmaps.MarkerId('property_location'),
            position: gmaps.LatLng(position.latitude, position.longitude),
            infoWindow: const gmaps.InfoWindow(title: 'Property Location'),
          ),
        };
      });

      _mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // PHASE 7: Navigation & Submit Methods
  void _nextStep() {
    // No validation - allow free navigation for testing
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }



  void _saveDraft() {
    _submitProperty(isDraft: true);
  }

  void _publishProperty() {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please complete all required fields in Step 1',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_propertyPhotos.length < 4) {
      Get.snackbar(
        'Validation Error',
        'Please upload at least 4 photos',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_latitude == null || _longitude == null) {
      Get.snackbar(
        'Validation Error',
        'Please pin your property location on the map',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    _submitProperty(isDraft: false);
  }

  void _submitProperty({bool isDraft = false}) {
    final controller = Get.find<HomeOwnerController>();

    // Convert File paths to strings for storage
    final photoUrls = _propertyPhotos.map((file) => file.path).toList();
    final videoUrl = _propertyVideo?.path;

    final property = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'subCategory': _selectedSubCategory,
      'propertyType': _selectedPropertyType,
      'photos': photoUrls,
      'video': videoUrl,
      'price': double.parse(_priceController.text),
      'negotiation_range_min': _negotiationMinController.text.isNotEmpty 
          ? double.parse(_negotiationMinController.text) 
          : null,
      'negotiation_range_max': _negotiationMaxController.text.isNotEmpty 
          ? double.parse(_negotiationMaxController.text) 
          : null,
      'enable_hold': _enableHold,
      'hold_days': _enableHold && _holdDaysController.text.isNotEmpty
          ? int.parse(_holdDaysController.text)
          : null,
      'hold_amount': _enableHold ? _calculatedHoldAmount : null,
      'lease_duration': _selectedLeaseDuration,
      'lease_duration_value': int.parse(_leaseDurationValueController.text),
      'property_status': _selectedPropertyStatus,
      'application_status': 'Pending',
      'status': isDraft ? 'Draft' : 'Active',
      'location': {
        'address': _addressController.text,
        'latitude': _latitude,
        'longitude': _longitude,
      },
      'properties': {
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
        'amenities': _selectedAmenities,
      },
      'views_count': 0,
      'favorites_count': 0,
    };

    controller.addProperty(property);

    Get.back();
    Get.snackbar(
      'Success',
      isDraft ? 'Property saved as Draft' : 'Property published successfully!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xff020202),
      colorText: Colors.white,
    );
  }
}
