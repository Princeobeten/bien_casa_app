import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../controllers/flatmate_controller.dart';
import '../../../../../routes/app_routes.dart';

class MatchCardSection extends StatefulWidget {
  const MatchCardSection({super.key});

  @override
  State<MatchCardSection> createState() => _MatchCardSectionState();
}

class _MatchCardSectionState extends State<MatchCardSection> {
  late final FlatmateController controller;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.find<FlatmateController>();
    _pageController = PageController(viewportFraction: 0.85);
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && controller.campaigns.isNotEmpty) {
        final nextPage = (_currentPage + 1) % controller.campaigns.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoSwipe();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.55,
      child: Obx(() {
        // Show loading indicator
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show empty state if no campaigns
        if (controller.campaigns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No campaigns available',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate end index safely to prevent RangeError
        final startIndex = controller.currentIndex.value;
        final maxIndex = controller.campaigns.length;
        final cardCount = controller.hasMoreCards ? 3 : 1;
        final endIndex = (startIndex + cardCount.clamp(1, 3)).clamp(0, maxIndex);

        // Make sure start index is valid and not greater than end index
        final validStartIndex = startIndex.clamp(0, maxIndex);
        final validEndIndex = endIndex > validStartIndex ? endIndex : validStartIndex;

        final cardsToShow = (validStartIndex < maxIndex)
            ? controller.campaigns
                .sublist(validStartIndex, validEndIndex)
                .asMap()
                .entries
                .toList()
            : [];

        return Stack(
          alignment: Alignment.center,
          children: [
            // Back cards (up to 2 cards behind)
            ...cardsToShow.sublist(0, cardsToShow.length - 1).asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              final cardIndex = controller.currentIndex.value + index;

              return Positioned(
                top: 20 + (index * 10),
                child: GestureDetector(
                  onTap: () => _navigateToCampaignDetail(card.value),
                  child: Transform.rotate(
                    angle: controller.getCardTilt(cardIndex),
                    child: _buildCard(
                      context,
                      campaign: card.value,
                      scale: 0.85 + (index * 0.05),
                      index: cardIndex,
                    ),
                  ),
                ),
              );
            }),

            // Front card
            if (cardsToShow.isNotEmpty)
              GestureDetector(
                onTap: () => _navigateToCampaignDetail(cardsToShow.last.value),
                child: Transform.rotate(
                  angle: controller.getCardTilt(
                    controller.currentIndex.value + cardsToShow.length - 1,
                  ),
                  child: _buildCard(
                    context,
                    campaign: cardsToShow.last.value,
                    isFront: true,
                    index: controller.currentIndex.value + cardsToShow.length - 1,
                  ),
                ),
              ),

            // Navigation arrows
            if (controller.currentIndex.value > 0)
              Positioned(
                left: 10,
                child: _buildNavButton(
                  icon: Icons.arrow_back_ios,
                  onPressed: controller.previousCard,
                  rotateLeft: true,
                ),
              ),

            if (controller.hasMoreCards)
              Positioned(
                right: 10,
                child: _buildNavButton(
                  icon: Icons.arrow_forward_ios,
                  onPressed: controller.nextCard,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool rotateLeft = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Transform.rotate(
angle: rotateLeft ? 3.14159 / 4 : 0,
          child: SvgPicture.asset(
          'assets/icons/swipe.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            Colors.black,
            BlendMode.srcIn,
      ),
        ),
      ),
        onPressed: onPressed,
      ),
    );
  }

  void _navigateToCampaignDetail(campaign) {
    // TODO: Create campaign detail page and route to it
    // For now, route to flatmate detail as placeholder
    Get.toNamed(AppRoutes.FLATMATE_DETAIL, arguments: campaign);
  }

  Widget _buildCard(
    BuildContext context, {
    required campaign,
    double scale = 1.0,
    bool isFront = false,
    int index = 0,
  }) {
    final size = MediaQuery.of(context).size;
    // Calculate match percentage (mock calculation)
    final matchPercentage = 75 + (index % 20);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: size.width * 0.75,
        height: size.height * 0.45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildCardContent(campaign),
            // Match percentage badge in top right corner
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: matchPercentage >= 80 ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$matchPercentage%',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: matchPercentage >= 80 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(campaign) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Campaign Image (placeholder gradient)
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getGoalColor(campaign.goal),
                  _getGoalColor(campaign.goal).withOpacity(0.7),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                _getGoalIcon(campaign.goal),
                size: 100,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              stops: const [0.4, 1.0],
            ),
          ),
        ),

        // User Info and View Campaign Button
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campaign Title
              Text(
                campaign.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  fontSize: 20,
                  height: 1,
                  letterSpacing: 0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Campaign Goal Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  campaign.goal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Budget and Location
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/naira.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 1.75),
                      Text(
                        campaign.formattedBudget,
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${campaign.city}, ${campaign.country}',
                        style: const TextStyle(
                          fontFamily: 'ProductSans Light',
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                          fontSize: 12,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Duration
              Text(
                'Duration: ${campaign.duration}',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'ProductSans Light',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 16),

              // View Campaign Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToCampaignDetail(campaign),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Campaign',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getGoalColor(String goal) {
    switch (goal) {
      case 'Flatmate':
        return Colors.blue;
      case 'Flat':
        return Colors.green;
      case 'Short-stay':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Flatmate':
        return Icons.people;
      case 'Flat':
        return Icons.home;
      case 'Short-stay':
        return Icons.hotel;
      default:
        return Icons.campaign;
    }
  }
}
