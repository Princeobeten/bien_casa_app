import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../widgets/custom_bottom_nav_bar.dart';
import '../../../widgets/transaction_details_bottom_sheet.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../../controllers/app_mode_controller.dart';
import '../../../controllers/home_owner_controller.dart';
import '../../../services/wallet_service.dart';
import 'add_funds_modal.dart';
import 'withdraw_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _walletBalance = 0.0;
  bool _hideBalance = false;
  bool _isLoading = true;
  bool _isRefreshing = false;

  // Wallet data
  Map<String, dynamic>? _walletData;
  List<Map<String, dynamic>> _recentWalletActivities = [];

  // Cache management
  static const String _cacheKey = 'wallet_data_cache';
  static const String _cacheTimestampKey = 'wallet_cache_timestamp';
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isRefreshing = true);
    }

    try {
      // Check if we have valid cached data
      if (!forceRefresh && await _hasCachedData()) {
        await _loadFromCache();
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        return;
      }

      print('💰 Loading wallet data from API...');

      // Fetch all wallet data from single endpoint
      final walletsResponse = await WalletService.getUserWallets();

      if (walletsResponse['data'] != null) {
        // Handle both array and object response formats
        Map<String, dynamic> walletData;

        if (walletsResponse['data'] is List) {
          // Old format: array of wallets
          final walletsList = walletsResponse['data'] as List;
          if (walletsList.isEmpty) {
            setState(() {
              _isLoading = false;
              _isRefreshing = false;
            });
            return;
          }
          walletData = walletsList[0];
        } else {
          // New format: single wallet object
          walletData = walletsResponse['data'] as Map<String, dynamic>;
        }

        // Extract balance
        final balance =
            double.tryParse(walletData['balance']?.toString() ?? '0') ?? 0.0;

        // Extract recent transactions if available
        final transactions =
            walletData['recentTransactions'] ??
            walletData['transactions'] ??
            walletData['transactionHistory'] ??
            [];

        final activities =
            (transactions as List?)
                ?.map((transaction) => _mapTransactionToActivity(transaction))
                .toList() ??
            [];

        // Cache the data
        await _cacheWalletData(walletData, balance, activities);

        setState(() {
          _walletData = walletData;
          _walletBalance = balance;
          _recentWalletActivities = activities;
          _isLoading = false;
          _isRefreshing = false;
        });

        print('💰 ✅ Wallet data loaded and cached successfully');
        print('💰 Balance: $balance');
        print(
          '💰 Account: ${walletData['accountNumber']} (${walletData['bankName']})',
        );
        print('💰 Transactions: ${activities.length}');
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      print('❌ Error loading wallet data: $e');

      // Try to load from cache as fallback
      if (await _hasCachedData()) {
        await _loadFromCache();
        Get.snackbar(
          'Offline Mode',
          'Showing cached data. Pull to refresh when online.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load wallet data: ${e.toString().replaceAll('Exception: ', '')}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<bool> _hasCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimestamp = prefs.getInt(_cacheTimestampKey);
      final cachedData = prefs.getString(_cacheKey);

      if (cacheTimestamp == null || cachedData == null) {
        return false;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
      final now = DateTime.now();
      final isValid = now.difference(cacheTime) < _cacheValidDuration;

      return isValid;
    } catch (e) {
      print('❌ Error checking cache: $e');
      return false;
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDataString = prefs.getString(_cacheKey);

      if (cachedDataString != null) {
        final cachedData = jsonDecode(cachedDataString);

        // Restore activities and add back the icons
        final cachedActivities = List<Map<String, dynamic>>.from(
          cachedData['activities'] ?? [],
        );

        final activitiesWithIcons =
            cachedActivities.map((activity) {
              // Restore the icon based on transaction amount
              final amount = activity['amount'] ?? 0;
              final isPositive = amount > 0;

              IconData icon =
                  isPositive ? Icons.arrow_downward : Icons.arrow_upward;

              return {...activity, 'icon': icon};
            }).toList();

        setState(() {
          _walletData = cachedData['walletData'];
          _walletBalance = cachedData['balance']?.toDouble() ?? 0.0;
          _recentWalletActivities = activitiesWithIcons;
        });

        print('💰 ✅ Loaded wallet data from cache');
      }
    } catch (e) {
      print('❌ Error loading from cache: $e');
    }
  }

  Future<void> _cacheWalletData(
    Map<String, dynamic>? walletData,
    double balance,
    List<Map<String, dynamic>> activities,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create a serializable version of activities (without IconData)
      final serializableActivities =
          activities.map((activity) {
            final serializableActivity = Map<String, dynamic>.from(activity);
            // Remove IconData which can't be serialized
            serializableActivity.remove('icon');
            return serializableActivity;
          }).toList();

      final cacheData = {
        'walletData': walletData,
        'balance': balance,
        'activities': serializableActivities,
      };

      await prefs.setString(_cacheKey, jsonEncode(cacheData));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      print('💰 ✅ Wallet data cached successfully');
    } catch (e) {
      print('❌ Error caching wallet data: $e');
    }
  }

  Future<void> _onRefresh() async {
    await _loadWalletData(forceRefresh: true);
  }

  Map<String, dynamic> _mapTransactionToActivity(
    Map<String, dynamic> transaction,
  ) {
    final type = transaction['type']?.toString().toLowerCase() ?? '';
    final direction = transaction['direction']?.toString().toLowerCase() ?? '';
    final amount =
        double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;

    // Determine if it's a credit or debit based on direction or type
    final isCredit =
        direction == 'credit' || type == 'deposit' || type == 'credit';

    // Use arrow icons - down arrow for incoming (credit), up arrow for outgoing (debit)
    IconData icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    String title;

    // Set title based on transaction type
    if (isCredit) {
      title = transaction['subtitle'] ?? 'Funds added';
    } else {
      title = transaction['subtitle'] ?? 'Payment';
    }

    return {
      'type': type,
      'title': title,
      'description':
          transaction['description'] ?? transaction['subtitle'] ?? title,
      'source': _extractSource(transaction),
      'purpose': transaction['description'] ?? transaction['subtitle'] ?? '',
      'reference':
          transaction['reference']?.toString() ??
          transaction['id']?.toString() ??
          '',
      'id': transaction['id']?.toString() ?? '',
      'date': _formatDate(transaction['createdAt']),
      'time': _formatTime(transaction['createdAt']),
      'amount': isCredit ? amount : -amount,
      'icon': icon,
      'status': _mapStatus(transaction['status']),
    };
  }

  String _extractSource(Map<String, dynamic> transaction) {
    final subtitle = transaction['subtitle']?.toString() ?? '';
    final description = transaction['description']?.toString() ?? '';

    // Extract source from subtitle or description
    if (subtitle.contains('from')) {
      final parts = subtitle.split('from');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }

    if (description.contains('from')) {
      final parts = description.split('from');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }

    return 'Bien Casa Wallet';
  }

  String _mapStatus(dynamic status) {
    if (status == null) return 'completed';

    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'successful':
      case 'success':
      case 'completed':
        return 'completed';
      case 'pending':
        return 'pending';
      case 'failed':
      case 'failure':
        return 'failed';
      default:
        return 'completed';
    }
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return '';
    }
  }

  String _formatTime(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final period = date.hour >= 12 ? 'pm' : 'am';
      return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return '';
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Helper widget to display naira symbol using SVG
  Widget _buildNairaSymbol({double size = 16, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/naira.svg',
      width: size,
      height: size,
      color: color ?? Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            final appModeController = Get.find<AppModeController>();
            if (appModeController.isHomeOwnerMode) {
              Get.offAllNamed('/home-owner-main');
            } else {
              Get.offAllNamed('/user-home');
            }
          },
          child: const Icon(CupertinoIcons.back, color: Colors.black, size: 28),
        ),
        title:
            _walletData?['accountName'] != null
                ? Text(
                  _capitalizeFirstLetter(_walletData!['accountName']),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ProductSans',
                  ),
                )
                : null,
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/notification.svg',
                  width: 24,
                  height: 24,
                  color: Colors.black,
                ),
                onPressed: () => Get.toNamed('/wallet-notifications'),
              ),
              Positioned(
                top: 12,
                right: 12,
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
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading ? const WalletSkeletonLoader() : _buildWalletContent(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget? _buildBottomNavBar() {
    final appModeController = Get.find<AppModeController>();
    return appModeController.isHomeOwnerMode
        ? null
        : CustomBottomNavBar(
          currentIndex: 3,
          onTap: (index) {
            switch (index) {
              case 0:
                Get.offAllNamed('/user-home');
                break;
              case 1:
                Get.offAllNamed('/flatmate');
                break;
              case 2:
                Get.toNamed('/chat-list');
                break;
              case 3:
                // Already on wallet screen
                break;
              case 4:
                Get.offAllNamed('/profile');
                break;
            }
          },
        );
  }

  Widget _buildWalletContent() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Black Wallet Card
            _buildWalletCard(),

            const SizedBox(height: 24),

            // Financial Overview for Home Owners
            _buildFinancialOverview(),

            // Recent Activities
            _buildRecentActivitiesHeader(),

            const SizedBox(height: 16),

            // Activities List
            _buildActivitiesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background patterns and logo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Full background splash image
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.6,
                      child: Image.asset(
                        'assets/image/splash_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance and Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Balance',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'ProductSans',
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _hideBalance = !_hideBalance;
                                });
                              },
                              child: Icon(
                                _hideBalance
                                    ? CupertinoIcons.eye_slash
                                    : CupertinoIcons.eye,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: _buildNairaSymbol(
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _hideBalance
                                  ? '****'
                                  : _formatAmount(_walletBalance),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ProductSans',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'ProductSans',
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _walletData?['status'] ?? 'Active',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ProductSans',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Account Number and Bank Name Row
              if (_walletData?['accountNumber'] != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Number Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Number',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                              fontFamily: 'ProductSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                _walletData?['accountNumber'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'ProductSans',
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: _walletData?['accountNumber'] ?? '',
                                    ),
                                  );
                                  Get.snackbar(
                                    'Copied',
                                    'Account number copied to clipboard',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 2),
                                    margin: const EdgeInsets.all(10),
                                  );
                                },
                                child: Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Bank Name Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Bank',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontFamily: 'ProductSans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _walletData?['bankName'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'ProductSans',
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action Buttons inside card
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAddFundsModal(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add Funds',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'ProductSans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showWithdrawModal(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Withdraw',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'ProductSans',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return GetBuilder<AppModeController>(
      builder: (appModeController) {
        if (appModeController.isHomeOwnerMode) {
          return GetBuilder<HomeOwnerController>(
            builder: (homeOwnerController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRevenueCard(
                          'Monthly Rental Income',
                          homeOwnerController.monthlyRentIncome,
                          Colors.green,
                          Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRevenueCard(
                          'Total Security Deposits',
                          homeOwnerController.totalSecurityDeposits,
                          Colors.blue,
                          Icons.account_balance_wallet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRevenueCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildNairaSymbol(size: 14, color: color),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  _formatAmount(amount),
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
          ),
        ),
        Row(
          children: [
            if (_isRefreshing)
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 8),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            TextButton(
              onPressed: () => Get.toNamed('/wallet-activities'),
              child: const Text(
                'View all',
                style: TextStyle(color: Colors.grey, fontFamily: 'ProductSans'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitiesList() {
    if (_recentWalletActivities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'ProductSans',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
          _recentWalletActivities
              .take(5)
              .map((activity) => _buildActivityItem(activity))
              .toList(),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final bool isPositive = activity['amount'] > 0;

    return GestureDetector(
      onTap: () => _showTransactionDetails(activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            // Icon with background
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color:
                    isPositive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                size: 20,
                color: isPositive ? Colors.green[600] : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'ProductSans',
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activity['date']}, ${activity['time']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ],
              ),
            ),

            // Amount and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPositive ? '+' : '-',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                        color: isPositive ? Colors.green[600] : Colors.black,
                      ),
                    ),
                    _buildNairaSymbol(
                      size: 14,
                      color: isPositive ? Colors.green[600] : Colors.black,
                    ),
                    Text(
                      activity['amount']
                          .abs()
                          .toStringAsFixed(2)
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                        color: isPositive ? Colors.green[600] : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      activity['status'],
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(activity['status']),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(activity['status']),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'successful':
        return Colors.green[600]!;
      case 'pending':
        return Colors.orange[600]!;
      case 'failed':
        return Colors.red[600]!;
      default:
        return Colors.green[600]!;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'Successful';
      case 'successful':
        return 'Successful';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return 'Successful';
    }
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    // Use the transaction ID for API call
    final transactionId = transaction['id'] ?? transaction['reference'] ?? '3';

    Get.bottomSheet(
      TransactionDetailsBottomSheet(
        transactionId: transactionId,
        initialData: transaction,
      ),
      isScrollControlled: true,
    );
  }

  void _showAddFundsModal() {
    Get.bottomSheet(
      AddFundsModal(
        accountNumber: _walletData?['accountNumber'],
        accountName: _walletData?['accountName'],
        bankName: _walletData?['bankName'],
      ),
      isScrollControlled: true,
    );
  }

  void _showWithdrawModal() {
    Get.to(() => WithdrawScreen(availableBalance: _walletBalance));
  }
}
