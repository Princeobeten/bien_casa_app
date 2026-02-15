import 'package:bien_casa/app/controllers/auth_controller.dart';
import 'package:bien_casa/app/screens/auth/forgot_password_flow/forgot_password_screen.dart';
import 'package:bien_casa/app/screens/auth/forgot_password_flow/forgot_password_otp_screen.dart';
// import 'package:bien_casa/app/screens/auth/signup_flow/old/passport_verification_screen.dart';
import 'package:bien_casa/app/screens/auth/kyc/kyc_success_screen.dart';
import 'package:bien_casa/app/screens/auth/forgot_password_flow/reset_password_screen.dart';
import 'package:bien_casa/app/screens/auth/signin_screen.dart';

import 'package:bien_casa/app/screens/auth/login_flow/signin_otp_verification_screen.dart';
import 'package:bien_casa/app/screens/auth/signup_flow/signup_details_screen.dart';
import 'package:bien_casa/app/screens/user/flatmate/create_campaign/stepped_create_campaign_page.dart';
import 'package:bien_casa/app/screens/user/user_home_screen.dart';
import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/welcome_screen.dart';

import '../screens/auth/signup_flow/phone_verification_screen.dart';
import '../screens/auth/signup_flow/whatsapp_verification_screen.dart';
import '../screens/auth/signup_flow/otp_verification_screen.dart';
import '../screens/auth/kyc/nin_verification_screen.dart';
// import '../screens/auth/signup_flow/old/nin_verification_screen.dart' as old;
// import '../screens/auth/signup_flow/old/nin_password_screen.dart';
// import '../screens/auth/signup_flow/old/check_readability_screen.dart';
// import '../screens/auth/signup_flow/old/check_quality_screen.dart';
// import '../screens/auth/signup_flow/old/address_verification_screen.dart';
import '../screens/user/home/search/search_screen.dart';
// import '../screens/user/widgets/home/property/featured_properties_screen.dart';
import '../screens/user/home/property/recently_added_screen.dart';
import '../screens/user/home/property/location_properties_screen.dart';
import '../screens/user/home/property/property_detail_screen.dart';
// import '../screens/auth/signup_flow/old/selfie_screen.dart';
// import '../screens/auth/signup_flow/old/map_address_screen.dart';
import '../screens/user/home/map_screen.dart';
import '../screens/user/flatmate_screen.dart';
// import '../screens/user/flatmate/home/_pages/to delete/match_detail_screen.dart';
import '../screens/user/flatmate/home/_pages/flatmate_detail_screen.dart';
import '../screens/user/flatmate/home/_pages/flat_detail_page.dart';
import '../screens/user/flatmate/home/_pages/all_campaigns_page.dart';
import '../screens/user/flatmate/create_campaign/stepped_campaign_view_page.dart';
import '../screens/user/flatmate/home/_pages/flats_page.dart';
import '../screens/user/wallet/wallet_screen.dart';
import '../screens/user/wallet/withdraw_funds_screen.dart';
import '../screens/user/wallet/wallet_activities_screen.dart';
import '../screens/user/wallet/transaction_details_screen.dart';
import '../screens/user/wallet/wallet_notifications_screen.dart';
import '../screens/user/profile/profile_screen.dart';
import '../screens/user/profile/personal_information_screen.dart';
import '../screens/home_owner/home_owner_main_screen.dart';
import '../screens/home_owner/messages/chat_screen.dart';
import '../screens/user/lease/lease_application_screen.dart';
import '../screens/user/lease/my_applications_screen.dart';
import '../screens/home_owner/applications/application_detail_screen.dart';
import '../screens/home_owner/applications/applications_list_screen.dart';
import '../screens/user/home/property/inspection_request_screen.dart';
import '../screens/user/favorites/favorites_screen.dart';
import '../screens/user/home/property/hold_payment_screen.dart';
import '../screens/user/profile/documents_screen.dart';
import '../screens/user/home/property/my_inspections_screen.dart';
import '../screens/user/home/my_leases_screen.dart';
import '../screens/home_owner/inspections/inspection_management_screen.dart';
import '../screens/home_owner/properties/property_documents_screen.dart';
import '../screens/home_owner/properties/active_leases_screen.dart';
import '../screens/user/flatmate/home/_pages/flatmate_requests_screen.dart';
import '../screens/user/flatmate/home/_pages/campaign_houses_screen.dart';
import '../screens/user/flatmate/home/_pages/campaign_contributions_screen.dart';
import '../screens/user/flatmate/home/_pages/transfer_requests_screen.dart';
import '../screens/user/home/property/inspection_detail_screen.dart';
import '../screens/user/home/lease_detail_screen.dart';
import '../screens/user/home/payment_management_screen.dart';
import '../screens/user/flatmate/campaign_fee_payment_screen.dart';
import '../screens/home_owner/subscription/subscription_screen.dart';
import '../screens/user/chat/chat_list_screen.dart';
import '../screens/user/chat/chat_conversation_screen.dart';
import '../screens/kyc/email_verification_screen.dart';
import '../screens/kyc/complete_biodata_screen.dart';
import '../screens/kyc/wallet_pin_setup_screen.dart';
import '../screens/kyc/nin_verification_screen.dart' as kyc_nin;
import '../models/lease/house_lease.dart';
import '../bindings/welcome_binding.dart';
import '../bindings/onboarding_binding.dart';
import '../bindings/user_home_binding.dart';
import '../bindings/flatmate_binding.dart';
import '../controllers/home_owner_controller.dart';
import '../controllers/app_mode_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.kycSuccess,
      page: () => const KYCSuccessScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SIGNIN_OTP_VERIFICATION,
      page: () => SignInOtpVerificationScreen(phoneNumber: Get.arguments ?? ''),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SIGNUP_DETAILS,
      page: () => const SignupDetailsScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: AppRoutes.SPLASH, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.WELCOME,
      page: () => const WelcomeScreen(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => PhoneVerificationScreen(userType: 'user'),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SIGNIN,
      page: () => const SignInScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.REST_PASSWORD,
      page: () => const ForgotPasswordOtpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PHONE_VERIFICATION,
      page: () => PhoneVerificationScreen(userType: Get.arguments as String),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.WHATSAPP_VERIFICATION,
      page: () => WhatsAppVerificationScreen(phoneNumber: Get.arguments as String),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.OTP_VERIFICATION,
      page: () => OtpVerificationScreen(phoneNumber: Get.arguments as String),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.KYC_VERIFICATION,
      page: () => const NINVerificationScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
      transition: Transition.rightToLeft,
    ),
    // GetPage(
    //   name: AppRoutes.NIN_VERIFICATION,
    //   page: () => const old.NINVerificationScreen(),
    //   binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.PASSPORT_VERIFICATION,
    //   page: () => const PassportVerificationScreen(),
    //   binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.NIN_PASSWORD,
    //   page: () => const NINPasswordScreen(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.CHECK_READABILITY,
    //   page: () => const CheckReadabilityScreen(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.CHECK_QUALITY,
    //   page: () => CheckQualityScreen(image: Get.arguments as XFile),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.ADDRESS_VERIFICATION,
    //   page: () => const AddressVerificationScreen(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.SELFIE,
    //   page: () => const SelfieScreen(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.MAP_ADDRESS,
    //   page: () => const MapAddressScreen(),
    //   transition: Transition.rightToLeft,
    // ),
    GetPage(
      name: AppRoutes.USER_HOME,
      page: () => const UserHome(),
      binding: BindingsBuilder(() {
        UserHomeBinding().dependencies();
        Get.lazyPut(() => AppModeController());
      }),
      transition: Transition.rightToLeft,
    ),

    // New property-related screens
    GetPage(
      name: AppRoutes.SEARCH,
      page: () => const SearchScreen(),
      binding: UserHomeBinding(),
      transition: Transition.rightToLeft,
    ),
    // GetPage(
    //   name: AppRoutes.FEATURED_PROPERTIES,
    //   page: () => FeaturedPropertiesScreen(),
    //   binding: UserHomeBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    GetPage(
      name: AppRoutes.RECENTLY_ADDED,
      page: () => RecentlyAddedScreen(),
      binding: UserHomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.LOCATION_PROPERTIES,
      page: () => LocationPropertiesScreen(),
      binding: UserHomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PROPERTY_DETAIL,
      page: () => PropertyDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.MAP,
      page: () => const MapScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.FLATMATE,
      page: () => const FlatmateScreen(),
      binding: FlatmateBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.WALLET,
      page: () => WalletScreen(),
      transition: Transition.rightToLeft,
    ),
    // GetPage(
    //   name: AppRoutes.WALLET_ADD_FUNDS,
    //   page: () => const AddFundsScreen(),
    //   transition: Transition.rightToLeft,
    // ),
    GetPage(
      name: AppRoutes.WALLET_WITHDRAW,
      page: () => const WithdrawFundsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.WALLET_ACTIVITIES,
      page: () => const WalletActivitiesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/wallet-transaction-details',
      page: () => const TransactionDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/wallet-notifications',
      page: () => const WalletNotificationsScreen(),
      transition: Transition.rightToLeft,
    ),
    // FLATMATE_DETAIL route is defined below with full argument handling
    GetPage(
      name: AppRoutes.ADD_FLATMATE,
      page: () => const SteppedCreateCampaignPage(),
      binding: FlatmateBinding(),
      transition: Transition.rightToLeft,
    ),
    // GetPage(
    //   name: AppRoutes.MATCH_DETAIL,
    //   page: () => MatchDetailScreen(initialData: Get.arguments),
    //   transition: Transition.rightToLeft,
    // ),
    GetPage(
      name: AppRoutes.FLATMATE_DETAIL,
      page: () {
        // Handle both old and new argument formats
        bool isMyFlatmate = false;
        if (Get.arguments is Map<String, dynamic> &&
            Get.arguments.containsKey('myFlatmate')) {
          // Safely handle the boolean value which might be null
          final myFlatmateValue = Get.arguments['myFlatmate'];
          if (myFlatmateValue is bool) {
            isMyFlatmate = myFlatmateValue;
          }
        }
        return FlatmateDetailScreen(myFlatmate: isMyFlatmate);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.FLAT_DETAIL,
      page: () => const FlatDetailPage(),
      binding: FlatmateBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.CAMPAIGNS_PAGE,
      page: () => const CampaignsPage(),
      binding: FlatmateBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.CAMPAIGN_VIEW,
      page: () => const SteppedCampaignViewPage(),
      binding: FlatmateBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.FLATS_PAGE,
      page: () => const FlatsPage(),
      binding: FlatmateBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PERSONAL_INFORMATION,
      page: () => PersonalInformationScreen(
        isEditMode: Get.arguments as bool? ?? false,
      ),
      transition: Transition.rightToLeft,
    ),

    // Home owner specific routes
    GetPage(
      name: AppRoutes.HOME_OWNER_MAIN,
      page: () => const HomeOwnerMainScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeOwnerController());
        Get.lazyPut(() => AppModeController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.HOME_OWNER_CHAT,
      page: () => ChatScreen(conversation: Get.arguments),
      transition: Transition.rightToLeft,
    ),

    // Lease application routes
    GetPage(
      name: AppRoutes.LEASE_APPLICATION,
      page: () => LeaseApplicationScreen(lease: Get.arguments),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.MY_APPLICATIONS,
      page: () => const MyApplicationsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.APPLICATION_DETAIL,
      page: () => ApplicationDetailScreen(application: Get.arguments),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.OWNER_APPLICATIONS,
      page: () => const ApplicationsListScreen(),
      transition: Transition.rightToLeft,
    ),

    // Inspection routes
    GetPage(
      name: AppRoutes.INSPECTION_REQUEST,
      page: () {
        final lease = Get.arguments as HouseLease;
        return InspectionRequestScreen(lease: lease);
      },
      transition: Transition.rightToLeft,
    ),

    // Favorites routes
    GetPage(
      name: AppRoutes.FAVORITES,
      page: () => const FavoritesScreen(),
      transition: Transition.rightToLeft,
    ),

    // Hold payment routes
    GetPage(
      name: AppRoutes.HOLD_PAYMENT,
      page: () {
        final lease = Get.arguments as HouseLease;
        return HoldPaymentScreen(lease: lease);
      },
      transition: Transition.rightToLeft,
    ),

    // Document routes
    GetPage(
      name: AppRoutes.MY_DOCUMENTS,
      page: () => const DocumentsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Inspection management routes
    GetPage(
      name: AppRoutes.MY_INSPECTIONS,
      page: () => const MyInspectionsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Lease management routes
    GetPage(
      name: AppRoutes.MY_LEASES,
      page: () => const MyLeasesScreen(),
      transition: Transition.rightToLeft,
    ),

    // Home owner management routes
    GetPage(
      name: AppRoutes.OWNER_INSPECTION_MANAGEMENT,
      page: () => const InspectionManagementScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.OWNER_PROPERTY_DOCUMENTS,
      page: () => PropertyDocumentsScreen(
        property: Get.arguments as Map<String, dynamic>?,
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.OWNER_ACTIVE_LEASES,
      page: () => const ActiveLeasesScreen(),
      transition: Transition.rightToLeft,
    ),

    // Campaign (Flatmate) management routes
    GetPage(
      name: AppRoutes.FLATMATE_REQUESTS,
      page: () => FlatmateRequestsScreen(
        campaignId: Get.arguments?['campaignId'] ?? '',
        campaignTitle: Get.arguments?['campaignTitle'] ?? 'Campaign',
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.CAMPAIGN_HOUSES,
      page: () => CampaignHousesScreen(
        campaignId: Get.arguments?['campaignId'] ?? '',
        campaignTitle: Get.arguments?['campaignTitle'] ?? 'Campaign',
        totalMembers: Get.arguments?['totalMembers'] ?? 3,
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.CAMPAIGN_CONTRIBUTIONS,
      page: () => CampaignContributionsScreen(
        campaignId: Get.arguments?['campaignId'] ?? '',
        campaignTitle: Get.arguments?['campaignTitle'] ?? 'Campaign',
        totalMembers: Get.arguments?['totalMembers'] ?? 3,
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.TRANSFER_REQUESTS,
      page: () => TransferRequestsScreen(
        campaignId: Get.arguments?['campaignId'] ?? '',
        campaignTitle: Get.arguments?['campaignTitle'] ?? 'Campaign',
        totalMembers: Get.arguments?['totalMembers'] ?? 3,
      ),
      transition: Transition.rightToLeft,
    ),
    
    // Phase 2 - Additional User Routes
    GetPage(
      name: AppRoutes.INSPECTION_DETAIL,
      page: () => InspectionDetailScreen(
        inspection: Get.arguments as Map<String, dynamic>,
      ),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.LEASE_DETAIL,
      page: () => LeaseDetailScreen(
        lease: Get.arguments as Map<String, dynamic>,
      ),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.PAYMENT_MANAGEMENT,
      page: () => const PaymentManagementScreen(),
      transition: Transition.cupertino,
    ),

    // Monetization routes
    GetPage(
      name: AppRoutes.CAMPAIGN_FEE_PAYMENT,
      page: () => const CampaignFeePaymentScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.OWNER_SUBSCRIPTION,
      page: () => const SubscriptionScreen(),
      transition: Transition.rightToLeft,
    ),

    // Chat routes
    GetPage(
      name: AppRoutes.CHAT_LIST,
      page: () => const ChatListScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.CHAT_CONVERSATION,
      page: () => const ChatConversationScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // KYC Completion routes
    GetPage(
      name: AppRoutes.EMAIL_VERIFICATION,
      page: () => const EmailVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.COMPLETE_BIODATA,
      page: () => const CompleteBiodataScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.WALLET_PIN_SETUP,
      page: () => const WalletPinSetupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.NIN_VERIFICATION,
      page: () => const kyc_nin.NINVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
