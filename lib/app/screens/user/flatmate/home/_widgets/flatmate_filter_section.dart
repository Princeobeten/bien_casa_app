import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlatmateFilterSection extends StatefulWidget {
  final Function(int) onTabChanged;
  final int initialTabIndex;
  
  const FlatmateFilterSection({
    super.key, 
    required this.onTabChanged,
    this.initialTabIndex = 0,
  });

  @override
  State<FlatmateFilterSection> createState() => _FlatmateFilterSectionState();
}

class _FlatmateFilterSectionState extends State<FlatmateFilterSection> {
  late int _selectedTabIndex;
  final List<String> _tabs = ['Hot', 'Flatmates', 'Flats', 'Short-stay'];

  @override
  void initState() {
    super.initState();
    // Initialize with the parent's selected tab
    _selectedTabIndex = widget.initialTabIndex;
  }
  
  @override
  void didUpdateWidget(covariant FlatmateFilterSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tab selection if parent changed it
    if (widget.initialTabIndex != _selectedTabIndex) {
      setState(() {
        _selectedTabIndex = widget.initialTabIndex;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Column(
        children: [
          // Filter tabs row with scrollable tabs and fixed location dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Scrollable tabs section
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Hot tab with fire icon
                      _buildTab(0, isHot: true),

                      const SizedBox(width: 10),

                      // Flatmates tab
                      _buildTab(1),

                      const SizedBox(width: 10),

                      // Flats tab
                      _buildTab(2),

                      const SizedBox(width: 10),

                      // Short-stay tab
                      _buildTab(3),
                    ],
                  ),
                ),
              ),

              // Location dropdown (fixed on right)
              _buildLocationDropdown(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, {bool isHot = false}) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        // Call the callback to notify parent about tab change
        widget.onTabChanged(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: Colors.black, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHot) ...[
              SvgPicture.asset(
                'assets/icons/fire.svg',
                width: 15,
                height: 20,
                colorFilter: ColorFilter.mode(
                  Color(0xffDC3545),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              _tabs[index],
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black,
                fontFamily: 'ProductSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List of available locations
  final List<String> _locations = ['Abuja', 'Lagos', 'Calabar'];
  String _selectedLocation = 'Abuja';

  Widget _buildLocationDropdown() {
    return GestureDetector(
      onTap: () {
        _showLocationPicker(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 20, color: Colors.black),
            const SizedBox(width: 4),
            Text(
              _selectedLocation,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                fontFamily: 'ProductSans',
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // Show location picker bottom sheet
  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Select Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
                ...List.generate(
                  _locations.length,
                  (index) => ListTile(
                    onTap: () {
                      setState(() {
                        _selectedLocation = _locations[index];
                      });
                      Navigator.pop(context);
                    },
                    title: Text(
                      _locations[index],
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontWeight:
                            _selectedLocation == _locations[index]
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        _selectedLocation == _locations[index]
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
