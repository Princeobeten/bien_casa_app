import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../controllers/flatmate_controller.dart';
import '../../../../../models/campaign/campaign.dart';
import '../_widgets/flatmate_card.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Flatmate', 'Flat', 'Short-stay'];

  @override
  void initState() {
    super.initState();
    // Refresh campaigns when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<FlatmateController>().fetchCampaigns(limit: 50);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Campaign> _getFilteredCampaigns(FlatmateController controller) {
    List<Campaign> campaigns = controller.campaigns.toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      campaigns = campaigns.where((campaign) {
        final title = campaign.title.toLowerCase();
        final location = campaign.location.toLowerCase();
        final city = campaign.city.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return title.contains(query) || 
               location.contains(query) || 
               city.contains(query);
      }).toList();
    }

    // Apply goal filter
    if (_selectedFilter != 'All') {
      campaigns = campaigns.where((campaign) {
        return campaign.goal == _selectedFilter;
      }).toList();
    }

    return campaigns;
  }

  @override
  Widget build(BuildContext context) {
    // Get the controller to access campaign data from API
    final controller = Get.find<FlatmateController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'All Campaigns',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Search bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search campaigns...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontFamily: 'ProductSans',
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: const Color(0xFFF8F8F8),
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Headline for the page
            const Text(
              'Browse available flatmate campaign by budget, location, interest etc.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                fontFamily: 'ProductSans',
                color: Color(0xff6B6B6B),
              ),
            ),

            const SizedBox(height: 16),

            // Campaigns grid view
            Expanded(
              child: Obx(() {
                // Show loading indicator
                 if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredCampaigns = _getFilteredCampaigns(controller);
                
                if (filteredCampaigns.isEmpty) {
                  return _buildEmptyState();
                }
                
                return _buildCampaignsGrid(filteredCampaigns);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Grid view of campaign listings
  Widget _buildCampaignsGrid(List<Campaign> campaigns) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return FlatmateCard(campaign: campaign);
      },
    );
  }

  // Empty state when no campaigns are available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/home.svg',
            width: 80,
            height: 80,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Campaigns Available',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'We\'ll add more campaigns soon.\nCheck back later!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'ProductSans',
            ),
          ),
        ],
      ),
    );
  }
}
