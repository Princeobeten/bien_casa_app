import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/user_home_controller.dart';
import '../location_property_card.dart';

class LocationPropertiesScreen extends StatelessWidget {
  final UserHomeController _controller = Get.find<UserHomeController>();
  final String location;

  LocationPropertiesScreen({super.key}) : location = Get.arguments as String;

  @override
  Widget build(BuildContext context) {
    final properties = _controller.locationProperties[location] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Properties in $location',
          style: const TextStyle(
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
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8, // Adjust based on card dimensions
        ),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return LocationPropertyCard(
            imageUrl:
                property['images'] != null &&
                        (property['images'] as List).isNotEmpty
                    ? property['images'][0]
                    : '',
            name: property['name'] ?? '',
            address: property['address'] ?? '',
            price: property['price'] ?? '',
            size: property['size'] ?? '',
            type: property['type'] ?? '',
            onTap: () => _controller.navigateToPropertyDetail(property),
          );
        },
      ),
    );
  }
}
