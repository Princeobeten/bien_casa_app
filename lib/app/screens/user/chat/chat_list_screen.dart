import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/chat/chat_message.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';

/// ChatListScreen - List of all user conversations
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _currentIndex = 2; // Messages tab

  // Mock conversations - replace with actual data from controller/API
  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: 'conv_1',
      userId: 'user_001',
      otherUserId: 'user_002',
      otherUserName: 'Sarah Johnson',
      otherUserAvatar: 'https://i.pravatar.cc/150?img=5',
      lastMessage: 'Is the property still available?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      conversationType: 'property',
      propertyId: 'prop_001',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatConversation(
      id: 'conv_2',
      userId: 'user_001',
      otherUserId: 'user_003',
      otherUserName: 'Michael Chen',
      otherUserAvatar: 'https://i.pravatar.cc/150?img=8',
      lastMessage: 'Great! When can we schedule the inspection?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      conversationType: 'direct',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ChatConversation(
      id: 'conv_3',
      userId: 'user_001',
      otherUserId: 'user_004',
      otherUserName: 'Emma Williams',
      otherUserAvatar: 'https://i.pravatar.cc/150?img=9',
      lastMessage: 'Thanks for the information!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      conversationType: 'campaign',
      campaignId: 'camp_001',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ChatConversation(
      id: 'conv_4',
      userId: 'user_001',
      otherUserId: 'user_005',
      otherUserName: 'David Brown',
      otherUserAvatar: 'https://i.pravatar.cc/150?img=12',
      lastMessage: 'I\'m interested in joining the campaign',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 1,
      conversationType: 'campaign',
      campaignId: 'camp_002',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  int get _totalUnreadCount {
    return _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 40,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        actions: [
          if (_totalUnreadCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_totalUnreadCount unread',
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body:
          _conversations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  return _buildConversationCard(_conversations[index]);
                },
              ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              Get.offAllNamed('/user-home');
              break;
            case 1:
              Get.offAllNamed('/flatmate');
              break;
            case 2:
              // Already on Messages
              break;
            case 3:
              Get.offAllNamed('/wallet');
              break;
            case 4:
              Get.offAllNamed('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildConversationCard(ChatConversation conversation) {
    final bool hasUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.CHAT_CONVERSATION,
          arguments: {
            'conversationId': conversation.id,
            'otherUserId': conversation.otherUserId,
            'otherUserName': conversation.otherUserName,
            'otherUserAvatar': conversation.otherUserAvatar,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      conversation.otherUserAvatar != null
                          ? NetworkImage(conversation.otherUserAvatar!)
                          : null,
                  child:
                      conversation.otherUserAvatar == null
                          ? Text(
                            conversation.otherUserName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                          : null,
                ),
                // Online indicator (optional - can be based on user status)
                // Positioned(
                //   right: 0,
                //   bottom: 0,
                //   child: Container(
                //     width: 14,
                //     height: 14,
                //     decoration: BoxDecoration(
                //       color: Colors.green,
                //       shape: BoxShape.circle,
                //       border: Border.all(color: Colors.white, width: 2),
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(width: 12),

            // Message info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 16,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageTime != null)
                        Text(
                          _formatTime(conversation.lastMessageTime!),
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 12,
                            color:
                                hasUnread ? Colors.black : Colors.grey.shade600,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage ?? 'No messages yet',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            color:
                                hasUnread
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                            fontWeight:
                                hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (conversation.conversationType != 'direct') ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            conversation.conversationType == 'property'
                                ? Colors.blue.shade50
                                : Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            conversation.conversationType == 'property'
                                ? Icons.home
                                : Icons.group,
                            size: 12,
                            color:
                                conversation.conversationType == 'property'
                                    ? Colors.blue.shade700
                                    : Colors.purple.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            conversation.conversationType == 'property'
                                ? 'Property'
                                : 'Campaign',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 11,
                              color:
                                  conversation.conversationType == 'property'
                                      ? Colors.blue.shade700
                                      : Colors.purple.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Messages Yet',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by contacting\nproperty owners or campaign members',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }
}
