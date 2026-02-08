import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../widgets/transaction_details_bottom_sheet.dart';
import '../../../services/wallet_service.dart';

class WalletActivitiesScreen extends StatefulWidget {
  const WalletActivitiesScreen({super.key});

  @override
  State<WalletActivitiesScreen> createState() => _WalletActivitiesScreenState();
}

class _WalletActivitiesScreenState extends State<WalletActivitiesScreen> {
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Status';
  String _selectedMonth = 'Jan';
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _activities = [];

  // Cache management
  static const String _cacheKey = 'wallet_activities_cache';
  static const String _cacheTimestampKey = 'wallet_activities_cache_timestamp';
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  final List<String> _categoryOptions = [
    'All Categories',
    'Credit',
    'Debit',
    'Deposit',
    'Withdrawal',
  ];

  final List<String> _statusOptions = [
    'All Status',
    'Successful',
    'Pending',
    'Failed',
  ];

  final List<String> _monthOptions = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  List<Map<String, dynamic>> get _filteredActivities {
    List<Map<String, dynamic>> filtered = List.from(_activities);
    
    // Filter by category
    if (_selectedCategory != 'All Categories') {
      filtered = filtered.where((activity) {
        final type = activity['type']?.toString().toLowerCase() ?? '';
        final amount = activity['amount'] ?? 0;
        
        switch (_selectedCategory) {
          case 'Credit':
            return amount > 0;
          case 'Debit':
            return amount < 0;
          case 'Deposit':
            return type == 'deposit' || type == 'credit';
          case 'Withdrawal':
            return type == 'withdrawal' || type == 'debit';
          default:
            return true;
        }
      }).toList();
    }
    
    // Filter by status
    if (_selectedStatus != 'All Status') {
      filtered = filtered.where((activity) {
        final status = activity['status']?.toString().toLowerCase() ?? '';
        final selectedStatusLower = _selectedStatus.toLowerCase();
        
        // Map 'Successful' to 'completed' for comparison
        if (selectedStatusLower == 'successful') {
          return status == 'completed' || status == 'successful';
        }
        
        return status == selectedStatusLower;
      }).toList();
    }
    
    // Filter by month
    filtered = filtered.where((activity) {
      final date = activity['date']?.toString() ?? '';
      if (date.isEmpty) return false;
      
      try {
        // Parse date format: DD-MM-YYYY
        final parts = date.split('-');
        if (parts.length >= 2) {
          final month = int.parse(parts[1]);
          final monthIndex = _monthOptions.indexOf(_selectedMonth) + 1;
          return month == monthIndex;
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
      return false;
    }).toList();
    
    return filtered;
  }

  double get _filteredTotalIn {
    double total = 0.0;
    for (var activity in _filteredActivities) {
      if (activity['amount'] > 0) {
        total += activity['amount'];
      }
    }
    return total;
  }

  double get _filteredTotalOut {
    double total = 0.0;
    for (var activity in _filteredActivities) {
      if (activity['amount'] < 0) {
        total += activity['amount'].abs();
      }
    }
    return total;
  }

  Future<void> _loadActivities({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);

    try {
      // Check cache first
      if (!forceRefresh && await _hasCachedData()) {
        await _loadFromCache();
        setState(() => _isLoading = false);
        return;
      }

      print('💰 Loading wallet activities from API...');
      
      // Fetch wallet data with transactions
      final walletsResponse = await WalletService.getUserWallets();
      
      if (walletsResponse['data'] != null) {
        Map<String, dynamic> walletData;
        
        if (walletsResponse['data'] is List) {
          final walletsList = walletsResponse['data'] as List;
          if (walletsList.isEmpty) {
            setState(() => _isLoading = false);
            return;
          }
          walletData = walletsList[0];
        } else {
          walletData = walletsResponse['data'] as Map<String, dynamic>;
        }
        
        // Extract transactions
        final transactions = walletData['recentTransactions'] ?? 
                           walletData['transactions'] ?? 
                           walletData['transactionHistory'] ?? [];
        
        final activities = (transactions as List?)
            ?.map((transaction) => _mapTransactionToActivity(transaction))
            .toList() ?? [];
        
        // Cache the data
        await _cacheActivitiesData(walletData, activities);
        
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
        
        print('💰 ✅ Activities loaded: ${activities.length} transactions');
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading activities: $e');
      
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
          'Failed to load activities: ${e.toString().replaceAll('Exception: ', '')}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
      
      setState(() => _isLoading = false);
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
      return now.difference(cacheTime) < _cacheValidDuration;
    } catch (e) {
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
          cachedData['activities'] ?? []
        );
        
        final activitiesWithIcons = cachedActivities.map((activity) {
          final amount = activity['amount'] ?? 0;
          final isPositive = amount > 0;
          IconData icon = isPositive ? Icons.arrow_downward : Icons.arrow_upward;
          
          return {
            ...activity,
            'icon': icon,
          };
        }).toList();
        
        setState(() {
          _activities = activitiesWithIcons;
        });
        
        print('💰 ✅ Loaded activities from cache');
      }
    } catch (e) {
      print('❌ Error loading from cache: $e');
    }
  }

  Future<void> _cacheActivitiesData(
    Map<String, dynamic>? walletData,
    List<Map<String, dynamic>> activities,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create a serializable version of activities (without IconData)
      final serializableActivities = activities.map((activity) {
        final serializableActivity = Map<String, dynamic>.from(activity);
        serializableActivity.remove('icon');
        return serializableActivity;
      }).toList();
      
      final cacheData = {
        'walletData': walletData,
        'activities': serializableActivities,
      };
      
      await prefs.setString(_cacheKey, jsonEncode(cacheData));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      print('💰 ✅ Activities cached successfully');
    } catch (e) {
      print('❌ Error caching activities: $e');
    }
  }

