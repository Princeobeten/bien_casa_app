import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bien_casa/app/screens/user/home/property/detail_widgets/full_screen_gallery.dart';

class GalleryIcon extends StatefulWidget {
  final bool isWhite;
  final double size;
  final double padding;
  final double iconSize;
  final List<String> images;
  final int currentIndex;
  final VoidCallback? onTap;

  const GalleryIcon({
    super.key,
    this.isWhite = true,
    this.size = 32.0,
    this.padding = 6.0,
    this.iconSize = 16.0,
    required this.images,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  State<GalleryIcon> createState() => _GalleryIconState();
}

class _GalleryIconState extends State<GalleryIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show full screen gallery
        Get.to(
          () => FullScreenGallery(
            images: widget.images,
            initialIndex: widget.currentIndex,
          ),
          fullscreenDialog: true,
        );

        // Call the original onTap if provided
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Container(
        padding: EdgeInsets.all(widget.padding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              widget.isWhite
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black.withOpacity(0.6),
        ),
        child: Icon(
          Icons.remove_red_eye_outlined,
          color: widget.isWhite ? Colors.black : Colors.white,
          size: widget.iconSize,
        ),
      ),
    );
  }
}
