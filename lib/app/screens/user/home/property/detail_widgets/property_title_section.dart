import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class PropertyTitleSection extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyTitleSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final double rating = property['rating'] ?? 3.5;
    final int reviews = property['reviews'] ?? 1050;
    final Map<String, dynamic> mapCoordinates =
        property['location']?['coordinates'] ?? {'latitude': 0.0, 'longitude': 0.0};

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property['title'] ?? 'Blue Ocean Estate',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 24.0,
                  height: 1.0,
                  leadingDistribution: TextLeadingDistribution.even,
                  letterSpacing: -0.32,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xff6B6B6B),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      property['location']?['address'] ??
                          '101 Jesse Jackson Street, Abuja 198302',
                      style: const TextStyle(
                        fontFamily: 'ProductSans Light',
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        fontSize: 13,
                        leadingDistribution:
                            TextLeadingDistribution.proportional,
                        letterSpacing: 0,
                        color: Color(0xff6B6B6B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xffFBA01C),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: TextStyle(
                      fontFamily: 'ProductSans Light',
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0,
                      color: const Color(0xff6B6B6B),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '| $reviews reviews',
                    style: TextStyle(
                      fontFamily: 'ProductSans Light',
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0,
                      color: const Color(0xff6B6B6B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            // Open map with coordinates
            final latitude = mapCoordinates['latitude'];
            final longitude = mapCoordinates['longitude'];
            final propertyName = property['title'] ?? 'Blue Ocean Estate';
            final propertyAddress =
                property['location']?['address'] ?? '101 Jesse Jackson Street, Abuja 198302';
            final propertyType = property['category'] ?? 'Residential';
            final propertySize = property['features']?['size'] ?? '500SQM';
            final propertyPrice = property['price']?.toString() ?? 'N110m per unit';

            // Navigate to map screen
            Get.toNamed(
              '/map',
              arguments: {
                'latitude': latitude,
                'longitude': longitude,
                'propertyName': propertyName,
                'propertyAddress': propertyAddress,
                'propertyImage':
                    property['photos'] != null && property['photos'].isNotEmpty
                        ? property['photos'][0]
                        : null,
                'propertyType': propertyType,
                'propertySize': propertySize,
                'propertyPrice': propertyPrice,
                'landmarks': property['features']?['landmarks'] ?? [],
              },
            );
          },
          child: Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 0),
                  blurRadius: 4,
                  color: Color(0x26000000),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/icons/map.svg',
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
