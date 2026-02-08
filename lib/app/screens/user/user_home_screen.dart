import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/kyc_completion_banner.dart';
import '../../widgets/skeleton_loader.dart';
import '../../controllers/user_home_controller.dart';
import '../../routes/app_routes.dart';
import '../../controllers/kyc_controller.dart';
import 'home/featured_property_card.dart';
import 'home/horizontal_property_list.dart';
import 'home/search_bar_widget.dart';
import 'home/section_header.dart';
import 'home/location_property_list.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  // Get the UserHomeController using GetX
  final UserHomeController _controller = Get.find<UserHomeController>();
  final kycController = Get.put(KYCController());

  int _currentIndex = 0;
  String _selectedFilter = 'Hot'; // Track selected filter

  @override
  void initState() {
    super.initState();
    // Preload cached KYC data to prevent UI flickering
    _preloadCachedData();
  }

  Future<void> _preloadCachedData() async {
    // This will load cached data immediately if available
    // preventing the UI from flickering while waiting for API calls
    await kycController.fetchAccountStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: !kycController.isKYCCompleted,
          title: Text(
            kycController.isKYCCompleted ? 'Explore' : 'Almost there',
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 40,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              height: 1,
              letterSpacing: 0,
              color: Colors.black,
            ),
          ),
          actions: [
            Obx(() {
              if (!kycController.isKYCCompleted) {
                return const SizedBox.shrink();
              }
              return kycController.isLoading.value
                  ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SkeletonLoader(width: 24, height: 24),
                  )
                  : Opacity(
                    opacity: kycController.isKYCCompleted ? 1.0 : 0.5,
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.favorite_border_rounded,
                            color:
                                kycController.isKYCCompleted
                                    ? Colors.black
                                    : Colors.grey,
                          ),
                          onPressed: () {
                            if (!kycController.isKYCCompleted) {
                              Get.snackbar(
                                'KYC Required',
                                'Please complete your KYC verification to access favorites',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            Get.toNamed(AppRoutes.FAVORITES);
                          },
                        ),
                        if (kycController.isKYCCompleted)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
            }),
            Obx(() {
              if (!kycController.isKYCCompleted) {
                return const SizedBox.shrink();
              }
              return kycController.isLoading.value
                  ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SkeletonLoader(width: 24, height: 24),
                  )
                  : Opacity(
                    opacity: kycController.isKYCCompleted ? 1.0 : 0.5,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/notification.svg',
                        colorFilter: ColorFilter.mode(
                          kycController.isKYCCompleted
                              ? Colors.black
                              : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        if (!kycController.isKYCCompleted) {
                          Get.snackbar(
                            'KYC Required',
                            'Please complete your KYC verification to access notifications',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        // Handle notification tap
                      },
                    ),
                  );
            }),
            const SizedBox(width: 10),
          ],
        ),
        body:
            kycController.isLoading.value
                ? const SingleChildScrollView(child: BottomNavSkeletonLoader())
                : RefreshIndicator(
                  backgroundColor: Colors.white,
                  color: Colors.black,
                  onRefresh: () async {
                    // Refresh KYC status and home data
                    print('🔄 Refreshing home screen data...');

                    // Refresh KYC status
                    await kycController.refreshAccountStatus();

                    // Refresh other home data if needed
                    // Example: await _controller.refreshData();

                    print('✅ Home screen refresh completed');
                  },
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // KYC Completion Banner (only show if not completed)
                          Obx(() {
                            if (kycController.isKYCCompleted) {
                              return const SizedBox.shrink();
                            }
                            return const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                KYCCompletionBanner(),
                                SizedBox(height: 16),
                              ],
                            );
                          }),

                          // Search Bar
                          Obx(
                            () => Opacity(
                              opacity: kycController.isKYCCompleted ? 1.0 : 0.5,
                              child: IgnorePointer(
                                ignoring: !kycController.isKYCCompleted,
                                child: SearchBarWidget(
                                  onTap: () => _controller.navigateToSearch(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Property Type Filters
                          Obx(
                            () => Opacity(
                              opacity: kycController.isKYCCompleted ? 1.0 : 0.5,
                              child: IgnorePointer(
                                ignoring: !kycController.isKYCCompleted,
                                child: _buildPropertyFilters(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Featured Properties Carousel - Shows sets of 3 properties
                          Obx(
                            () => Opacity(
                              opacity: kycController.isKYCCompleted ? 1.0 : 0.5,
                              child: IgnorePointer(
                                ignoring: !kycController.isKYCCompleted,
                                child: Obx(() {
                                  // Group properties into sets of 3
                                  final propertySets =
                                      <List<Map<String, dynamic>>>[];
                                  for (
                                    int i = 0;
                                    i < _controller.featuredProperties.length;
                                    i += 3
                                  ) {
                                    final end =
                                        (i + 3 <
                                                _controller
                                                    .featuredProperties
                                                    .length)
                                            ? i + 3
                                            : _controller
                                                .featuredProperties
                                                .length;
                                    propertySets.add(
                                      _controller.featuredProperties.sublist(
                                        i,
                                        end,
                                      ),
                                    );
                                  }

                                  if (propertySets.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  final currentSetIndex =
                                      _controller.currentFeaturedIndex.value;
                                  final currentSet =
                                      propertySets[currentSetIndex %
                                          propertySets.length];

                                  return Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    child: FeaturedPropertyCard(
                                      properties: currentSet,
                                      currentSetIndex: currentSetIndex,
                                      totalSets: propertySets.length,
                                      onSetChange: (newSetIndex) {
                                        _controller.currentFeaturedIndex.value =
                                            newSetIndex;
                                      },
                                      onPropertyTap: (property) {
                                        _controller.navigateToPropertyDetail(
                                          property,
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),

                          // Recently added houses
                          Obx(
                            () => Opacity(
                              opacity: kycController.isKYCCompleted ? 1.0 : 0.5,
                              child: IgnorePointer(
                                ignoring: !kycController.isKYCCompleted,
                                child: SectionHeader(
                                  title: 'Recently added houses for sale',
                                  viewAllText: 'View all',
                                  onViewAllTap:
                                      () =>
                                          _controller
                                              .navigateToRecentlyAddedProperties(),
                                ),
                              ),
                            ),
                          ),

                          Obx(
                            () => Opacity(
                              opacity: kycController.isKYCCompleted ? 1.0 : 0.5,
                              child: IgnorePointer(
                                ignoring: !kycController.isKYCCompleted,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  child: HorizontalPropertyList(
                                    properties:
                                        _controller.recentlyAddedProperties,
                                    onItemTap:
                                        (index) => _controller
                                            .navigateToPropertyDetail(
                                              _controller
                                                  .recentlyAddedProperties[index],
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Most searched houses by location
                          Obx(
                            () => Opacity(
                              opacity: kycController.isKYCCompleted ? 1.0 : 0.5,
                              child: IgnorePointer(
                                ignoring: !kycController.isKYCCompleted,
                                child: Obx(() {
                                  final location =
                                      _controller.selectedLocation.value;
                                  return LocationPropertyList(
                                    locationName: location,
                                    properties:
                                        _controller
                                            .locationProperties[location] ??
                                        [],
                                    onItemTap:
                                        (
                                          index,
                                        ) => _controller.navigateToPropertyDetail(
                                          _controller
                                              .locationProperties[location]![index],
                                        ),
                                    onViewAllTap:
                                        () => _controller
                                            .navigateToLocationProperties(
                                              location,
                                            ),
                                  );
                                }),
                              ),
                            ),
                          ),

                          // Add some bottom padding
                          const SizedBox(height: 34),
                        ],
                      ),
                    ),
                  ),
                ),
        bottomNavigationBar: Obx(
          () => Opacity(
            opacity:
                kycController.isLoading.value
                    ? 0.5
                    : (kycController.isKYCCompleted ? 1.0 : 0.5),
            child: IgnorePointer(
              ignoring:
                  kycController.isLoading.value ||
                  !kycController.isKYCCompleted,
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  if (!kycController.isKYCCompleted) {
                    Get.snackbar(
                      'KYC Required',
                      'Please complete your KYC verification to access this feature',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  setState(() {
                    _currentIndex = index;
                  });

                  // Navigate to the appropriate screen based on the index
                  switch (index) {
                    case 0:
                      // Already on home screen
                      break;
                    case 1:
                      // Flatmate tab
                      Get.offAllNamed('/flatmate');
                      break;
                    case 2:
                      // Messages tab
                      Get.toNamed(AppRoutes.CHAT_LIST);
                      break;
                    case 3:
                      // Wallet tab
                      Get.toNamed('/wallet');
                      break;
                    case 4:
                      // Profile tab
                      Get.offAllNamed('/profile');
                      break;
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Hot', Icons.local_fire_department, isHot: true),
          const SizedBox(width: 10),
          _buildFilterChip('Flats', Icons.apartment),
          const SizedBox(width: 10),
          _buildFilterChip('Hostels', Icons.business),
          const SizedBox(width: 10),
          _buildFilterChip('Short-stay', Icons.hotel),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, {bool isHot = false}) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
        // TODO: Implement filter logic to show filtered properties
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: Colors.black, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHot)
              Icon(icon, size: 18, color: const Color(0xffDC3545))
            else
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.black,
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'ProductSans',
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
