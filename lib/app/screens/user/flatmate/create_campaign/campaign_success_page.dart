import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CampaignSuccessPage extends StatelessWidget {
  const CampaignSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Get.height < 600;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Image at the top with logo
              Expanded(
                flex: isSmallScreen ? 4 : 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/image/85b6b47de87691ae5eb17ce2ee2ccda7ea1f1f06.jpg',
                          ), // Use the success image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Logo positioned at top left
                    Positioned(
                      top:
                          isSmallScreen ? Get.height * 0.04 : Get.height * 0.05,
                      left: 20,
                      child: Container(
                        padding: EdgeInsets.all(Get.width * 0.02),
                        child: SvgPicture.asset(
                          'assets/icons/flatmate_white.svg',
                          width: Get.width * 0.12,
                          height: Get.width * 0.12,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                flex: isSmallScreen ? 3 : 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Success message
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'You\'re all set to\n',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'Product Sans Black',
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: Color(0xFF29BCA2),
                                ),
                              ),
                              TextSpan(
                                text: 'go!',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'Product Sans Black',
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: Color(0xFF29BCA2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Your campaign is successfully published. Your Perfect Flatmate Awaits!',
                          style: TextStyle(
                            fontFamily: 'Product Sans Light',
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                            height: 1.33,
                            letterSpacing: 0,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Review notice
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Colors.orange[700],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your campaign is being reviewed, and will be live once approved.',
                                style: TextStyle(
                                  fontFamily: 'Product Sans Light',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15,
                                  color: Colors.orange[700],
                                  height: 1.33,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Take me home button
                        SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate back to home or main screen
                              Get.offAllNamed(
                                '/flatmate',
                              ); // Adjust route as needed
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Take me home',
                              style: TextStyle(
                                fontSize: Get.width * 0.055,
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50), // Exactly 50px from bottom
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // White gradient cloud overlay - positioned at the bottom of the image section
          Positioned(
            top:
                isSmallScreen
                    ? (Get.height * 4 / 7) -
                        (Get.height *
                            0.08) // 4/7 is the image flex ratio minus overlay height
                    : (Get.height * 3 / 5) -
                        (Get.height *
                            0.08), // 3/5 is the image flex ratio minus overlay height
            left: 0,
            right: 0,
            height: Get.height * 0.08,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0), Colors.white],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
