/// Chat message model
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final String? imageUrl;
  final String? fileUrl;
  final String messageType; // 'text', 'image', 'file'
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    this.imageUrl,
    this.fileUrl,
    this.messageType = 'text',
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? json['conversation_id'] ?? '',
      senderId: json['senderId'] ?? json['sender_id'] ?? '',
      senderName: json['senderName'] ?? json['sender_name'] ?? '',
      senderAvatar: json['senderAvatar'] ?? json['sender_avatar'],
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      fileUrl: json['fileUrl'] ?? json['file_url'],
      messageType: json['messageType'] ?? json['message_type'] ?? 'text',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'message': message,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'messageType': messageType,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Chat conversation model
class ChatConversation {
  final String id;
  final String userId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String conversationType; // 'direct', 'property', 'campaign'
  final String? propertyId;
  final String? campaignId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.conversationType = 'direct',
    this.propertyId,
    this.campaignId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      otherUserId: json['otherUserId'] ?? json['other_user_id'] ?? '',
      otherUserName: json['otherUserName'] ?? json['other_user_name'] ?? '',
      otherUserAvatar: json['otherUserAvatar'] ?? json['other_user_avatar'],
      lastMessage: json['lastMessage'] ?? json['last_message'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : (json['last_message_time'] != null
              ? DateTime.parse(json['last_message_time'])
              : null),
      unreadCount: json['unreadCount'] ?? json['unread_count'] ?? 0,
      conversationType: json['conversationType'] ?? json['conversation_type'] ?? 'direct',
      propertyId: json['propertyId'] ?? json['property_id'],
      campaignId: json['campaignId'] ?? json['campaign_id'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserAvatar': otherUserAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'conversationType': conversationType,
      'propertyId': propertyId,
      'campaignId': campaignId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
