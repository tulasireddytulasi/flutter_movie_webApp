import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moviewebapp/app/models/post_model.dart';
import 'widgets/preview_info_card.dart';

class ImmersivePostDetailScreen extends StatefulWidget {
  final PostModel post;

  const ImmersivePostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<ImmersivePostDetailScreen> createState() => _ImmersivePostDetailScreenState();
}

class _ImmersivePostDetailScreenState extends State<ImmersivePostDetailScreen> {
  late final PageController _pageController;

  // ValueNotifiers to isolate rebuilds and eliminate setState overhead
  final ValueNotifier<bool> _showUINotifier = ValueNotifier<bool>(true);
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isZoomedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showUINotifier.dispose();
    _currentIndexNotifier.dispose();
    _isZoomedNotifier.dispose();
    super.dispose();
  }

  void _toggleUI() {
    _showUINotifier.value = !_showUINotifier.value;
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
            // 1. Full-Bleed Media Display (Rebuilds only when zoom state changes)
            ValueListenableBuilder<bool>(
              valueListenable: _isZoomedNotifier,
              builder: (context, isZoomed, child) {
                return _buildMediaViewer(isZoomed);
              },
            ),

            // 2. Overlay Metadata & Controls (Rebuilds only when UI visibility toggles)
            ValueListenableBuilder<bool>(
              valueListenable: _showUINotifier,
              builder: (context, showUI, child) {
                return AnimatedOpacity(
                  opacity: showUI ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !showUI,
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
                              // Pagination Dots Indicator (Rebuilds only on index change)
                              if (widget.post.imageUrls.length > 1) ...[
                                ValueListenableBuilder<int>(
                                  valueListenable: _currentIndexNotifier,
                                  builder: (context, currentIndex, child) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        widget.post.imageUrls.length,
                                            (index) => AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                          width: currentIndex == index ? 8.0 : 6.0,
                                          height: currentIndex == index ? 8.0 : 6.0,
                                          decoration: BoxDecoration(
                                            color: currentIndex == index
                                                ? const Color(0xFFFFFFFF)
                                                : const Color(0xFFFFFFFF).withValues(alpha: 0.4),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12.0),
                              ],

                              PreviewInfoCard(post: widget.post),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaViewer(bool isZoomed) {
    final images = widget.post.imageUrls.isNotEmpty ? widget.post.imageUrls : [widget.post.avatarUrl];

    return PageView.builder(
      controller: _pageController,
      itemCount: images.length,
      physics: isZoomed ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      onPageChanged: (index) {
        _currentIndexNotifier.value = index;
        _isZoomedNotifier.value = false;
      },
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          onInteractionUpdate: (details) {
            final bool currentlyZoomed = details.scale > 1.0;
            if (_isZoomedNotifier.value != currentlyZoomed) {
              _isZoomedNotifier.value = currentlyZoomed;
            }
          },
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