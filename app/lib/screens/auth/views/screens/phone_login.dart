import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../constants/theme.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/helper/helper_controller.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  bool _obscurePin = true;

  @override
  void dispose() {
    phoneController.dispose();
    pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (phoneController.text.isEmpty) {
      Helper.errorSnackBar(
        title: 'Error',
        message: 'Please enter your phone number',
      );
      return;
    }

    if (pinController.text.isEmpty) {
      Helper.errorSnackBar(
        title: 'Error',
        message: 'Please enter your PIN',
      );
      return;
    }

    if (pinController.text.length != 4) {
      Helper.errorSnackBar(
        title: 'Error',
        message: 'PIN must be exactly 4 digits',
      );
      return;
    }

    authController.phoneNumber.value = phoneController.text;
    authController.pin.value = pinController.text;
    await authController.login();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Logo/Icon
                    _buildLogo(),

                    const SizedBox(height: 48),

                    // Welcome text
                    _buildWelcomeText(),

                    const SizedBox(height: 48),

                    // Phone input
                    _buildPhoneInput(),

                    const SizedBox(height: 24),

                    // PIN input
                    _buildPinInput(),

                    const SizedBox(height: 16),

                    // Forgot PIN
                    _buildForgotPin(),

                    const SizedBox(height: 32),

                    // Login button
                    _buildLoginButton(),

                    const SizedBox(height: 24),

                    // Sign up link
                    _buildSignUpLink(),

                    const Spacer(),

                    // Terms and privacy
                    _buildTermsAndPrivacy(),

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

  Widget _buildLogo() {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: softShadow,
      ),
      child: const Icon(
        Icons.home_rounded,
        size: 60,
        color: whiteColor,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to find your perfect room',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Container(
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
          hintText: 'Phone Number',
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
    );
  }

  Widget _buildPinInput() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
        boxShadow: softShadow,
      ),
      child: TextField(
        controller: pinController,
        obscureText: _obscurePin,
        keyboardType: TextInputType.number,
        maxLength: 4,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: charcoalBlack,
        ),
        decoration: InputDecoration(
          hintText: 'PIN',
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.4),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(14),
            child: const Icon(
              Icons.lock_rounded,
              color: primaryColor,
              size: 24,
            ),
          ),
          counterText: '',
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePin
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: charcoalBlack.withOpacity(0.5),
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _obscurePin = !_obscurePin;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPin() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Get.toNamed(AppRoutes.forgotPin);
        },
        child: const Text(
          'Forgot PIN?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => GestureDetector(
        onTap: authController.isLoading.value ? null : _handleLogin,
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
                    'Sign In',
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

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.7),
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.signup);
          },
          child: const Text(
            'Sign Up',
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

  Widget _buildTermsAndPrivacy() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: charcoalBlack.withOpacity(0.5),
      ),
    );
  }
}
