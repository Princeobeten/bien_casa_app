import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlatmateAppBar extends StatefulWidget {
  const FlatmateAppBar({super.key});

  @override
  State<FlatmateAppBar> createState() => _FlatmateAppBarState();
}

class _FlatmateAppBarState extends State<FlatmateAppBar> {
  String _selectedBudget = 'NGN50k - NGN100k';
  final List<String> _budgetRanges = [
    'NGN50k - NGN100k',
    'NGN100k - NGN200k',
    'NGN200k - NGN500k',
    'NGN500k - NGN1M',
    'NGN1M+',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Top row with budget dropdown, search icon, filter and notification
          Row(
            children: [
              // Budget dropdown
              GestureDetector(
                onTap: _showBudgetPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 18, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        _selectedBudget,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ProductSans',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Search icon
              GestureDetector(
                onTap: () => _showSearchModal(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/search icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Filter icon
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/filter icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Notification icon
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/notification.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSearchModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Search Campaigns',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ProductSans',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              
              // Search field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'ProductSans',
                      color: Colors.grey[400],
                    ),
                    prefixIcon: SvgPicture.asset(
                      'assets/icons/search icon.svg',
                      width: 22,
                      height: 22,
                      fit: BoxFit.scaleDown,
                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (value) {
                    // Handle search
                    Navigator.pop(context);
                    // TODO: Implement search functionality
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // Search button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Implement search functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Budget Range',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'ProductSans',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              _budgetRanges.length,
              (index) => ListTile(
                onTap: () {
                  setState(() {
                    _selectedBudget = _budgetRanges[index];
                  });
                  Navigator.pop(context);
                },
                title: Text(
                  _budgetRanges[index],
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontWeight: _selectedBudget == _budgetRanges[index]
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: _selectedBudget == _budgetRanges[index]
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
