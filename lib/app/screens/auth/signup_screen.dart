// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'package:get/get.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../../controllers/auth_controller.dart';
// import '../docs/terms_of_service_screen.dart';
// import '../docs/privacy_policy_screen.dart';

// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AuthController());

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: Get.width * 0.06),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: Get.height * 0.02),
//               // Logo
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: Get.width * 0.02),
//                 child: Image.asset(
//                   'assets/image/logo_black.png',
//                   width: 50,
//                   height: 50.2,
//                 ),
//               ),

//               SizedBox(height: Get.height * 0.04),

//               // Title
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: 'How do you\nwant to use\n',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontFamily: 'ProductSans-Black',
//                         fontWeight: FontWeight.w900,
//                         fontStyle: FontStyle.normal,
//                         color: Colors.black,
//                         height: 1,
//                         letterSpacing: 0,
//                       ),
//                     ),
//                     TextSpan(
//                       text: 'Bien Casa?',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontFamily: 'ProductSans',
//                         fontWeight: FontWeight.w400,
//                         fontStyle: FontStyle.normal,
//                         color: Colors.black,
//                         height: 1,
//                         letterSpacing: 0,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: Get.height * 0.06),

//               // Role Selection Grid
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 10,
//                   crossAxisSpacing: 10,
//                   childAspectRatio: 1,
//                   children: [
//                     // User Option
//                     _buildRoleCard(
//                       'User',
//                       'assets/icons/usericon.svg',
//                       controller,
//                       onTap: controller.navigateToUser,
//                     ),

//                     // Realtor Option
//                     _buildRoleCard(
//                       'Realtor',
//                       'assets/icons/realtor.svg',
//                       controller,
//                       onTap: controller.navigateToRealtor,
//                     ),

//                     // Home Owner Option
//                     _buildRoleCard(
//                       'Home\nOwner',
//                       'assets/icons/home_owner.svg',
//                       controller,
//                       onTap: controller.navigateToHomeOwner,
//                     ),

//                     // Sign In Option
//                     _buildSignInCard(controller),
//                   ],
//                 ),
//               ),

//               // Terms and Privacy
//               Padding(
//                 padding: EdgeInsets.only(
//                   // bottom: Get.height * 0.02,
//                   // top: Get.height * 0.02,
//                 ),
//                 child: Text.rich(
//                   TextSpan(
//                     text: 'By using Bien Casa you agree to our ',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontFamily: 'ProductSans Light',
//                       fontWeight: FontWeight.w300,
//                       fontStyle: FontStyle.normal,
//                       leadingDistribution: TextLeadingDistribution.proportional,
//                       letterSpacing: 0,
//                     ),
//                     children: [
//                       TextSpan(
//                         text: 'Term of Service',
//                         style: TextStyle(
//                           fontFamily: 'ProductSans',
//                           fontWeight: FontWeight.w700,
//                           fontStyle: FontStyle.normal,
//                           fontSize: 15,
//                           leadingDistribution:
//                               TextLeadingDistribution.proportional,
//                           letterSpacing: 0,
//                         ),
//                         recognizer:
//                             TapGestureRecognizer()
//                               ..onTap =
//                                   () => Get.to(
//                                     () => const TermsOfServiceScreen(),
//                                   ),
//                       ),
//                       TextSpan(text: ' and '),
//                       TextSpan(
//                         text: 'Privacy Policy',
//                         style: TextStyle(
//                           fontFamily: 'ProductSans',
//                           fontWeight: FontWeight.w700,
//                           fontStyle: FontStyle.normal,
//                           fontSize: 15,
//                           leadingDistribution:
//                               TextLeadingDistribution.proportional,
//                           letterSpacing: 0,
//                         ),
//                         recognizer:
//                             TapGestureRecognizer()
//                               ..onTap =
//                                   () =>
//                                       Get.to(() => const PrivacyPolicyScreen()),
//                       ),
//                     ],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRoleCard(
//     String title,
//     String iconPath,
//     AuthController controller, {
//     bool isComingSoon = false,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: isComingSoon ? null : onTap,
//       child: Container(
//         padding: EdgeInsets.all(21),
//         decoration: BoxDecoration(
//           color: Color(0xffF8F8F8),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Stack(
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SvgPicture.asset(
//                   iconPath.replaceAll('.png', '.svg'),
//                   width: 32,
//                   height: 44,
//                   alignment: Alignment.centerLeft,
//                   colorFilter: ColorFilter.mode(
//                     isComingSoon ? Color(0xffBDBDBD) : Colors.black,
//                     BlendMode.srcIn,
//                   ),
//                 ),
//                 SizedBox(height: Get.height * 0.01),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         title,
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           fontSize: 20,
//                           height: 1.2,
//                           fontFamily: 'ProductSans',
//                           fontWeight: FontWeight.w400,
//                           color:
//                               isComingSoon ? Color(0xffBDBDBD) : Colors.black,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       width: 25,
//                       height: 25,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.5),
//                         color: Colors.white,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: SvgPicture.asset(
//                           'assets/icons/right_arow.svg',
//                           width: 15,
//                           height: 11,
//                           colorFilter:
//                               isComingSoon
//                                   ? ColorFilter.mode(
//                                     Color(0xffBDBDBD),
//                                     BlendMode.srcIn,
//                                   )
//                                   : ColorFilter.mode(
//                                     Colors.black,
//                                     BlendMode.srcIn,
//                                   ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             if (isComingSoon)
//               Positioned(
//                 top: 10,
//                 right: 5,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: Colors.orange,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Text(
//                     'coming soon',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 8,
//                       fontFamily: 'ProductSans',
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSignInCard(AuthController controller) {
//     return GestureDetector(
//       onTap: controller.navigateToSignIn,
//       child: Container(
//         padding: EdgeInsets.all(25),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Color(0xffF8F8F8), width: 3),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               textAlign: TextAlign.left,
//               text: TextSpan(
//                 children: [
//                   TextSpan(
//                     text: 'Have an\naccount?\n',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontFamily: 'ProductSans',
//                       color: Color(0xff6B6B6B),
//                     ),
//                   ),
//                   TextSpan(
//                     text: 'Sign in',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontFamily: 'ProductSans',
//                       fontWeight: FontWeight.w900,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
