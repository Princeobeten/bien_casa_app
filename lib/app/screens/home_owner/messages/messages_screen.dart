import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/home_owner_controller.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredConversations = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredConversations.clear();
      }
    });
  }

  void _performSearch(String query, HomeOwnerController controller) {
    if (query.isEmpty) {
      setState(() {
        _filteredConversations.clear();
      });
      return;
    }

    final results =
        controller.conversations.where((conversation) {
          final participantName =
              conversation['participantName'].toString().toLowerCase();
          final propertyTitle =
              conversation['propertyTitle'].toString().toLowerCase();
          final lastMessage =
              conversation['lastMessage'].toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return participantName.contains(searchLower) ||
              propertyTitle.contains(searchLower) ||
              lastMessage.contains(searchLower);
        }).toList();

    setState(() {
      _filteredConversations = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeOwnerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar:
              _isSearching
                  ? _buildSearchAppBar(controller)
                  : _buildNormalAppBar(),
          body: _buildBody(controller),
        );
      },
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
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
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/search icon.svg',
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: _toggleSearch,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar(HomeOwnerController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: TextField(
        controller: _searchController,
        onChanged: (value) => _performSearch(value, controller),
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(
            fontFamily: 'ProductSans',
            color: Colors.grey[500],
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
        ),
        style: const TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: _toggleSearch,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildBody(HomeOwnerController controller) {
    if (_isSearching) {
      return _buildSearchResults(controller);
    }

    return controller.conversations.isEmpty
        ? _buildEmptyState()
        : RefreshIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: controller.conversations.length,
            itemBuilder: (context, index) {
              final conversation = controller.conversations[index];
              return _buildConversationCard(conversation, controller);
            },
          ),
        );
  }

  Widget _buildSearchResults(HomeOwnerController controller) {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Search Conversations',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type to search by tenant name, property, or message',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_filteredConversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No conversations found',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '${_filteredConversations.length} result${_filteredConversations.length == 1 ? '' : 's'} found',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filteredConversations.length,
            itemBuilder: (context, index) {
              final conversation = _filteredConversations[index];
              return _buildConversationCard(conversation, controller);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/message.svg',
            width: 80,
            height: 80,
            colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
          ),
          const SizedBox(height: 16),
          Text(
            'No Messages Yet',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conversations with tenants will appear here',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(
    Map<String, dynamic> conversation,
    HomeOwnerController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Get.to(() => ChatScreen(conversation: conversation));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child:
                        conversation['participantAvatar'] != null
                            ? ClipOval(
                              child: Image.network(
                                conversation['participantAvatar'],
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.grey,
                            ),
                  ),
                  // Online indicator
                  if (conversation['isOnline'] == true)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation['participantName'],
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          _formatMessageTime(conversation['lastMessageTime']),
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation['propertyTitle'],
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation['lastMessage'],
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 14,
                              color:
                                  conversation['unreadCount'] > 0
                                      ? Colors.black
                                      : Colors.grey[600],
                              fontWeight:
                                  conversation['unreadCount'] > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation['unreadCount'] > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF29BCA2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              conversation['unreadCount'].toString(),
                              style: const TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
