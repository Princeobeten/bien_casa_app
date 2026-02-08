import 'package:bien_casa/app/screens/user/flatmate/home/_widgets/flatmate_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flatmate/survey/flatmate_survey.dart';
import 'flatmate/home/_widgets/match_card_section.dart';
import 'flatmate/home/_widgets/available_flats_section.dart';
import 'flatmate/home/_widgets/available_campaigns_section.dart';
import 'flatmate/_widgets/floating_add_button.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../controllers/flatmate_match_controller.dart';
import '../../controllers/campaign/campaign_enhanced_controller.dart';
import '../../routes/app_routes.dart';

class FlatmateScreen extends StatefulWidget {
  const FlatmateScreen({super.key});

  @override
  State<FlatmateScreen> createState() => _FlatmateScreenState();
}

class _FlatmateScreenState extends State<FlatmateScreen> {
  bool _isFirstTime = true;
  bool _isLoading = true;
  int _currentIndex = 1; // Set to 1 for Flatmate tab
  int _selectedTabIndex = 0; // 0 for Hot tab (default), 1 for Flatmates, etc.

  @override
  void initState() {
    super.initState();
    // Initialize FlatmateMatchController if not already initialized
    if (!Get.isRegistered<FlatmateMatchController>()) {
      Get.put(FlatmateMatchController());
    }
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedSurvey =
        prefs.getBool('flatmate_survey_completed') ?? false;

    setState(() {
      _isFirstTime = !hasCompletedSurvey;
      _isLoading = false;
    });
  }

  Future<void> _markSurveyCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flatmate_survey_completed', true);

    setState(() {
      _isFirstTime = false;
    });
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // App bar with SVG icons
              const FlatmateAppBar(),

              // Main tabs: Flatmate and My Campaign
              _buildMainTabs(),

