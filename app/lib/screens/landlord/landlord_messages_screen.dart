import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/theme.dart';
import '../../widgets/landlord_bottom_nav.dart';

class LandlordMessagesScreen extends StatelessWidget {
  const LandlordMessagesScreen({super.key});

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
      bottomNavigationBar: const LandlordBottomNav(currentIndex: 2),
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
          .eq('landlord_id', userId)
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
            final studentId = conversation['student_id'];
            final houseId = conversation['house_id'];
            final lastMessage = conversation['last_message_text'] ?? '';
            final lastMessageAt = conversation['last_message_at'];
            final unreadCount = conversation['landlord_unread_count'] ?? 0;
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

            return FutureBuilder<Map<String, dynamic>>(
              future: _getConversationDetails(studentId, houseId),
              builder: (context, detailsSnapshot) {
                final studentName = detailsSnapshot.data?['student_name'] ?? 'Student';
                final propertyTitle = detailsSnapshot.data?['property_title'] ?? 'Property';
                final colors = [primaryColor, accentColor, yellowColor];
                final avatarColor = colors[index % 3];

                return _buildMessageItem(
                  name: studentName,
                  propertyTitle: propertyTitle,
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

  Future<Map<String, dynamic>> _getConversationDetails(String studentId, String? houseId) async {
    try {
      final studentResponse = await Supabase.instance.client
          .from('user_profiles')
          .select('first_name, last_name')
          .eq('id', studentId)
          .maybeSingle();

      String? propertyTitle;
      if (houseId != null) {
        final houseResponse = await Supabase.instance.client
            .from('houses')
            .select('title')
            .eq('id', houseId)
            .maybeSingle();
        propertyTitle = houseResponse?['title'];
      }

      return {
        'student_name': studentResponse != null
            ? '${studentResponse['first_name']} ${studentResponse['last_name']}'
            : 'Student',
        'property_title': propertyTitle ?? 'General Inquiry',
      };
    } catch (e) {
      return {
        'student_name': 'Student',
        'property_title': 'Property',
      };
    }
  }

  Widget _buildMessageItem({
    required String name,
    required String propertyTitle,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                propertyTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryColor.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
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
              'When tenants inquire about your properties, their messages will appear here',
              style: TextStyle(
                fontSize: 15,
                color: charcoalBlack.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
