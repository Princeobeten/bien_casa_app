import 'package:bien_casa/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KYCSuccessScreen extends StatelessWidget {
  const KYCSuccessScreen({super.key});

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
                flex: isSmallScreen ? 3 : 2,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/image/Mask_group_7.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Logo positioned at top left
                    Positioned(
                      top: 40,
                      left: 28,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Image.asset(
                          'assets/image/logo_white.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                flex: isSmallScreen ? 4 : 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: Get.height * 0.01,
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You're All Set To\nGo!",
                        style: TextStyle(
                          fontFamily: 'ProductSans Black',
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.normal,
                          fontSize: 35,
                          height: 1,
                          letterSpacing: 0,
                          color: Color(0xff29BCA2),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.02),
                      Text(
                        'Congrats! your account is successfully created, \nyou can now find your ideal flat mate based on \nbudget, location, lifestyle preferences.',
                        style: TextStyle(
                          fontFamily: 'ProductSans Light',
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          fontSize: 15,
                          height: 1.25,
                          color: Colors.black,
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () => Get.offAllNamed(AppRoutes.USER_HOME),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Take me in',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 22,
                              height: 40 / 22,
                              letterSpacing: 0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // White gradient cloud overlay
          Positioned(
            bottom: Get.height / (isSmallScreen ? 1.75 : 2),
            left: 0,
            right: 0,
            height: Get.height * 0.12,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0), Colors.white],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
