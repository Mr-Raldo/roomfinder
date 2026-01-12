import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../../constants/theme.dart';
import '../../../../controllers/auth_controller.dart';

class ForgotPinOtpScreen extends StatefulWidget {
  const ForgotPinOtpScreen({super.key});

  @override
  State<ForgotPinOtpScreen> createState() => _ForgotPinOtpScreenState();
}

class _ForgotPinOtpScreenState extends State<ForgotPinOtpScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();
  final FocusNode newPinFocusNode = FocusNode();
  final FocusNode confirmPinFocusNode = FocusNode();

  int resendTimer = 60;
  Timer? _timer;
  bool canResend = false;
  bool otpVerified = false;

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
    newPinController.dispose();
    confirmPinController.dispose();
    otpFocusNode.dispose();
    newPinFocusNode.dispose();
    confirmPinFocusNode.dispose();
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

  // TODO: Implement verify OTP logic
  Future<void> _handleVerifyOtp() async {
    if (otpController.text.length != 6) {
      _showError('Please enter the 6-digit OTP');
      return;
    }

    // Verification logic will be implemented later
    print('Verify OTP button pressed');
    print('OTP: ${otpController.text}');

    // Simulate successful verification
    setState(() {
      otpVerified = true;
    });
    newPinFocusNode.requestFocus();
  }

  // TODO: Implement update PIN logic
  Future<void> _handleUpdatePin() async {
    if (!otpVerified) {
      _showError('Please verify OTP first');
      return;
    }

    if (newPinController.text.length != 4) {
      _showError('Please enter a 4-digit PIN');
      return;
    }

    if (confirmPinController.text.length != 4) {
      _showError('Please confirm your PIN');
      return;
    }

    if (newPinController.text != confirmPinController.text) {
      _showError('PINs do not match');
      return;
    }

    // Update PIN logic will be implemented later
    print('Update PIN button pressed');
    print('New PIN: ${newPinController.text}');

    // Navigate back to login
    // Get.offAllNamed(AppRoutes.login);
  }

  // TODO: Implement resend OTP logic
  Future<void> _handleResendOtp() async {
    if (!canResend) return;

    // Resend logic will be implemented later
    print('Resend OTP button pressed');
    _startResendTimer();
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: redColor,
      colorText: whiteColor,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(phoneNumber),

                const SizedBox(height: 48),

                // OTP Input
                if (!otpVerified) ...[
                  _buildOtpInput(),
                  const SizedBox(height: 24),
                  _buildResendSection(),
                  const SizedBox(height: 40),
                  _buildVerifyButton(),
                ],

                // New PIN Input (shown after OTP verification)
                if (otpVerified) ...[
                  _buildPinInputSection(
                    label: 'New PIN',
                    controller: newPinController,
                    focusNode: newPinFocusNode,
                    onCompleted: (_) {
                      confirmPinFocusNode.requestFocus();
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildPinInputSection(
                    label: 'Confirm New PIN',
                    controller: confirmPinController,
                    focusNode: confirmPinFocusNode,
                    onCompleted: (_) {
                      _handleUpdatePin();
                    },
                  ),
                  const SizedBox(height: 40),
                  _buildUpdatePinButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String phoneNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          otpVerified ? 'Create New PIN' : 'Verify Your Phone',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          otpVerified
              ? 'Enter your new 4-digit PIN'
              : 'Enter the 6-digit code sent to',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.6),
          ),
        ),
        if (!otpVerified) ...[
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

  Widget _buildPinInputSection({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onCompleted,
  }) {
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
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
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: whiteColor,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: charcoalBlack,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Pinput(
            controller: controller,
            focusNode: focusNode,
            length: 4,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            obscureText: true,
            obscuringCharacter: '●',
            showCursor: true,
            onCompleted: onCompleted,
          ),
        ),
      ],
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

  Widget _buildUpdatePinButton() {
    return Obx(
      () => GestureDetector(
        onTap: authController.isLoading.value ? null : _handleUpdatePin,
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
                    'Update PIN',
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
