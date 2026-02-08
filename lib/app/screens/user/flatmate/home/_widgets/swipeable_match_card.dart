import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SwipeableMatchCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool isBackground; // Added parameter for background cards

  const SwipeableMatchCard({
    super.key,
    required this.data,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.isBackground = false, // Default is not a background card
  });

  @override
  State<SwipeableMatchCard> createState() => _SwipeableMatchCardState();
}

class _SwipeableMatchCardState extends State<SwipeableMatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Offset _dragPosition = Offset.zero;
  double _dragPercentage = 0.0;
  double _rotationFactor = 0.0;
  bool _isDragging = false;
  late CurvedAnimation _springCurve;

  // Swipe status
  static const double _swipeThreshold = 0.5; // 50% of screen width
  static const double _maxRotation = 0.2; // max rotation in radians
  static const double _maxScale = 0.95; // max scale when card is at rest
  static const double _initialRotation = -0.084; // -4.82 degrees in radians

  // Indication overlays
  double _likeOpacity = 0.0;
  double _nopeOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Use a spring curve for more natural motion
    _springCurve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.addListener(() {
      if (_animationController.isAnimating && mounted) {
        setState(() {
          // Use the spring curve for smoother movement
          final springValue = _springCurve.value;

          _dragPosition = Offset.lerp(_dragPosition, Offset.zero, springValue)!;
          // Use spring value for rotation and drag percentage too
          _rotationFactor = _rotationFactor * (1.0 - springValue);
          _dragPercentage = _dragPercentage * (1.0 - springValue);

          // Fade out indicators smoothly
          _likeOpacity = math.min(
            1.0,
            math.max(0.0, _likeOpacity * (1.0 - springValue)),
          );
          _nopeOpacity = math.min(
            1.0,
            math.max(0.0, _nopeOpacity * (1.0 - springValue)),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Calculate the max drag distance as 60% of screen width
    final maxDrag = size.width * 0.6;

    // Calculate scale based on drag (slightly larger when at rest)
    final scale =
        _isDragging
            ? _maxScale -
                (_dragPercentage.abs() * 0.1) // Shrink a bit when dragging
            : _maxScale;

    // Calculate rotation based on horizontal drag or use initial rotation when at rest
    final double rotation =
        _isDragging
            ? _rotationFactor * _maxRotation
            : (widget.isBackground
                ? 0.0
                : _initialRotation); // Apply initial rotation only to non-background card at rest

    // For background cards, just show the card without gesture detection or animations
    if (widget.isBackground) {
      return Center(child: _buildCard(context));
    }

    // For foreground (interactive) card
    return Center(
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _dragPosition += details.delta;
            _dragPercentage = _dragPosition.dx / maxDrag;
            _rotationFactor = _dragPosition.dx / maxDrag;

            // Update overlay opacity based on drag percentage
            _likeOpacity = math.min(1.0, math.max(0.0, _dragPercentage));
            _nopeOpacity = math.min(1.0, math.max(0.0, -_dragPercentage));
          });
        },
        onPanEnd: (details) {
          // Determine if the drag was fast enough to trigger a swipe
          final velocity = details.velocity.pixelsPerSecond.dx;
          final velocityThreshold =
              size.width * 1.5; // Pixels per second threshold

          if (_dragPercentage.abs() > _swipeThreshold ||
              velocity.abs() > velocityThreshold) {
            // Swipe detected
            if (_dragPercentage > 0) {
              // Swipe right - like
              _completeSwipeAnimation(true);
            } else {
              // Swipe left - nope
              _completeSwipeAnimation(false);
            }
          } else {
            // Reset position
            _resetPosition();
          }
        },
        child: Transform.translate(
          offset: _dragPosition,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main Card
                  _buildCard(context),

                  // Like indicator overlay
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Opacity(
                        opacity: _likeOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'LIKE',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Nope indicator overlay
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: Opacity(
                        opacity: _nopeOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'NOPE',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Complete the swipe animation and trigger callback
  void _completeSwipeAnimation(bool isLike) {
    final size = MediaQuery.of(context).size;

    // Provide haptic feedback immediately
    HapticFeedback.mediumImpact();

    // Execute callbacks immediately rather than waiting
    if (isLike) {
      widget.onSwipeRight();
    } else {
      widget.onSwipeLeft();
    }

    // Animate the card off screen with a smoother curve
    final targetX = isLike ? size.width * 1.5 : -size.width * 1.5;
    final targetY =
        isLike ? -50.0 : 50.0; // Add slight vertical movement for natural feel

    // Use AnimatedBuilder for smoother off-screen animation
    final animationDuration = const Duration(milliseconds: 200);

    if (mounted) {
      setState(() {
        // Update the card position immediately
        _dragPosition = Offset(targetX, targetY);

        // Set opacity to full
        if (isLike) {
          _likeOpacity = 1.0;
          _nopeOpacity = 0.0;
        } else {
          _likeOpacity = 0.0;
          _nopeOpacity = 1.0;
        }
      });
    }

    // Reset position after the animation completes
    Future.delayed(
      animationDuration + const Duration(milliseconds: 100),
      _resetPosition,
    );
  }

  // Reset card position
  void _resetPosition() {
    if (mounted) {
      // Check if widget is still in the tree
      setState(() {
        _isDragging = false;
        // Ensure rotation factor is reset to allow initial rotation to take effect
        _rotationFactor = 0.0;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  Widget _buildCard(BuildContext context) {
    final data = widget.data;
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.859, // Increased card width to match proportions
      height: size.height * 0.6, // Increased card height by ~30%
      decoration: BoxDecoration(
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
        fit: StackFit.expand,
        children: [
          // User Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              data['image'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.blue[100],
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.blueGrey,
                      ),
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

          // User Info
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name and Age
                Row(
                  children: [
                    Text(
                      '${data['name']}, ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      '${data['age'] ?? '??'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // User Details
                Row(
                  children: [
                    Text(
                      '${data['gender'] ?? 'Male'} | ${data['religion'] ?? 'Christian'} | ${data['occupation'] ?? 'Doctor'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        height: 1,
                        fontSize: 16,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Salary and Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${data['minPrice'] ?? '400k'} - ${data['maxPrice'] ?? '600k'}/yr',
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0,
                        color: Colors.white,
                      ),
                    ),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['location'] ?? 'Abuja',
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
