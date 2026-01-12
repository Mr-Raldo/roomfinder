import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';
import 'constants/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: whiteColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _initialRoute = AppRoutes.login;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      log('🔍 Checking authentication status...');
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session != null) {
        log('✅ Active session found');

        // Try to get account type from user metadata or database
        final userId = session.user.id;

        // Query the user_profiles table to get account_type
        final response = await supabase
            .from('user_profiles')
            .select('account_type')
            .eq('id', userId)
            .single();

        final accountType = response['account_type']?.toString().toLowerCase().trim();
        log('👤 User account type: $accountType');

        setState(() {
          if (accountType == 'student') {
            _initialRoute = AppRoutes.studentHome;
          } else if (accountType == 'landlord') {
            _initialRoute = AppRoutes.landlordHome;
          } else if (accountType == 'administrator') {
            _initialRoute = AppRoutes.adminHome;
          } else {
            _initialRoute = AppRoutes.studentHome; // Default
          }
        });

        log('🚀 Redirecting to: $_initialRoute');
      } else {
        log('⚠️ No active session, showing login screen');
      }
    } catch (e) {
      log('❌ Error checking auth status: $e');
      // If there's an error, default to login
      setState(() {
        _initialRoute = AppRoutes.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Room Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: whiteColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: whiteColor,
          elevation: 0,
          iconTheme: IconThemeData(color: charcoalBlack),
          titleTextStyle: TextStyle(
            color: charcoalBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: whiteColor,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      initialRoute: _initialRoute,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
