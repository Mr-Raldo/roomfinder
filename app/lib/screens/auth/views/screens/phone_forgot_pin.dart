import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/theme.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/helper/helper_controller.dart';

class PhoneForgotPinScreen extends StatefulWidget {
  const PhoneForgotPinScreen({super.key});

  @override
  State<PhoneForgotPinScreen> createState() => _PhoneForgotPinScreenState();
}

class _PhoneForgotPinScreenState extends State<PhoneForgotPinScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (phoneController.text.isEmpty) {
      Helper.errorSnackBar(
        title: 'Error',
        message: 'Please enter your phone number',
      );
      return;
    }

    // Set phone number in auth controller
    authController.phoneNumber.value = phoneController.text;

    // Send OTP
    await authController.sendOtp();

    // Navigate to OTP verification screen for forgot PIN if OTP was sent
    if (authController.otpSent.value) {
      Get.toNamed(
        AppRoutes.otpVerification,
        arguments: {'isNewUser': false},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),

                    const SizedBox(height: 48),

                    // Info card
                    _buildInfoCard(),

                    const SizedBox(height: 32),

                    // Phone input
                    _buildPhoneInput(),

                    const SizedBox(height: 40),

                    // Continue button
                    _buildContinueButton(),

                    const Spacer(),

                    // Back to login link
                    _buildBackToLoginLink(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Forgot PIN?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'No worries, we\'ll help you reset it',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: subtleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: softShadow,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reset Your PIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: charcoalBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We\'ll send a verification code to your phone',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: charcoalBlack.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: charcoalBlack,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
            boxShadow: softShadow,
          ),
          child: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: charcoalBlack,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your registered phone number',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: charcoalBlack.withOpacity(0.4),
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(14),
                child: const Icon(
                  Icons.phone_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Obx(
      () => GestureDetector(
        onTap: authController.isLoading.value ? null : _handleSendOtp,
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
                    'Send Verification Code',
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

  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Remember your PIN? ",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.7),
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
