import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class PropertyPrice extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyPrice({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/naira.svg',
                          width: 25,
                          height: 25,
                        ),

                        Text(
                          property['price'] ?? '0',
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  property['discount'] ?? '15% off',
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 16,
                    color: Color(0xffDC3545),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            // Make an offer button
            Stack(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.snackbar(
                      'Make an Offer',
                      'Opening offer form',
                      snackPosition: SnackPosition.TOP,
                    );
                  },
                  child: const Text(
                    'Make an offer',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

                Positioned(
                  right: double.minPositive,
                  bottom: 35,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Text(
                      'pro',
                      style: TextStyle(
                        color: Color(0xffFBA01C),
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
