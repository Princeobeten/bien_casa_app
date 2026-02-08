import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../controllers/user_home_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final UserHomeController _controller = Get.find<UserHomeController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 24,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            height: 1.04,
            letterSpacing: -0.32,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search input field
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xffF8F8F8),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/search icon.svg',
                    color: Colors.black,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search Bien Casa...',
                        hintStyle: TextStyle(
                          color: Color(0xffBDBDBD),
                          fontSize: 16,
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.w300,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  // Show cancel button only when there is text
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search results
            Expanded(
              child:
                  _searchQuery.isEmpty
                      ? _buildSearchSuggestions()
                      : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            height: 1.04,
            letterSpacing: -0.32,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSuggestionChip('Apartment'),
            _buildSuggestionChip('Villa'),
            _buildSuggestionChip('Lagos'),
            _buildSuggestionChip('Abuja'),
            _buildSuggestionChip('2 Bedroom'),
            _buildSuggestionChip('Duplex'),
            _buildSuggestionChip('Garden'),
            _buildSuggestionChip('Penthouse'),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Searches',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            height: 1.04,
            letterSpacing: -0.32,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildRecentSearchItem('Luxury Apartment in Lekki'),
        _buildRecentSearchItem('2 Bedroom flat in Abuja'),
        _buildRecentSearchItem('Victoria Island penthouse'),
      ],
    );
  }

  Widget _buildSuggestionChip(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchController.text = label;
          _searchQuery = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(
        search,
        style: const TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        setState(() {
          _searchController.text = search;
          _searchQuery = search;
        });
      },
    );
  }

  Widget _buildSearchResults() {
    // Filter properties based on search query
    final allProperties = [
      ..._controller.featuredProperties,
      ..._controller.recentlyAddedProperties,
    ];

    for (var location in _controller.locationProperties.keys) {
      allProperties.addAll(_controller.locationProperties[location] ?? []);
    }

    final filteredProperties =
        allProperties.where((property) {
          final name = property['name'] ?? '';
          final address = property['address'] ?? '';
          final type = property['type'] ?? '';

          return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              type.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    if (filteredProperties.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(fontFamily: 'ProductSans', fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredProperties.length,
      itemBuilder: (context, index) {
        final property = filteredProperties[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                property['images'] != null &&
                        (property['images'] as List).isNotEmpty
                    ? property['images'][0].toString().startsWith('http')
                        ? Image.network(
                          property['images'][0],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        )
                        : Image.asset(
                          property['images'][0],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                    : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
          ),
          title: Text(
            property['name'] ?? '',
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property['address'] ?? '',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${property['price'] ?? ''} • ${property['size'] ?? ''} • ${property['type'] ?? ''}',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          onTap: () => _controller.navigateToPropertyDetail(property),
        );
      },
    );
  }
}
