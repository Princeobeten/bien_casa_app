import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/home_owner_controller.dart';
import 'property_detail_screen.dart';

class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({super.key});

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, HomeOwnerController controller) {
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      final results =
          controller.properties.where((property) {
            final title = property['title'].toString().toLowerCase();
            final address = property['address'].toString().toLowerCase();
            final type = property['propertyType'].toString().toLowerCase();
            final status = property['status'].toString().toLowerCase();
            final searchLower = query.toLowerCase();

            return title.contains(searchLower) ||
                address.contains(searchLower) ||
                type.contains(searchLower) ||
                status.contains(searchLower);
          }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeOwnerController>(
      builder: (controller) {
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
              'Search Properties',
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
              // Search Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => _performSearch(value, controller),
                  decoration: InputDecoration(
                    hintText: 'Search by title, address, type, or status...',
                    hintStyle: TextStyle(
                      fontFamily: 'ProductSans',
                      color: Colors.grey[500],
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('', controller);
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
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 16,
                  ),
                ),
              ),

              // Search Results
              Expanded(child: _buildSearchContent(controller)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchContent(HomeOwnerController controller) {
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions(controller);
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchSuggestions(HomeOwnerController controller) {
    final recentSearches = [
      'Available properties',
      'Occupied properties',
      'Apartment',
      'House',
    ];
    final quickFilters = [
      {'title': 'Available Properties', 'filter': 'Available'},
      {'title': 'Occupied Properties', 'filter': 'Occupied'},
      {'title': 'Under Maintenance', 'filter': 'Under Maintenance'},
      {'title': 'Apartments', 'filter': 'Apartment'},
      {'title': 'Houses', 'filter': 'House'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Filters
          const Text(
            'Quick Filters',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                quickFilters.map((filter) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = filter['filter']!;
                      _performSearch(filter['filter']!, controller);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        filter['title']!,
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 32),

          // Recent Searches
          const Text(
            'Recent Searches',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...recentSearches.map((search) {
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(
                search,
                style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
              ),
              onTap: () {
                _searchController.text = search;
                _performSearch(search, controller);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No properties found',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'} found',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final property = _searchResults[index];
              return _buildPropertyCard(property);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showPropertyDetails(property),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Property Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(property['images'][0]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(property['status']),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          property['status'],
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Property Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'],
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/map pin.svg',
                          width: 12,
                          height: 12,
                          colorFilter: ColorFilter.mode(
                            Colors.grey[600]!,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property['address'],
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${property['bedrooms']}BR',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${property['bathrooms']}BA',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          property['propertyType'],
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NGN${_formatAmount(property['rentAmount'])}/month',
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF29BCA2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Occupied':
        return Colors.blue;
      case 'Under Maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount is num) {
      return amount
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return amount.toString();
  }

  void _showPropertyDetails(Map<String, dynamic> property) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Property Image
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(property['images'][0]),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(property['status']),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        property['status'],
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Property Details
            Text(
              property['title'],
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'NGN${_formatAmount(property['rentAmount'])}/month',
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF29BCA2),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Security Deposit: NGN${_formatAmount(property['holdingAmount'])}',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 16),

            // Property Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                  '${property['bedrooms']}',
                  'Bedrooms',
                  Icons.bed,
                ),
                _buildInfoItem(
                  '${property['bathrooms']}',
                  'Bathrooms',
                  Icons.bathtub,
                ),
                _buildInfoItem(property['propertyType'], 'Type', Icons.home),
              ],
            ),

            const SizedBox(height: 16),

            // Address
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    property['address'],
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Close',
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
                    onPressed: () {
                      Get.back();
                      Get.to(() => PropertyDetailScreen(property: property));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'View Property',
                      style: TextStyle(fontFamily: 'ProductSans', fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
