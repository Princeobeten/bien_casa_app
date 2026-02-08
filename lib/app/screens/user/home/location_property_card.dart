import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'heart_icon.dart';

class LocationPropertyCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String address;
  final String price;
  final String size;
  final String type;
  final Function()? onTap;

  const LocationPropertyCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.address,
    required this.price,
    required this.size,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 158,

        margin: const EdgeInsets.only(right: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x26000000).withValues(alpha: 0.1),
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image with heart overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child:
                      imageUrl.startsWith('http')
                          ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 97,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: 97,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 97,
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.error)),
                              );
                            },
                          )
                          : Image.asset(
                            imageUrl,
                            width: double.infinity,
                            height: 97,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 97,
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.error)),
                              );
                            },
                          ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: const HeartIcon(
                    isWhite: false,
                    size: 30,
                    padding: 6,
                    iconSize: 16,
                  ),
                ),
              ],
            ),

            // Property details
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property name
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      height: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Address with location icon
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontFamily: 'ProductSans Light',
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.normal,
                            height: 1,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Size and type
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/sqm.svg',
                        height: 14,
                        width: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$size - $type',
                        style: const TextStyle(
                          fontFamily: 'ProductSans Light',
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          height: 1,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Price
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/naira.svg',
                        width: 13,
                        height: 13,
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
