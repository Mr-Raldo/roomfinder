import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../../constants/theme.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/helper/helper_controller.dart';

class PhoneOtpVerificationScreen extends StatefulWidget {
  const PhoneOtpVerificationScreen({super.key});

  @override
  State<PhoneOtpVerificationScreen> createState() =>
      _PhoneOtpVerificationScreenState();
}

class _PhoneOtpVerificationScreenState
    extends State<PhoneOtpVerificationScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  int resendTimer = 60;
  Timer? _timer;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus OTP input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      resendTimer = 60;
      canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer > 0) {
        setState(() {
          resendTimer--;
        });
      } else {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleVerifyOtp() async {
    if (otpController.text.length != 6) {
      Helper.errorSnackBar(
        title: 'Error',
        message: 'Please enter the 6-digit code',
      );
      return;
    }

    authController.otp.value = otpController.text;
    final isNewUser = Get.arguments?['isNewUser'] ?? false;

    if (isNewUser) {
      // Edge function will verify OTP again during registration
      Helper.successSnackBar(
        title: 'Verified',
        message: 'Code accepted. Set up your PIN next.',
      );
      Get.toNamed(
        AppRoutes.pinSetup,
        arguments: {'isRegistration': true},
      );
    } else {
      // Forgot PIN flow still relies on server-side verification first
      await authController.verifyOtp();
      if (authController.otpVerified.value) {
        Get.toNamed(
          AppRoutes.pinSetup,
          arguments: {'isRegistration': false},
        );
      }
    }
  }

  Future<void> _handleResendOtp() async {
    if (!canResend) return;

    await authController.sendOtp();
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = authController.phoneNumber.value;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: charcoalBlack),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(phoneNumber),

              const SizedBox(height: 48),

              // OTP Input
              _buildOtpInput(),

              const SizedBox(height: 24),

              // Resend timer/button
              _buildResendSection(),

              const SizedBox(height: 40),

              // Verify button
              _buildVerifyButton(),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String phoneNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify Your Phone',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter the 6-digit code sent to',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phoneNumber.isEmpty ? '+263 XXX XXX XXX' : phoneNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: charcoalBlack,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: softShadow,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: buttonShadow,
      ),
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: whiteColor,
      ),
    );

    return Center(
      child: Pinput(
        controller: otpController,
        focusNode: otpFocusNode,
        length: 6,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        showCursor: true,
        onCompleted: (pin) {
          authController.otp.value = pin;
          _handleVerifyOtp();
        },
      ),
    );
  }

  Widget _buildResendSection() {
    return Center(
      child: canResend
          ? TextButton(
              onPressed: _handleResendOtp,
              child: const Text(
                'Resend Code',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            )
          : Text(
              'Resend code in ${resendTimer}s',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: charcoalBlack.withOpacity(0.5),
              ),
            ),
    );
  }

  Widget _buildVerifyButton() {
    return Obx(
      () => GestureDetector(
        onTap: authController.isLoading.value ? null : _handleVerifyOtp,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: buttonShadow,
          ),
          child: Center(
            child: authController.isLoading.value
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                    ),
                  )
                : const Text(
                    'Verify & Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: whiteColor,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
