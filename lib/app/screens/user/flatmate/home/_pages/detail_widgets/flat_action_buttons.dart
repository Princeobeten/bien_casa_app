import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlatActionButtons extends StatelessWidget {
  final Map<String, dynamic> flat;

  const FlatActionButtons({super.key, required this.flat});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Book Now button
        Expanded(
          child: Container(
            height: 70,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Book Now',
                  'Processing your booking request',
                  snackPosition: SnackPosition.TOP,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