              // Content based on selected tab
              Expanded(child: _buildTabContent()),
            ],
          ),

          const FloatingAddButton(routeName: '/add-campaign'),
        ],
      ),
    );
  }

  Widget _buildMainTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? Colors.black : const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
                child: Text(
                  'Campaigns',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _selectedTabIndex == 0 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? Colors.black : const Color(0xFFF8F8F8),
                 borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                
                ),
                child: Text(
                  'My Campaign',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _selectedTabIndex == 1 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build content based on selected tab
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Campaigns tab
        return SingleChildScrollView(
          child: Column(
            children: [
              // Info text with CTA button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Browse available flatmate campaign by budget, location, interest etc.',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'ProductSans',
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                       Get.toNamed("/campaigns-page");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Campaign cards section
              const MatchCardSection(),
              const SizedBox(height: 20),
              
              // Available flats section
              AvailableFlatsSection(
                onViewAllTap: () {
                  // Navigate to flats page to see all flats
                  Get.toNamed(AppRoutes.FLATS_PAGE);
                },
              ),
              const SizedBox(height: 20),
              
              // Available Campaigns section
              AvailableCampaignsSection(
                onViewAllTap: () {
                  // Navigate to campaigns page to see all campaigns
                  Get.toNamed(AppRoutes.CAMPAIGNS_PAGE);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      case 1: // My Campaign tab
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // My Campaign details
              _buildMyCampaignDetails(),
            ],
          ),
        );
      default:
        return const MatchCardSection();
    }
  }

  // Detailed My Campaign view
  Widget _buildMyCampaignDetails() {
    // Mock data for user's campaign
    const bool hasCampaign = true;

    if (!hasCampaign) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Icon(Icons.campaign_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No Active Campaign',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a campaign to find flatmates',
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

    return _buildMyCampaignQuickAccess();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Always use Scaffold with bottom nav bar
    return Scaffold(
      backgroundColor: Colors.white,

      body:
          _isFirstTime
              ? FlatmateSurvey(onSurveyComplete: _markSurveyCompleted)
              : _buildMainContent(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Navigate to the appropriate screen based on the index
          if (index == 0) {
            // Home tab - use offAllNamed to prevent back button
            Get.offAllNamed('/user-home');
          } else if (index == 2) {
            // Messages tab
            Get.toNamed('/chat-list');
          } else if (index == 3) {
            // Wallet tab
            Get.offAllNamed('/wallet');
          } else if (index == 4) {
            // Profile tab
            Get.offAllNamed('/profile');
          }

          // We're already on the Flatmate tab (index 1), so no navigation needed
        },
      ),
    );
  }

  // My Campaign Quick Access - Using real API data
  Widget _buildMyCampaignQuickAccess() {
    final campaignController = Get.find<CampaignEnhancedController>();
    
    return Obx(() {
      // Console log the campaigns API data
      print('=== MY CAMPAIGNS API DATA ===');
      print('Total Campaigns: ${campaignController.myCampaigns.length}');
      print('Is Loading: ${campaignController.isLoading}');
      
      if (campaignController.myCampaigns.isNotEmpty) {
        for (int i = 0; i < campaignController.myCampaigns.length; i++) {
          final campaign = campaignController.myCampaigns[i];
          print('Campaign $i:');
          print('  ID: ${campaign.id}');
          print('  Title: ${campaign.title}');
          print('  Goal: ${campaign.goal}');
          print('  Budget: ${campaign.budget}');
          print('  City: ${campaign.city}');
          print('  Status: ${campaign.status}');
        }
      }
      print('============================');

      // Show loading state
      if (campaignController.isLoading) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[100]!),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Show empty state if no campaigns
      if (campaignController.myCampaigns.isEmpty) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[100]!),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              const Icon(Icons.campaign_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No Campaigns Yet',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first campaign to find flatmates',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.ADD_FLATMATE),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Campaign',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Show first campaign with real data
      final campaign = campaignController.myCampaigns.first;
      
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[100]!),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Campaign',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        campaign.title,
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(campaign.status ?? 'Active').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: _getStatusColor(campaign.status ?? 'Active'),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        campaign.status ?? 'Active',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 11,
                          color: _getStatusColor(campaign.status ?? 'Active'),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Campaign details
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '${campaign.city}, ${campaign.country}',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'ProductSans',
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.account_balance_wallet, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  campaign.formattedBudget,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'ProductSans',
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to all campaigns page
                      Get.toNamed(AppRoutes.CAMPAIGNS_PAGE);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View All',
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
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.ADD_FLATMATE),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create New',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade600;
      case 'paused':
        return Colors.orange.shade600;
      case 'closed':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  // Helper to build quick stat items
  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Show campaign management menu
  void _showCampaignMenu(
    String campaignId,
    String campaignTitle,
    int totalMembers,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campaign Management',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                _buildMenuOption(
                  icon: Icons.home,
                  title: 'Houses',
                  subtitle: 'View campaign properties',
                  onTap: () {
                    Get.back();
                    Get.toNamed(
                      AppRoutes.CAMPAIGN_HOUSES,
                      arguments: {
                        'campaignId': campaignId,
                        'campaignTitle': campaignTitle,
                        'totalMembers': totalMembers,
                      },
                    );
                  },
                ),
                _buildMenuOption(
                  icon: Icons.account_balance_wallet,
                  title: 'Contributions',
                  subtitle: 'Manage campaign funds',
                  onTap: () {
                    Get.back();
                    Get.toNamed(
                      AppRoutes.CAMPAIGN_CONTRIBUTIONS,
                      arguments: {
                        'campaignId': campaignId,
                        'campaignTitle': campaignTitle,
                        'totalMembers': totalMembers,
                      },
                    );
                  },
                ),
                _buildMenuOption(
                  icon: Icons.send,
                  title: 'Transfer Requests',
                  subtitle: 'View pending transfers',
                  onTap: () {
                    Get.back();
                    Get.toNamed(
                      AppRoutes.TRANSFER_REQUESTS,
                      arguments: {
                        'campaignId': campaignId,
                        'campaignTitle': campaignTitle,
                        'totalMembers': totalMembers,
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
