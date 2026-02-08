import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PropertyFilterScreen extends StatefulWidget {
  const PropertyFilterScreen({super.key});

  @override
  State<PropertyFilterScreen> createState() => _PropertyFilterScreenState();
}

class _PropertyFilterScreenState extends State<PropertyFilterScreen> {
  // Filter state
  Set<String> selectedCategories = {};
  Set<String> selectedPropertyTypes = {};
  RangeValues priceRange = const RangeValues(0, 5000000);
  String selectedLocation = 'All Locations';
  Set<String> selectedAmenities = {};
  int selectedBedrooms = 0;
  int selectedBathrooms = 0;

  // Filter options
  final List<String> categories = [
    'Apartment',
    'Room',
    'Flatshare',
    'Studio',
    'House',
    'Condo',
    'Townhouse',
  ];

  final List<String> propertyTypes = [
    'Rent',
    'Lease',
    'Short Stay',
  ];

  final List<String> locations = [
    'All Locations',
    'Lekki',
    'Victoria Island',
    'Ikoyi',
    'Yaba',
    'Ikeja',
    'Ajah',
    'Surulere',
  ];

  final List<String> amenities = [
    'Parking',
    'WiFi',
    'Security',
    'Generator',
    'Swimming Pool',
    'Gym',
    'Garden',
    'Balcony',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Filters',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Reset',
              style: TextStyle(
                fontFamily: 'ProductSans',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Category'),
                  _buildCategoryChips(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Property Type'),
                  _buildPropertyTypeChips(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Price Range'),
                  _buildPriceRangeSlider(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Location'),
                  _buildLocationDropdown(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Bedrooms'),
                  _buildBedroomSelector(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Bathrooms'),
                  _buildBathroomSelector(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Amenities'),
                  _buildAmenitiesChips(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'ProductSans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedCategories.add(category);
              } else {
                selectedCategories.remove(category);
              }
            });
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: Colors.black,
          labelStyle: TextStyle(
            fontFamily: 'ProductSans',
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildPropertyTypeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: propertyTypes.map((type) {
        final isSelected = selectedPropertyTypes.contains(type);
        return FilterChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedPropertyTypes.add(type);
              } else {
                selectedPropertyTypes.remove(type);
              }
            });
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: Colors.black,
          labelStyle: TextStyle(
            fontFamily: 'ProductSans',
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      children: [
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 10000000,
          divisions: 100,
          activeColor: Colors.black,
          inactiveColor: Colors.grey.shade300,
          labels: RangeLabels(
            _formatPrice(priceRange.start),
            _formatPrice(priceRange.end),
          ),
          onChanged: (values) {
            setState(() {
              priceRange = values;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatPrice(priceRange.start),
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatPrice(priceRange.end),
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: selectedLocation,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        items: locations.map((location) {
          return DropdownMenuItem(
            value: location,
            child: Text(
              location,
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedLocation = value!;
          });
        },
      ),
    );
  }

  Widget _buildBedroomSelector() {
    return Row(
      children: List.generate(6, (index) {
        final value = index;
        final label = value == 0 ? 'Any' : value == 5 ? '5+' : '$value';
        final isSelected = selectedBedrooms == value;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedBedrooms = value;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBathroomSelector() {
    return Row(
      children: List.generate(5, (index) {
        final value = index;
        final label = value == 0 ? 'Any' : value == 4 ? '4+' : '$value';
        final isSelected = selectedBathrooms == value;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedBathrooms = value;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAmenitiesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.map((amenity) {
        final isSelected = selectedAmenities.contains(amenity);
        return FilterChip(
          label: Text(amenity),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedAmenities.add(amenity);
              } else {
                selectedAmenities.remove(amenity);
              }
            });
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: Colors.black,
          labelStyle: TextStyle(
            fontFamily: 'ProductSans',
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar() {
    final filterCount = _getActiveFilterCount();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (filterCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$filterCount active',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
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
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (selectedCategories.isNotEmpty) count++;
    if (selectedPropertyTypes.isNotEmpty) count++;
    if (priceRange.start > 0 || priceRange.end < 5000000) count++;
    if (selectedLocation != 'All Locations') count++;
    if (selectedBedrooms > 0) count++;
    if (selectedBathrooms > 0) count++;
    if (selectedAmenities.isNotEmpty) count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      selectedCategories.clear();
      selectedPropertyTypes.clear();
      priceRange = const RangeValues(0, 5000000);
      selectedLocation = 'All Locations';
      selectedAmenities.clear();
      selectedBedrooms = 0;
      selectedBathrooms = 0;
    });
  }

  void _applyFilters() {
    final filters = {
      'categories': selectedCategories.toList(),
      'propertyTypes': selectedPropertyTypes.toList(),
      'priceRange': {'min': priceRange.start, 'max': priceRange.end},
      'location': selectedLocation,
      'bedrooms': selectedBedrooms,
      'bathrooms': selectedBathrooms,
      'amenities': selectedAmenities.toList(),
    };
    
    Get.back(result: filters);
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return 'NGN${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return 'NGN${(price / 1000).toStringAsFixed(0)}K';
    } else {
      return 'NGN${price.toStringAsFixed(0)}';
    }
  }
}
