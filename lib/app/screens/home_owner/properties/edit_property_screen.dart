import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/home_owner_controller.dart';

class EditPropertyScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _depositController;
  late TextEditingController _holdAmountController;
  late TextEditingController _negotiationMinController;
  late TextEditingController _negotiationMaxController;
  late TextEditingController _videoUrlController;
  late TextEditingController _leaseDurationValueController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;

  late String _selectedCategory;
  late String _selectedPropertyType;
  late String _selectedLeaseDuration;
  late String _selectedPropertyStatus;
  late String _selectedStatus;

  final List<String> _categories = [
    'Apartment',
    'Room',
    'Flatshare',
    'Studio',
    'House',
    'Condo',
    'Townhouse',
  ];

  final List<String> _propertyTypes = [
    'Rent',
    'Lease',
    'Short Stay',
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

  final List<String> _statuses = [
    'Active',
    'Inactive',
    'Closed',
    'Draft',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property['title']);
    _descriptionController = TextEditingController(
      text: widget.property['description'] ?? '',
    );
    
    final location = widget.property['location'];
    _addressController = TextEditingController(
      text: location is Map ? location['address'] : widget.property['address'] ?? '',
    );
    
    // Handle both old and new field names
    _priceController = TextEditingController(
      text: (widget.property['price'] ?? widget.property['rentAmount'])?.toString() ?? '',
    );
    _depositController = TextEditingController(
      text: (widget.property['deposit_amount'] ?? widget.property['holdingAmount'])?.toString() ?? '0',
    );
    _holdAmountController = TextEditingController(
      text: widget.property['hold_amount']?.toString() ?? '0',
    );
    _negotiationMinController = TextEditingController(
      text: widget.property['negotiation_range_min']?.toString() ?? '',
    );
    _negotiationMaxController = TextEditingController(
      text: widget.property['negotiation_range_max']?.toString() ?? '',
    );
    _videoUrlController = TextEditingController(
      text: widget.property['video_url'] ?? '',
    );
    _leaseDurationValueController = TextEditingController(
      text: widget.property['lease_duration_value']?.toString() ?? '1',
    );
    
    final properties = widget.property['properties'];
    _bedroomsController = TextEditingController(
      text: properties is Map ? properties['bedrooms']?.toString() ?? '1' : '1',
    );
    _bathroomsController = TextEditingController(
      text: properties is Map ? properties['bathrooms']?.toString() ?? '1' : '1',
    );

    // Handle both old and new data formats
    final oldPropertyType = widget.property['propertyType'];
    final isOldFormat = oldPropertyType != null && 
        ['Apartment', 'House', 'Duplex', 'Bungalow', 'Flat', 'Studio', 'Penthouse'].contains(oldPropertyType);
    
    if (isOldFormat) {
      // Old format: propertyType was the category
      _selectedCategory = oldPropertyType;
      _selectedPropertyType = 'Rent'; // Default to Rent for old data
    } else {
      // New format
      _selectedCategory = widget.property['category'] ?? 'Apartment';
      _selectedPropertyType = widget.property['propertyType'] ?? 'Rent';
    }
    
    _selectedLeaseDuration = widget.property['lease_duration'] ?? 'Yearly';
    
    // Handle old status field mapping to new property_status
    final oldStatus = widget.property['status'];
    if (oldStatus != null && ['Available', 'Occupied'].contains(oldStatus)) {
      _selectedPropertyStatus = oldStatus;
      _selectedStatus = 'Active'; // Default to Active for old data
    } else {
      _selectedPropertyStatus = widget.property['property_status'] ?? 'Available';
      _selectedStatus = widget.property['status'] ?? 'Draft';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _holdAmountController.dispose();
    _negotiationMinController.dispose();
    _negotiationMaxController.dispose();
    _videoUrlController.dispose();
    _leaseDurationValueController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
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
          onPressed: () => Get.back(),
          child: const Icon(
            CupertinoIcons.back,
            color: Colors.black,
            size: 28,
          ),
        ),
        title: const Text(
          'Edit Property',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'Save',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Form(
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

              // Address
              _buildSectionTitle('Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _addressController,
                hintText: 'Enter full address',
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter property address';
                  }
                  return null;
                },
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
                        _buildTextField(
                          controller: _bedroomsController,
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
                        _buildTextField(
                          controller: _bathroomsController,
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

              // Deposit Amount
              _buildSectionTitle('Deposit Amount (NGN)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _depositController,
                hintText: '90,000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter deposit amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Hold Amount
              _buildSectionTitle('Hold Amount (NGN)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _holdAmountController,
                hintText: '50,000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hold amount';
                  }
                  return null;
                },
              ),

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

              // Status
              _buildSectionTitle('Status'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedStatus,
                items: _statuses,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Video URL (Optional)
              _buildSectionTitle('Video URL (Optional)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _videoUrlController,
                hintText: 'https://youtube.com/...',
                keyboardType: TextInputType.url,
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

              const SizedBox(height: 40),
            ],
          ),
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
      value: value,
      items: items.map((item) {
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<HomeOwnerController>();

      final updates = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'propertyType': _selectedPropertyType,
        'video_url': _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
        'price': double.parse(_priceController.text),
        'negotiation_range_min': _negotiationMinController.text.isNotEmpty 
            ? double.parse(_negotiationMinController.text) 
            : null,
        'negotiation_range_max': _negotiationMaxController.text.isNotEmpty 
            ? double.parse(_negotiationMaxController.text) 
            : null,
        'deposit_amount': double.parse(_depositController.text),
        'hold_amount': double.parse(_holdAmountController.text),
        'lease_duration': _selectedLeaseDuration,
        'lease_duration_value': int.parse(_leaseDurationValueController.text),
        'property_status': _selectedPropertyStatus,
        'status': _selectedStatus,
        'location': {
          'address': _addressController.text,
        },
        'properties': {
          'bedrooms': int.parse(_bedroomsController.text),
          'bathrooms': int.parse(_bathroomsController.text),
        },
      };

      controller.updateProperty(widget.property['id'], updates);
      Get.back();
      Get.snackbar(
        'Success',
        'Property updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xff020202),
        colorText: Colors.white,
      );
    }
  }
}
