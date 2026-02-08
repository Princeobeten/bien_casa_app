import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/chat/chat_message.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';

/// ChatConversationScreen - Individual chat conversation
class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 2; // Messages tab
  
  // Get arguments
  late String conversationId;
  late String otherUserId;
  late String otherUserName;
  String? otherUserAvatar;

  // Mock messages - replace with actual data from controller/API
  final List<ChatMessage> _messages = [];
  final String _currentUserId = 'user_001'; // Mock current user ID

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    conversationId = args['conversationId'] ?? '';
    otherUserId = args['otherUserId'] ?? '';
    otherUserName = args['otherUserName'] ?? 'User';
    otherUserAvatar = args['otherUserAvatar'];

    _loadMessages();
  }

  void _loadMessages() {
    // Mock messages
    setState(() {
      _messages.addAll([
        ChatMessage(
          id: 'msg_1',
          conversationId: conversationId,
          senderId: otherUserId,
          senderName: otherUserName,
          senderAvatar: otherUserAvatar,
          message: 'Hi! Is the property still available?',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: 'msg_2',
          conversationId: conversationId,
          senderId: _currentUserId,
          senderName: 'You',
          message: 'Yes, it is! Would you like to schedule a viewing?',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
        ),
        ChatMessage(
          id: 'msg_3',
          conversationId: conversationId,
          senderId: otherUserId,
          senderName: otherUserName,
          senderAvatar: otherUserAvatar,
          message: 'That would be great! What times are available?',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
        ),
        ChatMessage(
          id: 'msg_4',
          conversationId: conversationId,
          senderId: _currentUserId,
          senderName: 'You',
          message: 'I have availability tomorrow at 2 PM or Friday at 10 AM. Which works better for you?',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        ),
      ]);
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: otherUserAvatar != null
                  ? NetworkImage(otherUserAvatar!)
                  : null,
              child: otherUserAvatar == null
                  ? Text(
                      otherUserName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == _currentUserId;
                final showAvatar = !isMe && (index == _messages.length - 1 ||
                    _messages[index + 1].senderId != message.senderId);

                return _buildMessageBubble(message, isMe, showAvatar);
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment button
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: Colors.grey.shade600),
                    onPressed: () {
                      // Show attachment options
                    },
                  ),
                  
                  // Text input
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Send button
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              Get.offAllNamed('/chat-list');
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

  Widget _buildMessageBubble(ChatMessage message, bool isMe, bool showAvatar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar)
            CircleAvatar(
              radius: 16,
              backgroundImage: message.senderAvatar != null
                  ? NetworkImage(message.senderAvatar!)
                  : null,
              child: message.senderAvatar == null
                  ? Text(
                      message.senderName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : null,
            )
          else if (!isMe)
            const SizedBox(width: 32),
          
          const SizedBox(width: 8),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: !isMe
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 14,
                      color: isMe ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.createdAt),
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: _currentUserId,
      senderName: 'You',
      message: _messageController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // TODO: Send message to API
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return DateFormat('h:mm a').format(time);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE h:mm a').format(time);
    } else {
      return DateFormat('MMM dd, h:mm a').format(time);
    }
  }
}
