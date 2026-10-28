import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moviewebapp/app/models/post_model.dart';
import 'package:moviewebapp/app/views/twitter_ui/widgets/twitter_like_button.dart';

import 'widgets/card_2.dart';
import 'widgets/preview_info_card.dart';

class ImmersivePostDetailScreen extends StatefulWidget {
  final PostModel post;

  const ImmersivePostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<ImmersivePostDetailScreen> createState() => _ImmersivePostDetailScreenState();
}

class _ImmersivePostDetailScreenState extends State<ImmersivePostDetailScreen> {
  bool _showUI = true;
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: GestureDetector(
        onTap: _toggleUI,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full-Bleed Media Display with Carousel & Pinch-to-Zoom
            _buildMediaViewer(),

            // 2. Overlay Metadata & Controls (Toggles on tap)
            AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showUI,
                child: Stack(
                  children: [
                    // Top App Bar Controls (Back & Options)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            _buildCircleButton(
                              icon: Icons.more_vert,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Floating Glassmorphism Container & Pagination Dots
                    Positioned(
                      left: 16.0,
                      right: 16.0,
                      bottom: 24.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pagination Dots Indicator (if multiple images)
                          if (widget.post.imageUrls.length > 1) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.post.imageUrls.length,
                                    (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                  width: _currentIndex == index ? 8.0 : 6.0,
                                  height: _currentIndex == index ? 8.0 : 6.0,
                                  decoration: BoxDecoration(
                                    color: _currentIndex == index
                                        ? const Color(0xFFFFFFFF)
                                        : const Color(0xFFFFFFFF).withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                          ],

                          PreviewInfoCard(post: widget.post),

                          // Card2(post: widget.post),
                        ],
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

  Widget _buildMediaViewer() {
    final images = widget.post.imageUrls.isNotEmpty ? widget.post.imageUrls : [widget.post.avatarUrl];

    return PageView.builder(
      controller: _pageController,
      itemCount: images.length,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error, color: Colors.white54, size: 32),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFFFFFFF), size: 20.0),
          ),
        ),
      ),
    );
  }


}