import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../../constants/theme.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../utils/helper/helper_controller.dart';

class PhonePinSetupScreen extends StatefulWidget {
  const PhonePinSetupScreen({super.key});

  @override
  State<PhonePinSetupScreen> createState() => _PhonePinSetupScreenState();
}

class _PhonePinSetupScreenState extends State<PhonePinSetupScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();
  final FocusNode confirmPinFocusNode = FocusNode();

  bool _isPinSet = false;
  String _firstPin = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus PIN input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    pinFocusNode.dispose();
    confirmPinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handlePinComplete(String pin) async {
    if (!_isPinSet) {
      // First PIN entry
      setState(() {
        _isPinSet = true;
        _firstPin = pin;
      });
      Helper.successSnackBar(
        title: 'Step 1 Complete',
        message: 'Now confirm your PIN',
      );
      confirmPinFocusNode.requestFocus();
    } else {
      // Confirmation PIN entry
      if (pin == _firstPin) {
        authController.pin.value = pin;

        // Check if this is registration or PIN reset
        final isRegistration = Get.arguments?['isRegistration'] ?? false;

        if (isRegistration) {
          await authController.register();
        } else {
          await authController.updatePin(pin);
        }
      } else {
        Helper.errorSnackBar(
          title: 'Error',
          message: 'PINs do not match. Please try again.',
        );
        setState(() {
          _isPinSet = false;
          _firstPin = '';
        });
        pinController.clear();
        confirmPinController.clear();
        pinFocusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),

              const SizedBox(height: 48),

              // PIN Input
              _buildPinInputSection(
                label: _isPinSet ? 'Confirm PIN' : 'Create PIN',
                controller: _isPinSet ? confirmPinController : pinController,
                focusNode: _isPinSet ? confirmPinFocusNode : pinFocusNode,
                onCompleted: (pin) {
                  _handlePinComplete(pin);
                },
              ),

              const SizedBox(height: 24),

              // PIN requirements
              _buildPinRequirements(),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isPinSet ? 'Confirm Your PIN' : 'Create Your PIN',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isPinSet
              ? 'Re-enter your 4-digit PIN to confirm'
              : 'Create a secure 4-digit PIN for quick login',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.6),
          ),
        ),
      ],
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

  Widget _buildPinRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: skyBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your PIN must be exactly 4 digits and will be used for secure login',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: charcoalBlack.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
