import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';

class FlatCard extends StatelessWidget {
  final Map<String, dynamic> flat;

  const FlatCard({super.key, required this.flat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to flat details page
        Get.toNamed(AppRoutes.FLAT_DETAIL, arguments: flat);
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Flat image
              Image.network(
                flat['image'],
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.home,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
              ),

              // Black gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Favorite icon in top-right corner
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: () {
                    flat['isFavorite'] = !(flat['isFavorite'] ?? false);
                    // Update the flat in the database
                    // TODO: Implement database update
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      flat['isFavorite'] == true
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          flat['isFavorite'] == true
                              ? Colors.white
                              : Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Flat details at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bedrooms count
                      Text(
                        '${flat['bedrooms']} Bedroom Flat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Rating stars
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < (flat['rating'] ?? 0)
                                ? Icons.star_rounded
                                : Icons.star_rounded,
                            color:
                                index < (flat['rating'] ?? 0)
                                    ? Colors.amber
                                    : Colors.grey[300],
                            size: 14,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),

                      // Price and location row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/naira.svg',
                                width: 13,
                                height: 13,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 1.75),
                              Text(
                                '${flat['price']}/yr',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'ProductSans',
                                ),
                              ),
                            ],
                          ),

                          // Location
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                (flat['location'] ?? 'Unknown').split(' ')[0],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'ProductSansLight',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
