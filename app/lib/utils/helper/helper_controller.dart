import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/theme.dart';

class Helper extends GetxController {
  /* -- ============= VALIDATIONS ================ -- */

  static String? validateEmail(value) {
    if (value == null || value.isEmpty) return 'Email cannot be empty';
    if (!GetUtils.isEmail(value)) return 'Invalid email format';
    return null;
  }

  static String? validatePassword(value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';

    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Use 8 characters, an uppercase letter, number and symbol';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }

    // Remove any spaces or special characters
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it starts with 0 and is 10 digits
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      return null;
    }

    // Check if it starts with 263 and is 12 digits
    if (cleaned.startsWith('263') && cleaned.length == 12) {
      return null;
    }

    return 'Enter a valid phone number (e.g., 0771234567)';
  }

  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN cannot be empty';
    }

    if (value.length != 4) {
      return 'PIN must be exactly 4 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'PIN must contain only numbers';
    }

    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP cannot be empty';
    }

    if (value.length != 6) {
      return 'OTP must be exactly 6 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  /* -- ============= SNACK-BARS ================ -- */

  static successSnackBar({required title, message, duration}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: whiteColor,
      backgroundColor: accentColor,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration ?? 3),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: whiteColor),
      borderRadius: 12,
    );
  }

  static warningSnackBar({required title, message, duration}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: whiteColor,
      backgroundColor: yellowColor,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration ?? 3),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.warning_rounded, color: whiteColor),
      borderRadius: 12,
    );
  }

  static errorSnackBar({required title, message, duration}) {
    Get.snackbar(
      title,
      message ?? 'An error occurred',
      isDismissible: true,
      shouldIconPulse: true,
      colorText: whiteColor,
      backgroundColor: redColor,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration ?? 3),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_rounded, color: whiteColor),
      borderRadius: 12,
    );
  }

  static modernSnackBar({required title, message, duration}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      colorText: whiteColor,
      backgroundColor: primaryColor,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration ?? 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  static fullScreenDialogLoader() {
    showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (context) {
        return Dialog(
          surfaceTintColor: Colors.transparent,
          backgroundColor: primaryColor.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: whiteColor,
                  strokeWidth: 3.0,
                ),
                SizedBox(height: 20),
                Text(
                  "Please wait...",
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideLoader() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
