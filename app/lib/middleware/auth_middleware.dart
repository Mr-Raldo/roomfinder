import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    log('🔍 AuthMiddleware - Checking authentication for route: $route');
    log('🔍 Current session: ${session != null ? "Active" : "None"}');

    // If user has an active session, redirect to appropriate dashboard
    if (session != null) {
      log('✅ User is authenticated');
      // Don't redirect if already on a home/dashboard route
      if (route == AppRoutes.studentHome ||
          route == AppRoutes.landlordHome ||
          route == AppRoutes.adminHome) {
        log('✅ Already on dashboard route, allowing access');
        return null;
      }

      // Don't redirect if user is on any app page (not auth pages)
      if (route?.startsWith('/student-') == true ||
          route?.startsWith('/landlord-') == true ||
          route?.startsWith('/admin-') == true) {
        log('✅ Already on app page, allowing access');
        return null;
      }

      // If user is trying to access auth pages while logged in, redirect to dashboard
      log('🔄 Redirecting authenticated user to appropriate dashboard');
      return RouteSettings(name: _getDashboardRoute());
    }

    // If no session and trying to access protected routes, redirect to login
    if (session == null && route != AppRoutes.login && route != AppRoutes.signup) {
      log('⚠️ No session found, redirecting to login');
      return const RouteSettings(name: '/login');
    }

    log('✅ Allowing access to: $route');
    return null;
  }

  String _getDashboardRoute() {
    // Get the user's account type from metadata
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user?.userMetadata != null) {
      final accountType = user?.userMetadata?['account_type']?.toString().toLowerCase().trim();
      log('👤 User account type: $accountType');

      if (accountType == 'student') {
        return AppRoutes.studentHome;
      } else if (accountType == 'landlord') {
        return AppRoutes.landlordHome;
      } else if (accountType == 'administrator') {
        return AppRoutes.adminHome;
      }
    }

    // Default to student home if account type not found
    log('⚠️ Account type not found in metadata, defaulting to student home');
    return AppRoutes.studentHome;
  }
}
