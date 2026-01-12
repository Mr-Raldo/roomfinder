import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/landlord_bottom_nav.dart';

class LandlordHomeScreen extends StatelessWidget {
  const LandlordHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final userName = authController.currentUser.value?['first_name'] ?? 'Landlord';

    return Scaffold(
      backgroundColor: screenBGColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          'Room Finder - Landlord',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: primaryColor),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: primaryColor),
            onPressed: () => Get.toNamed('/landlord-profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                _buildWelcomeHeader(userName),

                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsCards(),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(),

                const SizedBox(height: 24),

                // My Listings Section
                _buildSectionHeader('My Listings'),
                const SizedBox(height: 16),
                _buildListings(),

                const SizedBox(height: 24),

                // Recent Inquiries
                _buildSectionHeader('Recent Inquiries'),
                const SizedBox(height: 16),
                _buildRecentInquiries(),

                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(authController),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/landlord-add-property'),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: whiteColor),
        label: const Text(
          'Add Listing',
          style: TextStyle(color: whiteColor, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: const LandlordBottomNav(currentIndex: 0),
    );
  }

  Widget _buildWelcomeHeader(String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoalBlack.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your property listings',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('houses')
          .stream(primaryKey: ['id'])
          .eq('landlord_id', userId ?? ''),
      builder: (context, snapshot) {
        final totalListings = snapshot.hasData ? snapshot.data!.length : 0;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.home_work_rounded,
                title: 'Total Listings',
                value: '$totalListings',
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('viewing_history')
                    .stream(primaryKey: ['id'])
                    .eq('house_id', userId ?? ''),
                builder: (context, viewsSnapshot) {
                  final totalViews = viewsSnapshot.hasData ? viewsSnapshot.data!.length : 0;
                  return _buildStatCard(
                    icon: Icons.visibility_rounded,
                    title: 'Total Views',
                    value: '$totalViews',
                    color: accentColor,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('bookings')
                    .stream(primaryKey: ['id'])
                    .eq('booking_status', 'pending'),
                builder: (context, inquiriesSnapshot) {
                  final totalInquiries = inquiriesSnapshot.hasData ? inquiriesSnapshot.data!.length : 0;
                  return _buildStatCard(
                    icon: Icons.message_rounded,
                    title: 'Inquiries',
                    value: '$totalInquiries',
                    color: yellowColor,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: charcoalBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: charcoalBlack.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline,
            title: 'New Listing',
            gradient: primaryGradient,
            onTap: () => Get.toNamed('/landlord-add-property'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.analytics_outlined,
            title: 'Analytics',
            gradient: const LinearGradient(
              colors: [accentColor, Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {
              // TODO: Show analytics
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: buttonShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: whiteColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed('/landlord-properties'),
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListings() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return const Center(
        child: Text('Please log in to view your listings'),
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('houses')
          .stream(primaryKey: ['id'])
          .eq('landlord_id', userId)
          .order('created_at', ascending: false)
          .limit(3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No listings yet. Add your first property!',
              style: TextStyle(color: charcoalBlack.withOpacity(0.6)),
            ),
          );
        }

        final listings = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            final title = listing['title'] ?? 'Untitled Property';
            final location = listing['city'] ?? 'Unknown';
            final isActive = listing['is_active'] ?? false;
            final imageUrl = listing['cover_image_url'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: imageUrl != null ? null : primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? const Icon(Icons.home_rounded, color: whiteColor, size: 36)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: charcoalBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: charcoalBlack.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: charcoalBlack.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? accentColor.withOpacity(0.1)
                                    : greyColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? accentColor : greyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentInquiries() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('booking_status', 'pending')
          .order('created_at', ascending: false)
          .limit(3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: softShadow,
            ),
            child: Center(
              child: Text(
                'No recent inquiries',
                style: TextStyle(color: charcoalBlack.withOpacity(0.6)),
              ),
            ),
          );
        }

        final inquiries = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: softShadow,
          ),
          child: Column(
            children: inquiries.asMap().entries.map((entry) {
              final index = entry.key;
              final inquiry = entry.value;
              final studentId = inquiry['student_id'] ?? '';
              final createdAt = inquiry['created_at'];

              String timeAgo = 'Recently';
              if (createdAt != null) {
                final created = DateTime.parse(createdAt);
                final diff = DateTime.now().difference(created);
                if (diff.inHours < 1) {
                  timeAgo = '${diff.inMinutes} minutes ago';
                } else if (diff.inHours < 24) {
                  timeAgo = '${diff.inHours} hours ago';
                } else {
                  timeAgo = '${diff.inDays} days ago';
                }
              }

              return Column(
                children: [
                  if (index > 0) const Divider(height: 24),
                  _buildInquiryItem(
                    studentId.substring(0, 8),
                    'New booking request',
                    timeAgo,
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildInquiryItem(String name, String message, String time) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: primaryColor.withOpacity(0.1),
          child: const Icon(Icons.person, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: charcoalBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: charcoalBlack.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color: charcoalBlack.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: greyColor),
      ],
    );
  }

  Widget _buildLogoutButton(AuthController authController) {
    return GestureDetector(
      onTap: () => authController.signOut(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: redColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: redColor.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: redColor, size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: redColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_rounded, 'Dashboard', true),
              _buildNavItem(Icons.home_work_rounded, 'Listings', false),
              _buildNavItem(Icons.message_rounded, 'Messages', false),
              _buildNavItem(Icons.analytics_rounded, 'Analytics', false),
              _buildNavItem(Icons.person_outline_rounded, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? primaryColor : greyColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? primaryColor : greyColor,
          ),
        ),
      ],
    );
  }
}
