import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CampaignHousesScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;
  final int totalMembers;

  const CampaignHousesScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
    this.totalMembers = 3,
  });

  @override
  State<CampaignHousesScreen> createState() => _CampaignHousesScreenState();
}

class _CampaignHousesScreenState extends State<CampaignHousesScreen> {
  // Mock data for campaign houses
  final List<Map<String, dynamic>> _campaignHouses = [
    {
      'id': 'house_001',
      'propertyId': 'prop_001',
      'title': 'Modern 3BR Apartment in Lekki',
      'location': 'Lekki Phase 1, Lagos',
      'price': 5000000,
      'image':
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'bedrooms': 3,
      'bathrooms': 2,
      'size': '120 sqm',
      'addedBy': 'John Doe',
      'addedAt': DateTime.now().subtract(const Duration(days: 2)),
      'votes': ['user_001', 'user_002'], // User IDs who voted
      'votedByCurrentUser': true,
    },
    {
      'id': 'house_002',
      'propertyId': 'prop_002',
      'title': 'Luxury 4BR Duplex with Pool',
      'location': 'Victoria Island, Lagos',
      'price': 8000000,
      'image':
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      'bedrooms': 4,
      'bathrooms': 3,
      'size': '200 sqm',
      'addedBy': 'Sarah Johnson',
      'addedAt': DateTime.now().subtract(const Duration(days: 1)),
      'votes': ['user_002'],
      'votedByCurrentUser': false,
    },
    {
      'id': 'house_003',
      'propertyId': 'prop_003',
      'title': 'Cozy 2BR Flat in Ikeja',
      'location': 'Ikeja GRA, Lagos',
      'price': 3500000,
      'image':
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      'bedrooms': 2,
      'bathrooms': 1,
      'size': '85 sqm',
      'addedBy': 'Michael Chen',
      'addedAt': DateTime.now().subtract(const Duration(hours: 5)),
      'votes': ['user_001', 'user_002', 'user_003'],
      'votedByCurrentUser': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Sort houses by vote count (descending)
    _campaignHouses.sort((a, b) {
      final aVotes = (a['votes'] as List).length;
      final bVotes = (b['votes'] as List).length;
      return bVotes.compareTo(aVotes);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.only(left: 18),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campaign Houses',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.campaignTitle,
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: _addHouseFromListings,
            tooltip: 'Add House',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body:
          _campaignHouses.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Vote for your favorite houses. The house with the most votes will be prioritized.',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Houses list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _campaignHouses.length,
                      itemBuilder: (context, index) {
                        final house = _campaignHouses[index];
                        return _buildHouseCard(house, index + 1);
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addHouseFromListings,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add House',
          style: TextStyle(
            fontFamily: 'ProductSans',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            Icon(Icons.home_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            const Text(
              'No Houses Added Yet',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start adding houses from property listings to vote on with your flatmates',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _addHouseFromListings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Your First House',
                style: TextStyle(
                  fontFamily: 'ProductSans',
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

  Widget _buildHouseCard(Map<String, dynamic> house, int rank) {
    final votes = house['votes'] as List;
    final voteCount = votes.length;
    final votePercentage = (voteCount / widget.totalMembers * 100).round();
    final hasVoted = house['votedByCurrentUser'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with rank badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  house['image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.home,
                        size: 60,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              // Rank badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        rank == 1
                            ? Colors.amber
                            : rank == 2
                            ? Colors.grey[400]
                            : Colors.brown[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        rank == 1
                            ? Icons.emoji_events
                            : rank == 2
                            ? Icons.workspace_premium
                            : Icons.star,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '#$rank',
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Vote count badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.how_to_vote,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$voteCount/${widget.totalMembers}',
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Property details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        house['title'],
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'NGN${_formatAmount(house['price'])}',
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        house['location'],
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Property specs
                Row(
                  children: [
                    _buildSpecChip(
                      Icons.bed_outlined,
                      '${house['bedrooms']} Beds',
                    ),
                    const SizedBox(width: 8),
                    _buildSpecChip(
                      Icons.bathtub_outlined,
                      '${house['bathrooms']} Baths',
                    ),
                    const SizedBox(width: 8),
                    _buildSpecChip(Icons.square_foot, house['size']),
                  ],
                ),

                const SizedBox(height: 12),

                // Added by
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Added by ${house['addedBy']}',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${_formatTimestamp(house['addedAt'])}',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Vote progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Votes: $voteCount of ${widget.totalMembers}',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '$votePercentage%',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: voteCount / widget.totalMembers,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          votePercentage >= 75
                              ? Colors.green
                              : votePercentage >= 50
                              ? Colors.amber
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewPropertyDetails(house),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        label: const Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleVote(house),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hasVoted ? Colors.grey : Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: Icon(
                          hasVoted ? Icons.check_circle : Icons.how_to_vote,
                          size: 20,
                        ),
                        label: Text(
                          hasVoted ? 'Voted' : 'Vote',
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Remove button
                TextButton.icon(
                  onPressed: () => _removeHouse(house),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'Remove from Campaign',
                    style: TextStyle(fontFamily: 'ProductSans', fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount is num) {
      return amount
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return amount.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _toggleVote(Map<String, dynamic> house) {
    setState(() {
      final votes = house['votes'] as List;
      final hasVoted = house['votedByCurrentUser'] as bool;

      if (hasVoted) {
        // Remove vote
        votes.remove('user_001'); // Current user ID
        house['votedByCurrentUser'] = false;
        Get.snackbar(
          'Vote Removed',
          'Your vote has been removed',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.grey.shade100,
          colorText: Colors.black,
        );
      } else {
        // Add vote
        votes.add('user_001'); // Current user ID
        house['votedByCurrentUser'] = true;
        Get.snackbar(
          'Voted!',
          'Your vote has been recorded',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      }
    });
  }

  void _viewPropertyDetails(Map<String, dynamic> house) {
    Get.snackbar(
      'View Property',
      'Opening details for ${house['title']}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
    );
    // TODO: Navigate to property detail screen
    // Get.toNamed(AppRoutes.PROPERTY_DETAIL, arguments: house['propertyId']);
  }

  void _removeHouse(Map<String, dynamic> house) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Remove House',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Remove "${house['title']}" from campaign houses?',
          style: const TextStyle(fontFamily: 'ProductSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setState(() {
                _campaignHouses.remove(house);
              });
              Get.snackbar(
                'Removed',
                'House has been removed from campaign',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade900,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _addHouseFromListings() {
    Get.snackbar(
      'Add House',
      'Browse property listings to add houses to your campaign',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    // TODO: Navigate to property listings with "Add to Campaign" option
    // Get.toNamed(AppRoutes.USER_HOME);
  }
}
