import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/lease/house_lease.dart';
import '../../controllers/lease/favourite_controller.dart';
import '../status_badges/status_badge.dart';

/// PropertyCard - Reusable property listing card
class PropertyCard extends StatelessWidget {
  final HouseLease lease;
  final VoidCallback? onTap;
  final bool showFavorite;
  final String? userId;

  const PropertyCard({
    Key? key,
    required this.lease,
    this.onTap,
    this.showFavorite = true,
    this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favouriteController = Get.find<FavouriteController>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: lease.photos.isNotEmpty
                      ? Image.network(
                          lease.photos.first,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.home, size: 60, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.home, size: 60, color: Colors.grey),
                        ),
                ),
                // Status badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: LeaseStatusBadge(status: lease.status),
                ),
                // Property status badge
                Positioned(
                  top: 12,
                  right: showFavorite && userId != null ? 60 : 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: lease.isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lease.propertyStatus,
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Favorite button
                if (showFavorite && userId != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Obx(() {
                      final isFav = favouriteController.isFavourited(lease.id);
                      return GestureDetector(
                        onTap: () {
                          favouriteController.toggleFavourite(userId!, lease.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
            // Property details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    lease.title,
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lease.location['city'] ?? 'Location',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price and details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lease.formattedPrice,
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            lease.leaseDuration,
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      // Property type
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lease.propertyType,
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
