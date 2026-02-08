import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/user_home_controller.dart';
import '../home/property_list_item.dart';

/// FavoritesScreen - Display user's favorited properties
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final UserHomeController _controller = Get.find<UserHomeController>();

  // Mock favorites data - will be replaced with actual API data
  final List<Map<String, dynamic>> _mockFavorites = [
    {
      'id': 'fav_001',
      'name': 'Modern 3BR Apartment in Lekki',
      'address': 'Lekki Phase 1, Lagos',
      'price': 'NGN5,000,000',
      'size': '120 sqm',
      'type': 'Apartment',
      'bedrooms': 3,
      'bathrooms': 2,
      'images': [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      ],
      'isFavorite': true,
    },
    {
      'id': 'fav_002',
      'name': 'Luxury 4BR Duplex with Pool',
      'address': 'Victoria Island, Lagos',
      'price': 'NGN8,000,000',
      'size': '200 sqm',
      'type': 'Duplex',
      'bedrooms': 4,
      'bathrooms': 3,
      'images': [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      ],
      'isFavorite': true,
    },
    {
      'id': 'fav_003',
      'name': 'Cozy 2BR Flat in Ikeja',
      'address': 'Ikeja GRA, Lagos',
      'price': 'NGN3,500,000',
      'size': '85 sqm',
      'type': 'Flat',
      'bedrooms': 2,
      'bathrooms': 1,
      'images': [
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      ],
      'isFavorite': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'My Favorites',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          if (_mockFavorites.isNotEmpty)
            TextButton(
              onPressed: () => _showClearAllDialog(),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
      body:
          _mockFavorites.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _mockFavorites.length,
                itemBuilder: (context, index) {
                  final property = _mockFavorites[index];
                  final List<String> images =
                      property['images'] != null && property['images'] is List
                          ? List<String>.from(property['images'])
                          : [];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PropertyListItem(
                      imageUrl: images.isNotEmpty ? images[0] : '',
                      name: property['name'] ?? '',
                      address: property['address'] ?? '',
                      size: property['size'] ?? '',
                      type: property['type'] ?? '',
                      price: property['price'] ?? '',
                      onTap:
                          () => _controller.navigateToPropertyDetail(property),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Favorites Yet',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding properties to your favorites\nto see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Browse Properties',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Clear All Favorites?',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'This will remove all properties from your favorites. This action cannot be undone.',
          style: TextStyle(fontFamily: 'ProductSans', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _mockFavorites.clear();
              });
              Get.back();
              Get.snackbar(
                'Cleared',
                'All favorites have been removed',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.grey.shade100,
                colorText: Colors.black,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
