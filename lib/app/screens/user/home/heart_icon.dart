import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/lease/favourite_controller.dart';

class HeartIcon extends StatelessWidget {
  final bool isWhite;
  final double size;
  final double padding;
  final double iconSize;
  final VoidCallback? onTap;
  final String? propertyId;

  const HeartIcon({
    super.key,
    this.isWhite = true,
    this.size = 32.0,
    this.padding = 6.0,
    this.iconSize = 16.0,
    this.onTap,
    this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    final favouriteController = Get.find<FavouriteController>();

    return GetBuilder<FavouriteController>(
      builder: (controller) {
        final isFavorite =
            propertyId != null ? controller.isFavourited(propertyId!) : false;

        return GestureDetector(
          onTap: () async {
            if (propertyId != null) {
              // TODO: Get actual userId from AuthController when auth is fully implemented
              // For now, using a mock userId
              const userId = 'user_001';

              // Toggle favorite using controller
              final newState = await controller.toggleFavourite(
                userId,
                propertyId!,
              );

              // Show feedback to user
              Get.snackbar(
                'Favorite',
                newState ? 'Added to favorites' : 'Removed from favorites',
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 1),
                backgroundColor: newState ? Colors.green : Colors.grey,
                colorText: Colors.white,
              );
            }

            // Call the original onTap if provided
            if (onTap != null) {
              onTap!();
            }
          },
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isWhite
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black.withOpacity(0.6),
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
              color:
                  isFavorite
                      ? Colors.red
                      : (isWhite ? Colors.black : Colors.white),
              size: iconSize,
            ),
          ),
        );
      },
    );
  }
}
