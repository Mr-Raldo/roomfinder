import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/landlord_bottom_nav.dart';

class LandlordProfileScreen extends StatelessWidget {
  const LandlordProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final userName = authController.currentUser.value?['first_name'] ?? 'Landlord';
    final userEmail = authController.currentUser.value?['email'] ?? 'landlord@example.com';

    return Scaffold(
      backgroundColor: screenBGColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: primaryColor),
            onPressed: () {
              // TODO: Edit profile
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildProfileHeader(userName, userEmail),
              const SizedBox(height: 24),
              _buildProfileOptions(authController),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const LandlordBottomNav(currentIndex: 3),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [accentColor, Color(0xFF66BB6A), primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: whiteColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: whiteColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: whiteColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: whiteColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user, color: whiteColor, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Verified Landlord',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: whiteColor,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(AuthController authController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      ),
      child: Column(
        children: [
          _buildOptionItem(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Update your details',
            onTap: () {
              // TODO: Navigate to personal info
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.home_work_outlined,
            title: 'My Properties',
            subtitle: 'Manage your listings',
            onTap: () {
              Get.toNamed('/landlord-properties');
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.payment_outlined,
            title: 'Payment & Banking',
            subtitle: 'Manage payment methods',
            onTap: () {
              // TODO: Navigate to payment settings
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.analytics_outlined,
            title: 'Analytics',
            subtitle: 'View performance statistics',
            onTap: () {
              // TODO: Navigate to analytics
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Manage your privacy settings',
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help or contact us',
            onTap: () {
              // TODO: Navigate to help
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              // TODO: Show about dialog
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(authController),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? redColor.withOpacity(0.1)
                    : accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? redColor : accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? redColor : charcoalBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: charcoalBlack.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? redColor : greyColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: greyColor.withOpacity(0.2),
      indent: 16,
      endIndent: 16,
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: redColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  size: 48,
                  color: redColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: charcoalBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 15,
                  color: charcoalBlack.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: charcoalBlack,
                        side: BorderSide(color: greyColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        authController.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redColor,
                        foregroundColor: whiteColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
