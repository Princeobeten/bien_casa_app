import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../controllers/flatmate_match_controller.dart';
import '../_widgets/flat_card.dart';

class FlatsPage extends StatefulWidget {
  const FlatsPage({super.key});

  @override
  State<FlatsPage> createState() => _FlatsPageState();
}

class _FlatsPageState extends State<FlatsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Studio', '1 Bedroom', '2 Bedroom', '3+ Bedroom'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredFlats(FlatmateMatchController controller) {
    List<Map<String, dynamic>> flats = controller.flats.toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      flats = flats.where((flat) {
        final name = flat['name']?.toString().toLowerCase() ?? '';
        final location = flat['location']?.toString().toLowerCase() ?? '';
        final address = flat['address']?.toString().toLowerCase() ?? '';
        final description = flat['description']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) || 
               location.contains(query) || 
               address.contains(query) ||
               description.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      flats = flats.where((flat) {
        final bedrooms = flat['bedrooms']?.toString() ?? '';
        switch (_selectedFilter) {
          case 'Studio':
            return bedrooms == '0' || bedrooms.toLowerCase().contains('studio');
          case '1 Bedroom':
            return bedrooms == '1';
          case '2 Bedroom':
            return bedrooms == '2';
          case '3+ Bedroom':
            return int.tryParse(bedrooms) != null && int.parse(bedrooms) >= 3;
          default:
            return true;
        }
      }).toList();
    }

    return flats;
  }

  @override
  Widget build(BuildContext context) {
    // Get the controller to access flat data
    final controller = Get.find<FlatmateMatchController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'All Flats',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Search bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search flats...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontFamily: 'ProductSans',
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: const Color(0xFFF8F8F8),
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Headline for the page
            const Text(
              'Browse available flat perfect for your flatmate by budget, location, interest etc.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                fontFamily: 'ProductSans',
                color: Color(0xff6B6B6B),
              ),
            ),

            const SizedBox(height: 16),

            // Flats grid view
            Expanded(
              child: Obx(() {
                final filteredFlats = _getFilteredFlats(controller);
                
                if (filteredFlats.isEmpty) {
                  return _buildEmptyState();
                }
                
                return _buildFlatsGrid(filteredFlats);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Grid view of flat listings
  Widget _buildFlatsGrid(List<Map<String, dynamic>> flats) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Taller than wide
      ),
      itemCount: flats.length,
      itemBuilder: (context, index) {
        final flat = flats[index];
        return FlatCard(flat: flat);
      },
    );
  }

  // Empty state when no flats are available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/home.svg', // Replace with appropriate icon
            width: 80,
            height: 80,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Flats Available',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'We\'ll add more flats soon.\nCheck back later!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'ProductSans',
            ),
          ),
        ],
      ),
    );
  }
}
