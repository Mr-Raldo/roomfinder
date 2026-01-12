import 'package:get/get.dart';
import '../screens/auth/views/screens/phone_login.dart';
import '../screens/auth/views/screens/phone_signup.dart';
import '../screens/auth/views/screens/phone_otp_verification.dart';
import '../screens/auth/views/screens/phone_pin_setup.dart';
import '../screens/auth/views/screens/phone_forgot_pin.dart';
import '../screens/auth/views/screens/forgot_pin_otp_screen.dart';
import '../screens/student/student_home_screen.dart';
import '../screens/student/student_search_screen.dart';
import '../screens/student/student_saved_screen.dart';
import '../screens/student/student_messages_screen.dart';
import '../screens/student/student_profile_screen.dart';
import '../screens/landlord/landlord_home_screen.dart';
import '../screens/landlord/landlord_properties_screen.dart';
import '../screens/landlord/landlord_add_property_screen.dart';
import '../screens/landlord/landlord_messages_screen.dart';
import '../screens/landlord/landlord_profile_screen.dart';
import '../screens/administrator/admin_home_screen.dart';
import '../screens/administrator/admin_users_screen.dart';
import '../screens/administrator/admin_properties_screen.dart';
import '../screens/administrator/admin_reports_screen.dart';
import '../screens/administrator/admin_messages_screen.dart';
import '../screens/administrator/admin_profile_screen.dart';
import '../widgets/admin_bottom_nav.dart';
import '../controllers/auth_controller.dart';
import '../middleware/auth_middleware.dart';

class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';
  static const String pinSetup = '/pin-setup';
  static const String forgotPin = '/forgot-pin';
  static const String forgotPinOtp = '/forgot-pin-otp';

  // Home routes for different user types
  static const String studentHome = '/student-home';
  static const String studentSearch = '/student-search';
  static const String studentSaved = '/student-saved';
  static const String studentMessages = '/student-messages';
  static const String studentProfile = '/student-profile';
  static const String landlordHome = '/landlord-home';
  static const String landlordProperties = '/landlord-properties';
  static const String landlordAddProperty = '/landlord-add-property';
  static const String landlordMessages = '/landlord-messages';
  static const String landlordProfile = '/landlord-profile';
  static const String adminHome = '/admin-home';
  static const String adminUsers = '/admin-users';
  static const String adminProperties = '/admin-properties';
  static const String adminReports = '/admin-reports';
  static const String adminMessages = '/admin-messages';
  static const String adminProfile = '/admin-profile';

  static List<GetPage> routes = [
    // Auth routes
    GetPage(
      name: login,
      page: () => const PhoneLoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: signup,
      page: () => const PhoneSignupScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: otpVerification,
      page: () => const PhoneOtpVerificationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: pinSetup,
      page: () => const PhonePinSetupScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: forgotPin,
      page: () => const PhoneForgotPinScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: forgotPinOtp,
      page: () => const ForgotPinOtpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),

    // Home routes for different user types
    GetPage(
      name: studentHome,
      page: () => const StudentHomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: studentSearch,
      page: () => const StudentSearchScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: studentSaved,
      page: () => const StudentSavedScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: studentMessages,
      page: () => const StudentMessagesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: studentProfile,
      page: () => const StudentProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: landlordHome,
      page: () => const LandlordHomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: landlordProperties,
      page: () => const LandlordPropertiesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: landlordAddProperty,
      page: () => const LandlordAddPropertyScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: landlordMessages,
      page: () => const LandlordMessagesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: landlordProfile,
      page: () => const LandlordProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: adminHome,
      page: () => const AdminBottomNav(initialIndex: 0),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: adminUsers,
      page: () => const AdminBottomNav(initialIndex: 1),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: adminProperties,
      page: () => const AdminBottomNav(initialIndex: 2),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: adminReports,
      page: () => const AdminBottomNav(initialIndex: 3),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: adminMessages,
      page: () => const AdminBottomNav(initialIndex: 4),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: adminProfile,
      page: () => const AdminBottomNav(initialIndex: 5),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
  ];
}
