import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/theme.dart';
import '../../widgets/modern_bottom_nav.dart';

class StudentMessagesScreen extends StatelessWidget {
  const StudentMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Messages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: primaryColor),
            onPressed: () {
              // TODO: Search messages
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildMessagesList(),
      ),
      bottomNavigationBar: const ModernBottomNav(currentIndex: 3),
    );
  }

  Widget _buildMessagesList() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return _buildEmptyState();
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('chat_conversations')
          .stream(primaryKey: ['id'])
          .eq('student_id', userId)
          .order('last_message_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final conversations = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            final landlordId = conversation['landlord_id'];
            final lastMessage = conversation['last_message_text'] ?? '';
            final lastMessageAt = conversation['last_message_at'];
            final unreadCount = conversation['student_unread_count'] ?? 0;
            final isUnread = unreadCount > 0;

            String timeAgo = 'Recently';
            if (lastMessageAt != null) {
              final lastMsgTime = DateTime.parse(lastMessageAt);
              final diff = DateTime.now().difference(lastMsgTime);
              if (diff.inMinutes < 60) {
                timeAgo = '${diff.inMinutes} min ago';
              } else if (diff.inHours < 24) {
                timeAgo = '${diff.inHours}h ago';
              } else {
                timeAgo = '${diff.inDays}d ago';
              }
            }

            return FutureBuilder<String>(
              future: _getLandlordName(landlordId),
              builder: (context, landlordSnapshot) {
                final landlordName = landlordSnapshot.data ?? 'Landlord';
                final colors = [primaryColor, accentColor, redColor];
                final avatarColor = colors[index % 3];

                return _buildMessageItem(
                  name: landlordName,
                  message: lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                  time: timeAgo,
                  isUnread: isUnread,
                  avatarColor: avatarColor,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<String> _getLandlordName(String landlordId) async {
    try {
      final landlordResponse = await Supabase.instance.client
          .from('user_profiles')
          .select('first_name, last_name')
          .eq('id', landlordId)
          .maybeSingle();

      if (landlordResponse != null) {
        return '${landlordResponse['first_name']} ${landlordResponse['last_name']}';
      }
      return 'Landlord';
    } catch (e) {
      return 'Landlord';
    }
  }

  Widget _buildMessageItem({
    required String name,
    required String message,
    required String time,
    required bool isUnread,
    required Color avatarColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isUnread ? primaryColor.withOpacity(0.05) : whiteColor,
        border: Border(
          bottom: BorderSide(
            color: greyColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [avatarColor, avatarColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: whiteColor,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                  color: charcoalBlack,
                ),
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isUnread ? primaryColor : charcoalBlack.withOpacity(0.5),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                    color: charcoalBlack.withOpacity(isUnread ? 0.8 : 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isUnread)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
        onTap: () {
          // TODO: Open chat screen
          Get.snackbar(
            'Chat',
            'Opening conversation with $name',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: primaryColor,
            colorText: whiteColor,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Messages Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: charcoalBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start a conversation with landlords to find your perfect room',
              style: TextStyle(
                fontSize: 15,
                color: charcoalBlack.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/student-search');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: whiteColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Browse Rooms',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
              _buildNavItem(Icons.home_rounded, 'Home', false, () => Get.back()),
              _buildNavItem(Icons.search_rounded, 'Search', false, () => Get.toNamed('/student-search')),
              _buildNavItem(Icons.favorite_border_rounded, 'Saved', false, () => Get.toNamed('/student-saved')),
              _buildNavItem(Icons.chat_bubble_outline_rounded, 'Messages', true, () {}),
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
