import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../controllers/flatmate_match_controller.dart';

class FlatmateActionButtons extends StatelessWidget {
  final Map<String, dynamic> match;

  const FlatmateActionButtons({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final FlatmateMatchController controller =
        Get.find<FlatmateMatchController>();

    return Row(
      children: [
        // Accept button
        Expanded(
          child: SizedBox(
            height: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29BCA2).withAlpha(26),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Get.back();
                controller.acceptMatch(match);
              },
              child: const Text(
                'Accept',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
                  color: Color(0xFF29BCA2),
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 15),

        // Decline button
        Expanded(
          child: SizedBox(
            height: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545).withAlpha(26),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Get.back();
                controller.declineMatch(match);
              },
              child: const Text(
                'Decline',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
                  color: Color(0xFFDC3545),
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
