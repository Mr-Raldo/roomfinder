import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class PhoneAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Encryption key for PIN storage (use same key as backend for consistency)
  static const String _encryptionKey = 'your-32-character-secret-key!!'; // TODO: Move to env

  /// Send OTP to phone number via Edge Function
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      log('📱 Sending OTP to $phone');

      final response = await _supabase.functions.invoke(
        'send-otp-notifytext',
        body: {'phone': phone},
      );

      if (response.data == null) {
        throw Exception('Failed to send OTP: No response from server');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        log('✅ OTP sent successfully');
        return {
          'success': true,
          'message': data['message'],
          'expiresIn': data['expiresIn'],
        };
      } else {
        throw Exception(data['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      log('❌ Error sending OTP: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Verify OTP code via Edge Function
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      log('🔐 Verifying OTP for $phone');

      final response = await _supabase.functions.invoke(
        'verify-otp',
        body: {
          'phone': phone,
          'otp': otp,
        },
      );

      if (response.data == null) {
        throw Exception('Failed to verify OTP: No response from server');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        log('✅ OTP verified successfully');
        return {
          'success': true,
          'message': data['message'],
          'phone': data['phone'],
        };
      } else {
        throw Exception(data['error'] ?? 'Invalid OTP');
      }
    } catch (e) {
      log('❌ Error verifying OTP: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Encrypt PIN for secure storage
  String encryptPin(String pin) {
    final key = encrypt.Key.fromUtf8(_encryptionKey.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(pin, iv: iv);
    return encrypted.base64;
  }

  /// Decrypt PIN for verification
  String decryptPin(String encryptedPin) {
    try {
      final key = encrypt.Key.fromUtf8(_encryptionKey.padRight(32, '0').substring(0, 32));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt64(encryptedPin, iv: iv);
      return decrypted;
    } catch (e) {
      log('❌ Error decrypting PIN: $e');
      return '';
    }
  }

  /// Check if user exists by phone number
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      log('👤 Checking if user exists: $phone');

      final response = await _supabase
          .from('rf_user_profile')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (response == null) {
        log('ℹ️ No user found with phone $phone');
        return null;
      }

      log('✅ User found: ${response['id']}');
      return response;
    } catch (e) {
      log('❌ Error fetching user: $e');
      return null;
    }
  }

  /// Call edge function to register user with Supabase Auth + user profile
  Future<Map<String, dynamic>> registerUserWithKyc({
    required String phone,
    required String otp,
    required String firstName,
    required String lastName,
    required String pin,
    required String accountType,
  }) async {
    try {
      log('🆕 Registering user via register-user-with-kyc function');
      final response = await _supabase.functions.invoke(
        'register-user-with-kyc',
        body: {
          'phone': phone,
          'otp': otp,
          'first_name': firstName,
          'last_name': lastName,
          'pin': pin,
          'account_type': accountType,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('register-user-with-kyc returned no data');
      }

      return data;
    } catch (e) {
      log('❌ registerUserWithKyc error: $e');
      rethrow;
    }
  }

  /// Verify PIN for login
  Future<bool> verifyPin(String phone, String inputPin) async {
    try {
      log('🔐 Verifying PIN for $phone');

      final user = await getUserByPhone(phone);

      if (user == null) {
        log('❌ User not found');
        return false;
      }

      final storedEncryptedPin = user['pin'] as String?;

      if (storedEncryptedPin == null) {
        log('❌ No PIN set for user');
        return false;
      }

      final decryptedPin = decryptPin(storedEncryptedPin);
      final isValid = decryptedPin == inputPin;

      log(isValid ? '✅ PIN verified' : '❌ Invalid PIN');
      return isValid;
    } catch (e) {
      log('❌ Error verifying PIN: $e');
      return false;
    }
  }

  /// Update user PIN (for reset functionality)
  Future<Map<String, dynamic>> updatePin(String phone, String newPin) async {
    try {
      log('🔐 Updating PIN for $phone');

      final encryptedPin = encryptPin(newPin);

      final response = await _supabase
          .from('rf_user_profile')
          .update({'pin': encryptedPin})
          .eq('phone', phone)
          .select()
          .single();

      log('✅ PIN updated successfully');

      return {
        'success': true,
        'user': response,
      };
    } catch (e) {
      log('❌ Error updating PIN: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Complete login flow: phone + PIN
  Future<Map<String, dynamic>> loginWithPhoneAndPin(String phone, String pin) async {
    try {
      log('🔑 Logging in with phone and PIN');

      // Verify PIN
      final isPinValid = await verifyPin(phone, pin);

      if (!isPinValid) {
        throw Exception('Invalid phone number or PIN');
      }

      // Get user profile
      final user = await getUserByPhone(phone);

      if (user == null) {
        throw Exception('User not found');
      }

      log('✅ Login successful');

      return {
        'success': true,
        'user': user,
      };
    } catch (e) {
      log('❌ Login error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Call edge function to login user
  Future<Map<String, dynamic>> loginHandler({
    required String phone,
    required String pin,
  }) async {
    try {
      log('🔑 Logging in via loginHandler edge function');
      final response = await _supabase.functions.invoke(
        'loginHandler',
        body: {
          'phone': phone,
          'pin': pin,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('loginHandler returned no data');
      }

      return data;
    } catch (e) {
      log('❌ loginHandler error: $e');
      rethrow;
    }
  }
}