  Future<void> _onRefresh() async {
    await _loadActivities(forceRefresh: true);
  }

  Map<String, dynamic> _mapTransactionToActivity(Map<String, dynamic> transaction) {
    final type = transaction['type']?.toString().toLowerCase() ?? '';
    final direction = transaction['direction']?.toString().toLowerCase() ?? '';
    final amount = double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
    
    final isCredit = direction == 'credit' || type == 'deposit' || type == 'credit';
    IconData icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    
    String title;
    if (isCredit) {
      title = transaction['subtitle'] ?? 'Funds added';
    } else {
      title = transaction['subtitle'] ?? 'Payment';
    }
    
    return {
      'type': type,
      'title': title,
      'description': transaction['description'] ?? transaction['subtitle'] ?? title,
      'source': _extractSource(transaction),
      'purpose': transaction['description'] ?? transaction['subtitle'] ?? '',
      'reference': transaction['reference']?.toString() ?? transaction['id']?.toString() ?? '',
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
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${date.month.toString()}/${date.day.toString()}, ${hour.toString()}:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return '';
    }
  }

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Get.back(),
          child: const Icon(CupertinoIcons.back, color: Colors.black, size: 28),
        ),
        centerTitle: true,
        title: const Text(
          'Transactions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'ProductSans',
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF26306A)))
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter section with white background
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Filter dropdowns
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  _selectedCategory,
                                  _categoryOptions,
                                  (value) => setState(() => _selectedCategory = value!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown(
                                  _selectedStatus,
                                  _statusOptions,
                                  (value) => setState(() => _selectedStatus = value!),
                                ),
                              ),
                            ],
                          ),
                          
                          
                          // Ads Banner
                        ],
                      ),
                    ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildSMSAlertBanner(),
                          ),

                    const SizedBox(height: 20),

                    // Bottom section with white background and rounded corners
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                           Radius.circular(20)
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Month selector
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMonthDropdown(),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // In/Out summary (using filtered totals)
                            Row(
                              children: [
                                Text(
                                  'In ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                                _buildNairaSymbol(size: 14, color: Colors.black),
                                Text(
                                  _formatAmount(_filteredTotalIn),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Text(
                                  'Out ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                                _buildNairaSymbol(size: 14, color: Colors.black),
                                Text(
                                  _formatAmount(_filteredTotalOut),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: 'ProductSans',
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Horizontal divider line
                            Container(
                              height: 1,
                              color: Colors.grey[100],
                              margin: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            
                            // Activities list
                            if (_filteredActivities.isEmpty)
                              _buildEmptyState()
                            else
                              ..._filteredActivities.map((activity) => _buildActivityItem(activity)),
                            
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown(String value, List<String> options, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[100]!),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.05),
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontFamily: 'ProductSans',
          ),
          dropdownColor: Colors.grey[50],
          elevation: 0,
          borderRadius: BorderRadius.circular(8),
          onChanged: onChanged,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMonth,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: 'ProductSans',
          ),
          dropdownColor: Colors.white,
          elevation: 0,
          borderRadius: BorderRadius.circular(8),
          onChanged: (value) => setState(() => _selectedMonth = value!),
          items: _monthOptions.map((String month) {
            return DropdownMenuItem<String>(
              value: month,
              child: Text(month),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSMSAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:  Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'ProductSans',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover amazing offers and services tailored for you',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[200],
                    fontFamily: 'ProductSans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.campaign,
            size: 36,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final bool isPositive = activity['amount'] > 0;

    return GestureDetector(
      onTap: () {
        // Use the transaction ID for API call
        final transactionId = activity['id'] ?? activity['reference'] ?? '3';
        
        Get.bottomSheet(
          TransactionDetailsBottomSheet(
            transactionId: transactionId,
            initialData: activity,
          ),
          isScrollControlled: true,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          // border: Border(
          //   bottom: BorderSide(
          //     color: Color(0xFFF5F5F5),
          //     width: 1,
          //   ),
          // ),
        ),
        child: Row(
          children: [
            // Icon with background
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isPositive
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
                      fontWeight: FontWeight.w500,
                      fontFamily: 'ProductSans',
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['time'],
                    style: TextStyle(
                      fontSize: 13,
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
                      _formatAmount(activity['amount'].abs()),
                      style: TextStyle(
                        fontSize: 16,
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
                    color: _getStatusColor(activity['status']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(activity['status']),
                    style: TextStyle(
                      fontSize: 11,
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
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
