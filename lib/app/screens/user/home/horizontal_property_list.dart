import 'package:flutter/material.dart';
import 'property_list_item.dart';

class HorizontalPropertyList extends StatefulWidget {
  final List<Map<String, dynamic>> properties;
  final Function(int)? onItemTap;

  const HorizontalPropertyList({
    super.key,
    required this.properties,
    this.onItemTap,
  });

  @override
  State<HorizontalPropertyList> createState() => _HorizontalPropertyListState();
}

class _HorizontalPropertyListState extends State<HorizontalPropertyList> {
  late PageController _pageController;
  int _currentPage = 0;
  int get _totalPages => (widget.properties.length / 2).ceil();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _pageController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pageController.page!.round() != _currentPage) {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 280, // Increased height to accommodate two stacked cards with margins
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _totalPages,
            itemBuilder: (context, pageIndex) {
              // Calculate the start index for this page
              final startIndex = pageIndex * 2;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    // First item
                    startIndex < widget.properties.length ? PropertyListItem(
                      imageUrl: widget.properties[startIndex]['images'] != null && 
                               (widget.properties[startIndex]['images'] as List).isNotEmpty
                               ? widget.properties[startIndex]['images'][0]
                               : 'assets/image/placeholder.png',
                      name: widget.properties[startIndex]['name'] ?? '',
                      address: widget.properties[startIndex]['address'] ?? '',
                      size: widget.properties[startIndex]['size'] ?? '',
                      type: widget.properties[startIndex]['type'] ?? '',
                      price: widget.properties[startIndex]['price'] ?? '',
                      propertyId: widget.properties[startIndex]['id']?.toString(),
                      onTap: widget.onItemTap != null ? () => widget.onItemTap!(startIndex) : null,
                    ) : const SizedBox(), // Empty if no more items
                    
                    const SizedBox(height: 8), // Space between cards
                    
                    // Second item
                    (startIndex + 1) < widget.properties.length ? PropertyListItem(
                      imageUrl: widget.properties[startIndex + 1]['images'] != null && 
                               (widget.properties[startIndex + 1]['images'] as List).isNotEmpty
                               ? widget.properties[startIndex + 1]['images'][0]
                               : 'assets/image/placeholder.png',
                      name: widget.properties[startIndex + 1]['name'] ?? '',
                      address: widget.properties[startIndex + 1]['address'] ?? '',
                      size: widget.properties[startIndex + 1]['size'] ?? '',
                      type: widget.properties[startIndex + 1]['type'] ?? '',
                      price: widget.properties[startIndex + 1]['price'] ?? '',
                      propertyId: widget.properties[startIndex + 1]['id']?.toString(),
                      onTap: widget.onItemTap != null ? () => widget.onItemTap!(startIndex + 1) : null,
                    ) : const SizedBox(), // Empty if no more items
                  ],
                ),
              );
            },
          ),
        ),
        
        // Progress bar with improved styling
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 120),
          height: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              // Use dot indicators rather than lines
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _currentPage ? 24 : 8,
                height: 3,
                decoration: BoxDecoration(
                  color: index == _currentPage ? Color(0xffBDBDBD) : Color(0xffEAEAEA),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
