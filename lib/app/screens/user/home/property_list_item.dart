import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'heart_icon.dart';

class PropertyListItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String address;
  final String size;
  final String type;
  final String price;
  final Function()? onTap;
  final String? propertyId;

  const PropertyListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.address,
    required this.size,
    required this.type,
    required this.price,
    this.onTap,
    this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        child: Row(
          children: [
            // Property image with heart icon - LEFT SIDE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                  child:
                      imageUrl.startsWith('http')
                          ? Image.network(
                            imageUrl,
                            width: 136,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 136,
                                height: double.infinity,
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
                                width: 136,
                                height: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.error)),
                              );
                            },
                          )
                          : Image.asset(
                            imageUrl,
                            width: 136,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 136,
                                height: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.error)),
                              );
                            },
                          ),
                ),
                // Heart icon
                Positioned(
                  top: 10,
                  left: 10,
                  child: HeartIcon(
                    isWhite: false,
                    padding: 6,
                    iconSize: 16,
                    propertyId: propertyId,
                  ),
                ),
              ],
            ),

            // Property details - RIGHT SIDE
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                        height: 1,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Location with pin icon
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontFamily: 'ProductSans Light',
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.normal,
                              fontSize: 12.5,
                              height: 1,
                              letterSpacing: 0,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Area and type
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
                            fontSize: 12.5,
                            height: 1,
                            letterSpacing: 0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(width: 14),
                    // Price with bolder styling
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
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
                          Text(
                            ' ${price.split(' ').skip(1).join(' ')}', // The 'per unit' text
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
