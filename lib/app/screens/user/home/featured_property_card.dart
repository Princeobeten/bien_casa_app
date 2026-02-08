import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';

class FeaturedPropertyCard extends StatefulWidget {
  final List<Map<String, dynamic>> properties; // Set of 3 properties
  final int currentSetIndex; // Current set index (0, 1, 2 for 3 sets)
  final int totalSets; // Total number of sets
  final Function(int)? onSetChange; // Callback when set changes
  final Function(Map<String, dynamic>)? onPropertyTap; // Callback when property is tapped

  const FeaturedPropertyCard({
    super.key,
    required this.properties,
    this.currentSetIndex = 0,
    this.totalSets = 3,
    this.onSetChange,
    this.onPropertyTap,
  });

  @override
  State<FeaturedPropertyCard> createState() => _FeaturedPropertyCardState();
}

class _FeaturedPropertyCardState extends State<FeaturedPropertyCard>
    with TickerProviderStateMixin {
  int _currentPropertyIndex = 0; // Index within the current set (0, 1, or 2)
  late AnimationController _progressController;
  late AnimationController _kenBurnsController;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _alignmentAnimation;
  Timer? _autoPlayTimer;
  static const Duration _itemDuration = Duration(
    seconds: 7,
  ); // 7 seconds per property

  // Get current property from the set
  Map<String, dynamic> get _currentProperty {
    if (_currentPropertyIndex >= 0 && _currentPropertyIndex < widget.properties.length) {
      return widget.properties[_currentPropertyIndex];
    }
    return widget.properties.first;
  }

  String get _currentImage {
    final images = _currentProperty['images'];
    if (images != null && images is List && images.isNotEmpty) {
      return images[0]; // Take first image of each property
    }
    return _currentProperty['imageUrl'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _itemDuration,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _moveToNextProperty();
      }
    });

    // Ken Burns Effect Animation
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: _itemDuration,
    );

    _initializeKenBurnsAnimation();
    _startAutoPlay();
  }

  void _initializeKenBurnsAnimation() {
    // Zoom in effect
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _kenBurnsController,
      curve: Curves.easeInOut,
    ));

    // Pan effect - different direction for each property
    final alignments = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
      Alignment.center,
    ];
    final startAlignment = alignments[_currentPropertyIndex % alignments.length];
    final endAlignment = alignments[(_currentPropertyIndex + 2) % alignments.length];

    _alignmentAnimation = AlignmentTween(
      begin: startAlignment,
      end: endAlignment,
    ).animate(CurvedAnimation(
      parent: _kenBurnsController,
      curve: Curves.easeInOut,
    ));

    _kenBurnsController.forward(from: 0);
  }

  @override
  void didUpdateWidget(FeaturedPropertyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When set changes, reset to first property in new set
    if (oldWidget.currentSetIndex != widget.currentSetIndex) {
      setState(() {
        _currentPropertyIndex = 0;
      });
      _initializeKenBurnsAnimation();
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _kenBurnsController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _progressController.forward(from: 0);
  }

  void _moveToNextProperty() {
    print('Current property: $_currentPropertyIndex of ${widget.properties.length}');
    
    if (_currentPropertyIndex < widget.properties.length - 1) {
      // Move to next property in SAME set
      setState(() {
        _currentPropertyIndex++;
      });
      print('Moving to next property in same set: $_currentPropertyIndex');
      _initializeKenBurnsAnimation();
      _progressController.forward(from: 0);
    } else {
      // Finished all 3 properties in current set
      // NOW move to next set
      print('Finished all ${widget.properties.length} properties, moving to next set');
      setState(() {
        _currentPropertyIndex = 0; // Reset to first property for next set
      });
      _initializeKenBurnsAnimation();

      if (widget.currentSetIndex < widget.totalSets - 1) {
        // Move to next set
        widget.onSetChange?.call(widget.currentSetIndex + 1);
      } else {
        // Loop back to first set
        widget.onSetChange?.call(0);
      }
    }
  }

  void _moveToPreviousProperty() {
    if (_currentPropertyIndex > 0) {
      // Move to previous property in current set
      setState(() {
        _currentPropertyIndex--;
      });
      _initializeKenBurnsAnimation();
      _progressController.forward(from: 0);
    } else {
      // Move to previous set
      if (widget.currentSetIndex > 0) {
        widget.onSetChange?.call(widget.currentSetIndex - 1);
      }
    }
  }

  void _pauseAutoPlay() {
    _progressController.stop();
    _kenBurnsController.stop();
  }

  void _resumeAutoPlay() {
    _progressController.forward();
    _kenBurnsController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Set to min to prevent overflow
      children: [
        GestureDetector(
          onTapDown: (_) => _pauseAutoPlay(),
          onTapUp: (_) => _resumeAutoPlay(),
          onTapCancel: () => _resumeAutoPlay(),
          onLongPressStart: (_) => _pauseAutoPlay(),
          onLongPressEnd: (_) => _resumeAutoPlay(),
          onTap: () => widget.onPropertyTap?.call(_currentProperty),
          child: Container(
            width: double.infinity,
            height: 350,
            margin: const EdgeInsets.symmetric(
              vertical: 2,
            ), // Further reduced vertical margin
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Property image with Ken Burns Effect
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _kenBurnsController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          alignment: _alignmentAnimation.value,
                          child: child,
                        );
                      },
                      child:
                          _currentImage.startsWith('http')
                              ? Image.network(
                                _currentImage,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.error, color: Colors.red),
                                    ),
                                  );
                                },
                              )
                              : Image.asset(
                                _currentImage,
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                  // Dark overlay for text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5), // Dark at the top
                            Colors.transparent.withOpacity(
                              0.1,
                            ), // More transparent in middle
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.2, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Progress bar at top of card - shows progress through 3 properties in set
                  Positioned(
                    top: 15,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 17.5),
                      height: 3,
                      child: Row(
                        children: List.generate(widget.properties.length, (
                          index,
                        ) {
                          return Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (context, child) {
                                      double progress = 0.0;
                                      if (index < _currentPropertyIndex) {
                                        // Completed properties
                                        progress = 1.0;
                                      } else if (index == _currentPropertyIndex) {
                                        // Current property - show animated progress
                                        progress = _progressController.value;
                                      }
                                      // Future properties remain at 0.0

                                      return Stack(
                                        children: [
                                          // Background (unfilled)
                                          Container(
                                            height: 3,
                                            color: Colors.white.withOpacity(
                                              0.4,
                                            ),
                                          ),
                                          // Foreground (filled progress)
                                          FractionallySizedBox(
                                            widthFactor: progress,
                                            child: Container(
                                              height: 3,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                if (index < widget.properties.length - 1)
                                  const SizedBox(width: 4),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  // Featured tag
                  Positioned(
                    top: 30,
                    left: 16,
                    child: Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'ProductSans Light',
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  
                  // Property details
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Property specs with pill shape
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 72,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildPropertySpec(_currentProperty['size'] ?? ''),
                                const SizedBox(width: 8),
                                _buildPropertySpec(_currentProperty['type'] ?? ''),
                                const SizedBox(width: 8),
                                _buildPropertySpec(_currentProperty['price'] ?? '', isPrice: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Property name
                        Text(
                          _currentProperty['name'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            fontSize: 21,
                            height: 1,
                            letterSpacing: 0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Property address
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _currentProperty['address'] ?? '',
                                style: const TextStyle(
                                  fontFamily: 'ProductSans Light',
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 15),
        // External progress bar
        Container(
          height: 3,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 130),
          child: Row(
            children: List.generate(widget.totalSets, (index) {
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color:
                            index == widget.currentSetIndex
                                ? Colors.black
                                : Color(0xffEAEAEA),
                      ),
                    ),
                    if (index < widget.totalSets - 1) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertySpec(String text, {bool isPrice = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (isPrice)
            SvgPicture.asset(
              'assets/icons/naira.svg',
              width: 13,
              height: 13,
              color: Colors.white,
            ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              fontSize: 13,
              color: Colors.white,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
