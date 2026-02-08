import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'campaign_preview_page.dart';

class PinEntryBottomSheet extends StatefulWidget {
  const PinEntryBottomSheet({super.key});

  @override
  State<PinEntryBottomSheet> createState() => _PinEntryBottomSheetState();
}

class _PinEntryBottomSheetState extends State<PinEntryBottomSheet> {
  String pin = '';
  final int pinLength = 4;
  late List<String> shuffledNumbers;

  @override
  void initState() {
    super.initState();
    // Create a shuffled list of numbers 0-9
    shuffledNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    shuffledNumbers.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Header content
          const Text(
            'Confirm payment',
            style: TextStyle(
              fontFamily: 'Product Sans',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'NGN250,000',
            style: TextStyle(
              fontFamily: 'Product Sans',
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),

          const Text(
            'Flatmate Escrow fee',
            style: TextStyle(
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          // PIN display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pinLength, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        index < pin.length ? Colors.black : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    index < pin.length ? '*' : '',
                    style: const TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Number pad - taking remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index < 10) {
                    // Shuffled numbers 0-9
                    return _buildNumberButton(shuffledNumbers[index]);
                  } else if (index == 10) {
                    // Empty space
                    return Container();
                  } else if (index == 11) {
                    // Delete button
                    return GestureDetector(
                      onTap: () {
                        if (pin.isNotEmpty) {
                          setState(() {
                            pin = pin.substring(0, pin.length - 1);
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.backspace_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () {
        if (pin.length < pinLength) {
          setState(() {
            pin += number;
          });

          // Auto-proceed when PIN is complete
          if (pin.length == pinLength) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _completePinEntry();
            });
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: 'Product Sans',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _completePinEntry() {
    // Close the bottom sheet and navigate to campaign preview page
    Navigator.pop(context);
    Get.to(() => const CampaignPreviewPage());
  }
}
