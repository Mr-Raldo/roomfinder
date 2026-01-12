import 'dart:developer';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/phone_auth_service.dart';
import '../utils/helper/helper_controller.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PhoneAuthService _phoneAuthService = PhoneAuthService();

  // Observable variables for form data (Phone + PIN based)
  final RxString phoneNumber = ''.obs;
  final RxString pin = ''.obs;
  final RxString otp = ''.obs;
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString selectedAccountType = 'Student'.obs; // Student, Landlord, Administrator
  final RxBool isLoading = false.obs;
  final RxBool otpSent = false.obs;
  final RxBool otpVerified = false.obs;

  // Current user profile data
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);

  // ---------------------------
  // VALIDATION HELPERS
  // ---------------------------
  /// Validates phone number: must be 10 digits and start with 0
  String? validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any spaces or special characters for validation
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // Check if it starts with 0
    if (!phone.trim().startsWith('0')) {
      return 'Phone number must start with 0';
    }

    // Check if it's exactly 10 digits (including the leading 0)
    if (cleaned.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }

    return null; // Valid
  }

  /// Validates PIN: must be exactly 4 digits
  String? validatePin(String pin) {
    if (pin.isEmpty) {
      return 'PIN is required';
    }

    // Check if it's exactly 4 digits
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return 'PIN must be exactly 4 digits';
    }

    return null; // Valid
  }

  // ---------------------------
  // SEND OTP TO PHONE
  // ---------------------------
  Future<void> sendOtp() async {
    try {
      if (phoneNumber.value.isEmpty) {
        Helper.errorSnackBar(title: 'Error', message: 'Please enter a phone number');
        return;
      }

      final phoneError = validatePhoneNumber(phoneNumber.value);
      if (phoneError != null) {
        Helper.errorSnackBar(title: 'Invalid Phone Number', message: phoneError);
        return;
      }

      _normalizePhoneNumber();
      isLoading.value = true;
      log('📱 Sending OTP to ${phoneNumber.value}');

      final result = await _phoneAuthService.sendOtp(phoneNumber.value);

      if (result['success'] == true) {
        otpSent.value = true;
        Helper.successSnackBar(
          title: 'OTP Sent',
          message: 'Verification code sent to ${phoneNumber.value}',
        );
        log('✅ OTP sent successfully');
      } else {
        throw Exception(result['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      log('❌ Error sending OTP: $e');
      Helper.errorSnackBar(title: 'Error', message: 'Failed to send OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // VERIFY OTP
  // ---------------------------
  Future<void> verifyOtp() async {
    try {
      if (phoneNumber.value.isEmpty || otp.value.isEmpty) {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'Please enter the verification code',
        );
        return;
      }

      _normalizePhoneNumber();
      isLoading.value = true;
      log('🔐 Verifying OTP for ${phoneNumber.value}');

      final result = await _phoneAuthService.verifyOtp(phoneNumber.value, otp.value);
      if (result['success'] == true) {
        otpVerified.value = true;
        Helper.successSnackBar(
          title: 'Verified',
          message: 'Phone number verified successfully',
        );
        log('✅ OTP verified successfully');
      } else {
        throw Exception(result['error'] ?? 'Invalid verification code');
      }
    } catch (e) {
      log('❌ Error verifying OTP: $e');
      Helper.errorSnackBar(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // REGISTER (Phone + PIN based)
  // ---------------------------
  Future<void> register() async {
    try {
      log("🚀 ========== REGISTRATION PROCESS STARTED ==========");

      // Validate phone number exists (format already validated during OTP send)
      if (phoneNumber.value.isEmpty) {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'Phone number is required',
        );
        return;
      }

      // Validate OTP
      if (otp.value.isEmpty) {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'OTP is required. Please verify your phone number first.',
        );
        return;
      }

      // Validate first name
      if (firstName.value.isEmpty) {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'First name is required',
        );
        return;
      }

      // Validate last name
      if (lastName.value.isEmpty) {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'Last name is required',
        );
        return;
      }

      // Validate PIN
      if (pin.value.isEmpty) {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'PIN is required. Please set your PIN before continuing.',
        );
        return;
      }

      final pinError = validatePin(pin.value);
      if (pinError != null) {
        Helper.errorSnackBar(
          title: 'Invalid PIN',
          message: pinError,
        );
        return;
      }

      // Validate account type
      if (selectedAccountType.value.isEmpty) {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'Please select an account type',
        );
        return;
      }

      _normalizePhoneNumber();
      log("📱 Phone: ${phoneNumber.value}");
      log("👤 Name: ${firstName.value} ${lastName.value}");
      log("🏷️ Account Type: ${selectedAccountType.value}");

      isLoading.value = true;

      // -------------------------------
      // Step 1: Call edge function
      // -------------------------------
      log("🔄 Step 1: Calling register-user-with-kyc edge function...");
      final result = await _phoneAuthService.registerUserWithKyc(
        phone: phoneNumber.value,
        otp: otp.value,
        firstName: firstName.value,
        lastName: lastName.value,
        pin: pin.value,
        accountType: selectedAccountType.value,
      );

      if (result['success'] != true) throw Exception(result['error'] ?? 'Registration failed');

      log("✅ Edge function completed - user created");

      // -------------------------------
      // Step 2: Re-authenticate client-side
      // -------------------------------
      final fakeEmail = result['fake_email'] as String?;
      final supabasePassword = result['supabase_password'] as String?;

      if (fakeEmail == null || supabasePassword == null) {
        throw Exception('Missing login credentials from registration response');
      }

      log("🔄 Step 2: Signing in client-side using generated credentials...");

      final authResponse = await _supabase.auth.signInWithPassword(
        email: fakeEmail,
        password: supabasePassword,
      );

      if (authResponse.session == null) {
        log("❌ Client sign-in failed after registration");
        throw Exception('Client sign-in failed after registration');
      }

      log("✅ Session set successfully client-side");
      log("🔑 Access token: ${authResponse.session!.accessToken}");

      // -------------------------------
      // Step 3: Load profile and route user
      // -------------------------------
      log("🔄 Loading user profile...");
      await loadUserProfile();
      final accountType = currentUser.value?['account_type'] ?? 'Student';
      log("✅ Profile loaded. Account type: $accountType");

      Helper.successSnackBar(
        title: 'Success',
        message: 'Account created successfully!',
      );

      resetForm();

      // Route based on account type
      final role = accountType.toString().toLowerCase().trim();
      if (role == 'student') {
        Get.offAllNamed(AppRoutes.studentHome);
      } else if (role == 'landlord') {
        Get.offAllNamed(AppRoutes.landlordHome);
      } else if (role == 'administrator') {
        Get.offAllNamed(AppRoutes.adminHome);
      } else {
        Get.offAllNamed(AppRoutes.studentHome); // Default
      }
    } catch (e) {
      log("❌ Registration error: $e");
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Handle specific error types
      if (errorMessage.contains('already exists') || errorMessage.contains('already registered')) {
        Helper.errorSnackBar(
          title: 'Registration Failed',
          message: 'This phone number is already registered. Please login instead.',
        );
      } else if (errorMessage.contains('Invalid OTP') || errorMessage.contains('OTP')) {
        Helper.errorSnackBar(
          title: 'Invalid OTP',
          message: 'The verification code is incorrect. Please try again.',
        );
      } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        Helper.errorSnackBar(
          title: 'Connection Error',
          message: 'Please check your internet connection and try again.',
        );
      } else {
        Helper.errorSnackBar(
          title: 'Registration Error',
          message: errorMessage.isNotEmpty ? errorMessage : 'Failed to create account. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // LOGIN (Phone + PIN based)
  // ---------------------------
  Future<void> login() async {
    try {
      log("🚀 ========== LOGIN PROCESS STARTED ==========");
      isLoading.value = true;

      // Validate phone number
      if (phoneNumber.value.isEmpty) {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'Please enter your phone number',
        );
        return;
      }

      final phoneError = validatePhoneNumber(phoneNumber.value);
      if (phoneError != null) {
        Helper.errorSnackBar(
          title: 'Invalid Phone Number',
          message: phoneError,
        );
        return;
      }

      // Validate PIN
      if (pin.value.isEmpty) {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'Please enter your PIN',
        );
        return;
      }

      final pinError = validatePin(pin.value);
      if (pinError != null) {
        Helper.errorSnackBar(
          title: 'Invalid PIN',
          message: pinError,
        );
        return;
      }

      // 1️⃣ Format the phone number
      _normalizePhoneNumber();

      // 2️⃣ Derive the 'fake' email and password used during registration
      final String phone = phoneNumber.value;
      final String pinValue = pin.value;

      final fakeEmail = phone.replaceAll(RegExp(r'\D'), '') + "@wallet.app";
      final supabasePassword = pinValue + "_s3cure";

      log("🔄 Attempting client-side sign-in for email: $fakeEmail");

      // 3️⃣ Sign in directly with Supabase client (uses ANON key)
      final authResponse = await _supabase.auth.signInWithPassword(
        email: fakeEmail,
        password: supabasePassword,
      );

      // 4️⃣ Check if session exists
      if (authResponse.session == null) {
        Helper.errorSnackBar(
          title: 'Login Failed',
          message: 'Invalid phone number or PIN. Please check your credentials.',
        );
        throw Exception('Login failed. Invalid credentials.');
      }

      log("✅ Login successful. Session established client-side");
      log("🔑 Access token: ${authResponse.session!.accessToken}");

      // 5️⃣ Load profile and route user
      await loadUserProfile();
      final accountType = currentUser.value?['account_type'] ?? 'Student';

      Helper.successSnackBar(
        title: 'Success',
        message: 'Welcome back!',
      );

      resetForm(); // Reset form fields

      // Route based on account type
      final role = accountType.toString().toLowerCase().trim();
      if (role == 'student') {
        Get.offAllNamed(AppRoutes.studentHome);
      } else if (role == 'landlord') {
        Get.offAllNamed(AppRoutes.landlordHome);
      } else if (role == 'administrator') {
        Get.offAllNamed(AppRoutes.adminHome);
      } else {
        Get.offAllNamed(AppRoutes.studentHome); // Default
      }
    } catch (e) {
      log("❌ Login error: $e");
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Handle specific Supabase auth errors
      if (errorMessage.contains('Invalid login credentials') ||
          errorMessage.contains('Invalid credentials') ||
          errorMessage.contains('Email not confirmed')) {
        Helper.errorSnackBar(
          title: 'Login Failed',
          message: 'Invalid phone number or PIN. Please check your credentials.',
        );
      } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        Helper.errorSnackBar(
          title: 'Connection Error',
          message: 'Please check your internet connection and try again.',
        );
      } else {
        Helper.errorSnackBar(
          title: 'Login Error',
          message: errorMessage.isNotEmpty ? errorMessage : 'Failed to log in. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // UPDATE PIN (for Forgot PIN flow)
  // ---------------------------
  Future<void> updatePin(String newPin) async {
    try {
      if (phoneNumber.value.isEmpty) {
        Helper.errorSnackBar(title: 'Error', message: 'Phone number is required');
        return;
      }

      final pinError = validatePin(newPin);
      if (pinError != null) {
        Helper.errorSnackBar(title: 'Invalid PIN', message: pinError);
        return;
      }

      isLoading.value = true;
      _normalizePhoneNumber();

      final result = await _phoneAuthService.updatePin(phoneNumber.value, newPin);

      if (result['success'] == true) {
        Helper.successSnackBar(
          title: 'Success',
          message: 'PIN updated successfully',
        );
        log('✅ PIN updated successfully');

        // Navigate back to login
        Get.offAllNamed(AppRoutes.login);
      } else {
        throw Exception(result['error'] ?? 'Failed to update PIN');
      }
    } catch (e) {
      log('❌ Error updating PIN: $e');
      Helper.errorSnackBar(title: 'Error', message: 'Failed to update PIN: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // SIGN OUT
  // ---------------------------
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      log('🚪 ========== LOGOUT PROCESS STARTED ==========');

      // Sign out from Supabase session
      log('🔐 Signing out from Supabase...');
      await _supabase.auth.signOut();
      log('✅ Supabase session cleared');

      // Clear current user
      currentUser.value = null;

      // Reset auth controller state
      log('🔄 Resetting auth form...');
      resetForm();
      log('✅ Auth form reset');

      log('✅ User signed out successfully');
      log('🏁 ========== LOGOUT COMPLETE ==========');

      // Navigate user back to the phone login screen
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      log('❌ SignOut Error: $e');
      Helper.errorSnackBar(
        title: 'Logout Error',
        message: 'Failed to logout: ${e.toString()}',
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // LOAD USER PROFILE
  // ---------------------------
  Future<void> loadUserProfile() async {
    try {
      final user = await _phoneAuthService.getUserByPhone(phoneNumber.value);
      currentUser.value = user;
    } catch (e) {
      log('❌ Error loading user profile: $e');
      rethrow;
    }
  }

  // ---------------------------
  // RESET FORM
  // ---------------------------
  void resetForm() {
    phoneNumber.value = '';
    pin.value = '';
    otp.value = '';
    firstName.value = '';
    lastName.value = '';
    selectedAccountType.value = 'Student';
    isLoading.value = false;
    otpSent.value = false;
    otpVerified.value = false;
  }

  // ---------------------------
  // ACCOUNT TYPE SELECTION
  // ---------------------------
  void setSelectedAccountType(String type) {
    selectedAccountType.value = type;
    log('Account type set to: $type');
  }

  // ---------------------------
  // CHECK IF USER IS LOGGED IN
  // ---------------------------
  Future<bool> isLoggedIn() async {
    try {
      _normalizePhoneNumber();
      final user = await _phoneAuthService.getUserByPhone(phoneNumber.value);
      return user != null;
    } catch (e) {
      log("CheckAccount Error: $e");
      return false;
    }
  }

  void _normalizePhoneNumber() {
    if (phoneNumber.value.isEmpty) return;
    phoneNumber.value = _formatPhoneE164(phoneNumber.value);
  }

  String _formatPhoneE164(String phone) {
    final trimmed = phone.trim();

    if (trimmed.isEmpty) {
      return trimmed;
    }

    if (trimmed.startsWith('+')) {
      return trimmed;
    }

    if (trimmed.startsWith('0')) {
      return '+263${trimmed.substring(1)}';
    }

    if (trimmed.startsWith('263')) {
      return '+$trimmed';
    }

    return trimmed.startsWith('+263') ? trimmed : '+263$trimmed';
  }
}
