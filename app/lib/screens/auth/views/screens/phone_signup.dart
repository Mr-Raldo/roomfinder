import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/theme.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/helper/helper_controller.dart';

class PhoneSignupScreen extends StatefulWidget {
  const PhoneSignupScreen({super.key});

  @override
  State<PhoneSignupScreen> createState() => _PhoneSignupScreenState();
}

class _PhoneSignupScreenState extends State<PhoneSignupScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController accessCodeController = TextEditingController();

  final List<String> accountTypes = ['Student', 'Landlord', 'Administrator'];

  @override
  void dispose() {
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    accessCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    // Validate phone number
    if (phoneController.text.trim().isEmpty) {
      Helper.errorSnackBar(
        title: 'Error',
        message: 'Please enter your phone number',
      );
      return;
    }

    // Validate first name
    if (firstNameController.text.trim().isEmpty) {
      Helper.errorSnackBar(
        title: 'Error',
        message: 'Please enter your first name',
      );
      return;
    }

    // Validate last name
    if (lastNameController.text.trim().isEmpty) {
      Helper.errorSnackBar(
        title: 'Error',
        message: 'Please enter your last name',
      );
      return;
    }

    // Validate account type selection
    if (authController.selectedAccountType.value.isEmpty) {
      Helper.errorSnackBar(
        title: 'Error',
        message: 'Please select an account type',
      );
      return;
    }

    // Validate access code for Admin and Landlord
    final accountType = authController.selectedAccountType.value;

    if (accountType == 'Administrator') {
      if (accessCodeController.text != 'ADMIN2026') {
        Helper.errorSnackBar(
          title: 'Invalid Access Code',
          message: 'Please enter the correct access code for Administrator',
        );
        return;
      }
    } else if (accountType == 'Landlord') {
      if (accessCodeController.text != 'HIT2026') {
        Helper.errorSnackBar(
          title: 'Invalid Access Code',
          message: 'Please enter the correct access code for Landlord',
        );
        return;
      }
    }

    // Store data in auth controller
    authController.phoneNumber.value = phoneController.text.trim();
    authController.firstName.value = firstNameController.text.trim();
    authController.lastName.value = lastNameController.text.trim();

    // Send OTP
    await authController.sendOtp();

    // Navigate to OTP verification screen if OTP was sent successfully
    if (authController.otpSent.value) {
      Get.toNamed(
        AppRoutes.otpVerification,
        arguments: {'isNewUser': true},
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

                    const SizedBox(height: 40),

                    // Account Type
                    _buildAccountTypeSelector(),

                    // Access Code (conditional)
                    Obx(() {
                      final accountType = authController.selectedAccountType.value;
                      if (accountType == 'Administrator' || accountType == 'Landlord') {
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildInputField(
                              controller: accessCodeController,
                              label: 'Access Code',
                              hint: 'Enter access code',
                              icon: Icons.lock_rounded,
                              keyboardType: TextInputType.text,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 20),

                    // First Name
                    _buildInputField(
                      controller: firstNameController,
                      label: 'First Name',
                      hint: 'Enter your first name',
                      icon: Icons.person_rounded,
                    ),

                    const SizedBox(height: 20),

                    // Last Name
                    _buildInputField(
                      controller: lastNameController,
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      icon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 20),

                    // Phone Number
                    _buildInputField(
                      controller: phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 40),

                    // Continue Button
                    _buildContinueButton(),

                    const SizedBox(height: 24),

                    // Sign in link
                    _buildSignInLink(),

                    const Spacer(),
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
          'Create Account',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join Room Finder to discover your ideal space',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: charcoalBlack,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: charcoalBlack.withOpacity(0.4),
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(14),
                child: Icon(
                  icon,
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

  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I am a',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: charcoalBlack,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: accountTypes.map((type) {
              final isSelected = authController.selectedAccountType.value == type;
              return GestureDetector(
                onTap: () {
                  authController.selectedAccountType.value = type;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? primaryGradient : null,
                    color: isSelected ? null : whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: isSelected ? buttonShadow : softShadow,
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? whiteColor : charcoalBlack,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Obx(
      () => GestureDetector(
        onTap: authController.isLoading.value ? null : _handleContinue,
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
                    'Continue',
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

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
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
