import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/theme.dart';
import '../../controllers/auth_controller.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final userName = authController.currentUser.value?['first_name'] ?? 'Admin';

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
          'Room Finder - Admin',
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
            icon: const Icon(Icons.settings_outlined, color: primaryColor),
            onPressed: () {
              // TODO: Navigate to settings
            },
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

                // Stats Overview
                _buildStatsOverview(),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(),

                const SizedBox(height: 24),

                // Recent Activities
                _buildSectionHeader('Recent Activities'),
                const SizedBox(height: 16),
                _buildRecentActivities(),

                const SizedBox(height: 24),

                // System Status
                _buildSectionHeader('System Status'),
                const SizedBox(height: 16),
                _buildSystemStatus(),

                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(authController),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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
          'System Administrator Panel',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('user_profiles')
                    .stream(primaryKey: ['id']),
                builder: (context, snapshot) {
                  final totalUsers = snapshot.hasData ? snapshot.data!.length : 0;
                  return _buildStatCard(
                    icon: Icons.people_rounded,
                    title: 'Total Users',
                    value: totalUsers.toString(),
                    color: primaryColor,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('houses')
                    .stream(primaryKey: ['id']),
                builder: (context, snapshot) {
                  final totalListings = snapshot.hasData ? snapshot.data!.length : 0;
                  return _buildStatCard(
                    icon: Icons.home_work_rounded,
                    title: 'Total Listings',
                    value: totalListings.toString(),
                    color: accentColor,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('houses')
                    .stream(primaryKey: ['id'])
                    .eq('is_active', false),
                builder: (context, snapshot) {
                  final pendingApprovals = snapshot.hasData ? snapshot.data!.length : 0;
                  return _buildStatCard(
                    icon: Icons.pending_actions_rounded,
                    title: 'Pending Approvals',
                    value: pendingApprovals.toString(),
                    color: yellowColor,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('reports')
                    .stream(primaryKey: ['id'])
                    .eq('status', 'pending'),
                builder: (context, snapshot) {
                  final reports = snapshot.hasData ? snapshot.data!.length : 0;
                  return _buildStatCard(
                    icon: Icons.report_problem_rounded,
                    title: 'Reports',
                    value: reports.toString(),
                    color: redColor,
                  );
                },
              ),
            ),
          ],
        ),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: charcoalBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: charcoalBlack.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.person_add_rounded,
                title: 'Manage Users',
                color: primaryColor,
                onTap: () {
                  // TODO: Navigate to user management
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.home_work_rounded,
                title: 'Manage Listings',
                color: accentColor,
                onTap: () {
                  // TODO: Navigate to listings management
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.flag_rounded,
                title: 'Reports',
                color: redColor,
                onTap: () {
                  // TODO: Navigate to reports
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics_rounded,
                title: 'Analytics',
                color: yellowColor,
                onTap: () {
                  // TODO: Navigate to analytics
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: softShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: whiteColor, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: whiteColor,
              ),
              textAlign: TextAlign.center,
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
          onPressed: () {
            // TODO: View all
          },
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

  Widget _buildRecentActivities() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('user_profiles')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .limit(5),
      builder: (context, userSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: Supabase.instance.client
              .from('houses')
              .stream(primaryKey: ['id'])
              .order('created_at', ascending: false)
              .limit(5),
          builder: (context, houseSnapshot) {
            final List<Map<String, dynamic>> activities = [];

            if (userSnapshot.hasData) {
              for (var user in userSnapshot.data!) {
                activities.add({
                  'type': 'user',
                  'data': user,
                  'timestamp': user['created_at'],
                });
              }
            }

            if (houseSnapshot.hasData) {
              for (var house in houseSnapshot.data!) {
                activities.add({
                  'type': 'house',
                  'data': house,
                  'timestamp': house['created_at'],
                });
              }
            }

            activities.sort((a, b) {
              final aTime = DateTime.parse(a['timestamp'] ?? DateTime.now().toIso8601String());
              final bTime = DateTime.parse(b['timestamp'] ?? DateTime.now().toIso8601String());
              return bTime.compareTo(aTime);
            });

            final recentActivities = activities.take(3).toList();

            if (recentActivities.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: softShadow,
                ),
                child: Center(
                  child: Text(
                    'No recent activities',
                    style: TextStyle(color: charcoalBlack.withOpacity(0.6)),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: softShadow,
              ),
              child: Column(
                children: recentActivities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  final type = activity['type'];
                  final data = activity['data'];
                  final timestamp = activity['timestamp'];

                  String timeAgo = 'Recently';
                  if (timestamp != null) {
                    final created = DateTime.parse(timestamp);
                    final diff = DateTime.now().difference(created);
                    if (diff.inMinutes < 60) {
                      timeAgo = '${diff.inMinutes} min ago';
                    } else if (diff.inHours < 24) {
                      timeAgo = '${diff.inHours} hours ago';
                    } else {
                      timeAgo = '${diff.inDays} days ago';
                    }
                  }

                  if (type == 'user') {
                    final firstName = data['first_name'] ?? 'User';
                    final accountType = data['account_type'] ?? 'Student';
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 24),
                        _buildActivityItem(
                          Icons.person_add_rounded,
                          'New user registered',
                          '$firstName joined as $accountType',
                          timeAgo,
                          primaryColor,
                        ),
                      ],
                    );
                  } else {
                    final title = data['title'] ?? 'Property';
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 24),
                        _buildActivityItem(
                          Icons.home_rounded,
                          'New listing added',
                          title,
                          timeAgo,
                          accentColor,
                        ),
                      ],
                    );
                  }
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String subtitle,
    String time,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: charcoalBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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
      ],
    );
  }

  Widget _buildSystemStatus() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('houses')
          .stream(primaryKey: ['id'])
          .eq('is_active', true),
      builder: (context, activeHousesSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: Supabase.instance.client
              .from('bookings')
              .stream(primaryKey: ['id']),
          builder: (context, bookingsSnapshot) {
            final activeListings = activeHousesSnapshot.hasData ? activeHousesSnapshot.data!.length : 0;
            final totalBookings = bookingsSnapshot.hasData ? bookingsSnapshot.data!.length : 0;

            final pendingBookings = bookingsSnapshot.hasData
                ? bookingsSnapshot.data!.where((b) => b['booking_status'] == 'pending').length
                : 0;

            final confirmedBookings = bookingsSnapshot.hasData
                ? bookingsSnapshot.data!.where((b) => b['booking_status'] == 'confirmed').length
                : 0;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: softShadow,
              ),
              child: Column(
                children: [
                  _buildStatusItem('Active Listings', activeListings.toString(), accentColor),
                  const Divider(height: 20),
                  _buildStatusItem('Total Bookings', totalBookings.toString(), primaryColor),
                  const Divider(height: 20),
                  _buildStatusItem('Pending Bookings', pendingBookings.toString(), yellowColor),
                  const Divider(height: 20),
                  _buildStatusItem('Confirmed Bookings', confirmedBookings.toString(), accentColor),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusItem(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: charcoalBlack,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
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
}
