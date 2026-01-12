import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/modern_bottom_nav.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final userName = authController.currentUser.value?['first_name'] ?? 'Student';

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
          'Room Finder',
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
            onPressed: () {
              // TODO: Navigate to profile
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

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(),

                const SizedBox(height: 24),

                // Featured Rooms Section
                _buildSectionHeader('Featured Rooms'),
                const SizedBox(height: 16),
                _buildFeaturedRooms(),

                const SizedBox(height: 24),

                // Recent Searches
                _buildSectionHeader('Recent Searches'),
                const SizedBox(height: 16),
                _buildRecentSearches(),

                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(authController),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ModernBottomNav(currentIndex: 0),
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
          'Find your perfect room today',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for rooms...',
          hintStyle: TextStyle(
            fontSize: 15,
            color: charcoalBlack.withOpacity(0.4),
          ),
          prefixIcon: const Icon(Icons.search, color: primaryColor),
          suffixIcon: const Icon(Icons.tune, color: primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onTap: () {
          // TODO: Navigate to search screen
        },
        readOnly: true,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.location_on_rounded,
            title: 'Near Me',
            color: primaryColor,
            onTap: () {
              // TODO: Show rooms near user
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.favorite_border_rounded,
            title: 'Favorites',
            color: redColor,
            onTap: () {
              // TODO: Show saved rooms
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.history_rounded,
            title: 'History',
            color: accentColor,
            onTap: () {
              // TODO: Show viewing history
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
            Icon(icon, color: whiteColor, size: 28),
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

  Widget _buildFeaturedRooms() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('houses')
          .stream(primaryKey: ['id'])
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 230,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 230,
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: softShadow,
            ),
            child: Center(
              child: Text(
                'No rooms available yet',
                style: TextStyle(color: charcoalBlack.withOpacity(0.6)),
              ),
            ),
          );
        }

        final rooms = snapshot.data!;

        return SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final title = room['title'] ?? 'Untitled Property';
              final city = room['city'] ?? 'Unknown';
              final price = room['price_per_month'] ?? 0;
              final imageUrl = room['cover_image_url'];

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: softShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: imageUrl != null ? null : primaryGradient,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        image: imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageUrl == null
                          ? const Center(
                              child: Icon(Icons.home_rounded, size: 50, color: whiteColor),
                            )
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                  city,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${price.toStringAsFixed(0)}/month',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                              const Icon(Icons.favorite_border, color: redColor, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('viewing_history')
          .stream(primaryKey: ['id'])
          .eq('student_id', userId)
          .order('viewed_at', ascending: false)
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
                'No recent searches',
                style: TextStyle(color: charcoalBlack.withOpacity(0.6)),
              ),
            ),
          );
        }

        final searches = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: softShadow,
          ),
          child: Column(
            children: searches.asMap().entries.map((entry) {
              final index = entry.key;
              final search = entry.value;
              final houseId = search['house_id'];
              final viewedAt = search['viewed_at'];

              String timeAgo = 'Recently';
              if (viewedAt != null) {
                final viewed = DateTime.parse(viewedAt);
                final diff = DateTime.now().difference(viewed);
                if (diff.inMinutes < 60) {
                  timeAgo = '${diff.inMinutes} min ago';
                } else if (diff.inHours < 24) {
                  timeAgo = '${diff.inHours} hours ago';
                } else if (diff.inDays < 7) {
                  timeAgo = '${diff.inDays} days ago';
                } else {
                  timeAgo = '${(diff.inDays / 7).floor()} weeks ago';
                }
              }

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getHouseDetails(houseId),
                builder: (context, houseSnapshot) {
                  final houseTitle = houseSnapshot.data?['title'] ?? 'Property';

                  return Column(
                    children: [
                      if (index > 0) const Divider(height: 24),
                      _buildSearchItem(houseTitle, timeAgo),
                    ],
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getHouseDetails(String houseId) async {
    try {
      final response = await Supabase.instance.client
          .from('houses')
          .select('title, city')
          .eq('id', houseId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Widget _buildSearchItem(String title, String time) {
    return Row(
      children: [
        const Icon(Icons.history, color: primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: charcoalBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: charcoalBlack.withOpacity(0.5),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', true, () {}),
              _buildNavItem(Icons.search_rounded, 'Search', false, () => Get.toNamed('/student-search')),
              _buildNavItem(Icons.favorite_border_rounded, 'Saved', false, () => Get.toNamed('/student-saved')),
              _buildNavItem(Icons.chat_bubble_outline_rounded, 'Messages', false, () => Get.toNamed('/student-messages')),
              _buildNavItem(Icons.person_outline_rounded, 'Profile', false, () => Get.toNamed('/student-profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
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
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
