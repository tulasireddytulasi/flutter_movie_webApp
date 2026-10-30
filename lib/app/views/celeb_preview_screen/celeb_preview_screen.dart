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

  final ValueNotifier<bool> _showUINotifier = ValueNotifier<bool>(true);
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  // Controls PageView scroll physics based on touch pointer count & zoom state
  final ValueNotifier<bool> _isSwipeLockedNotifier = ValueNotifier<bool>(false);

  // Track transformation state to check zoom accurately
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pageController.dispose();
    _showUINotifier.dispose();
    _currentIndexNotifier.dispose();
    _isSwipeLockedNotifier.dispose();
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
            // 1. Full-Bleed Media Display
            ValueListenableBuilder<bool>(
              valueListenable: _isSwipeLockedNotifier,
              builder: (context, isSwipeLocked, child) {
                return _buildMediaViewer(isSwipeLocked);
              },
            ),

            // 2. Overlay Metadata & Controls
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
                        // Top App Bar Controls
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

                        // Bottom Floating Container & Pagination Dots
                        Positioned(
                          left: 16.0,
                          right: 16.0,
                          bottom: 24.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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

  Widget _buildMediaViewer(bool isSwipeLocked) {
    final images = widget.post.imageUrls.isNotEmpty ? widget.post.imageUrls : [widget.post.avatarUrl];

    return PageView.builder(
      controller: _pageController,
      itemCount: images.length,
      // Keep standard physics, we block gestures upstream using AbsorbPointer
      physics: const BouncingScrollPhysics(),
      onPageChanged: (index) {
        _currentIndexNotifier.value = index;
        _transformationController.value = Matrix4.identity(); // Reset zoom on page change
        _isSwipeLockedNotifier.value = false;
      },
      itemBuilder: (context, index) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isSwipeLockedNotifier,
          builder: (context, isLocked, child) {
            // AbsorbPointer completely blocks PageView from receiving touch events when locked/zoomed
            return AbsorbPointer(
              absorbing: isLocked,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 4.0,
                onInteractionStart: (details) {
                  // If 2 fingers touch or already zoomed, instantly lock swiping
                  if (details.pointerCount >= 2 || _transformationController.value.getMaxScaleOnAxis() > 1.0) {
                    _isSwipeLockedNotifier.value = true;
                  }
                },
                onInteractionUpdate: (details) {
                  final double currentScale = _transformationController.value.getMaxScaleOnAxis();
                  // Lock if zooming/pinching with 2+ fingers OR if current image is scaled in (> 1.0)
                  final bool shouldLock = details.pointerCount >= 2 || currentScale > 1.0;
                  if (_isSwipeLockedNotifier.value != shouldLock) {
                    _isSwipeLockedNotifier.value = shouldLock;
                  }
                },
                onInteractionEnd: (details) {
                  final double currentScale = _transformationController.value.getMaxScaleOnAxis();
                  // Only unlock page swiping if scale snaps completely back to 1.0 and fingers are lifted
                  if (currentScale <= 1.001) {
                    _isSwipeLockedNotifier.value = false;
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
              ),
            );
          },
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