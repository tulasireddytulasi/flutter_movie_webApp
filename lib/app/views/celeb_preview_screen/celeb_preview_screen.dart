import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moviewebapp/app/models/post_model.dart';
import 'widgets/preview_info_card.dart';

typedef _ImageTransform = ({double scale, Offset offset});

class ImmersivePostDetailScreen extends StatefulWidget {
  final PostModel post;

  const ImmersivePostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<ImmersivePostDetailScreen> createState() => _ImmersivePostDetailScreenState();
}

class _ImmersivePostDetailScreenState extends State<ImmersivePostDetailScreen> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;

  final ValueNotifier<bool> _showUINotifier = ValueNotifier<bool>(true);
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  final Set<int> _activePointers = {};
  final _pointerCount = ValueNotifier<int>(0);
  final _transform = ValueNotifier<_ImageTransform>((scale: 1.0, offset: Offset.zero));
  Animation<double>? _scaleAnimation;
  Animation<Offset>? _offsetAnimation;
  double _baseScale = 1.0;
  Offset _doubleTapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))
      ..addListener(() {
        _transform.value = (
          scale: _scaleAnimation?.value ?? _transform.value.scale,
          offset: _offsetAnimation?.value ?? _transform.value.offset,
        );
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transform.dispose();
    _pointerCount.dispose();
    _pageController.dispose();
    _showUINotifier.dispose();
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  void _toggleUI() {
    _showUINotifier.value = !_showUINotifier.value;
  }

  // Each newly selected image starts centered at its original scale.
  void _resetTransform() {
    _animationController.stop();
    _baseScale = 1.0;
    _transform.value = (scale: 1.0, offset: Offset.zero);
  }

  // Keep panning within the viewport boundaries used by imageview.
  Offset _clampOffset(Offset offset, double scale, Size viewportSize) {
    if (scale <= 1.0) return Offset.zero;
    final maxDx = viewportSize.width * (scale - 1) / 2;
    final maxDy = viewportSize.height * (scale - 1) / 2;
    return Offset(offset.dx.clamp(-maxDx, maxDx), offset.dy.clamp(-maxDy, maxDy));
  }

  // Animate double-tap zoom and spring-back without rebuilding the overlays.
  void _animateToTransform({required double scale, required Offset offset, Curve curve = Curves.easeOutCubic}) {
    final animation = _animationController.drive(CurveTween(curve: curve));
    _scaleAnimation = Tween<double>(begin: _transform.value.scale, end: scale).animate(animation);
    _offsetAnimation = Tween<Offset>(begin: _transform.value.offset, end: offset).animate(animation);
    _animationController.forward(from: 0);
  }

  // Toggle between 1x and 2.5x, zooming toward the double-tapped position.
  void _handleDoubleTap(Size viewportSize) {
    if (_activePointers.length > 1) return;
    final scale = _transform.value.scale > 1.0 ? 1.0 : 2.5;
    final center = Offset(viewportSize.width / 2, viewportSize.height / 2);
    final offset = -(_doubleTapPosition - center) * (scale - 1);
    _animateToTransform(scale: scale, offset: _clampOffset(offset, scale, viewportSize));
  }

  // Disable page swiping during a pinch without blocking image gestures.
  void _updatePointer(int pointer, {required bool down}) {
    if (down) {
      _activePointers.add(pointer);
    } else {
      _activePointers.remove(pointer);
    }
    _baseScale = _transform.value.scale;
    _pointerCount.value = _activePointers.length;
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
            _buildMediaViewer(),

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
                                _buildCircleButton(icon: Icons.arrow_back, onTap: () => Navigator.of(context).pop()),
                                _buildCircleButton(icon: Icons.more_vert, onTap: () {}),
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

  Widget _buildMediaViewer() {
    final images = widget.post.imageUrls.isNotEmpty ? widget.post.imageUrls : [widget.post.avatarUrl];

    return Listener(
      onPointerDown: (event) => _updatePointer(event.pointer, down: true),
      onPointerUp: (event) => _updatePointer(event.pointer, down: false),
      onPointerCancel: (event) => _updatePointer(event.pointer, down: false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
          return ValueListenableBuilder<int>(
            valueListenable: _pointerCount,
            builder: (context, fingerCount, _) => ValueListenableBuilder<_ImageTransform>(
              valueListenable: _transform,
              builder: (context, transform, _) {
                final maxDx = viewportSize.width * (transform.scale - 1) / 2;
                final atHorizontalEdge = transform.offset.dx.abs() >= maxDx - 2.0;
                final allowPageSwipe = fingerCount <= 1 && (transform.scale <= 1.0 || atHorizontalEdge);

                return PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  physics: allowPageSwipe ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    _currentIndexNotifier.value = index;
                    _resetTransform();
                  },
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: _toggleUI,
                    onDoubleTapDown: (details) {
                      _doubleTapPosition = details.localPosition;
                    },
                    onDoubleTap: () => _handleDoubleTap(viewportSize),
                    onScaleStart: (_) {
                      _animationController.stop();
                      _baseScale = _transform.value.scale;
                    },
                    onScaleUpdate: (details) {
                      final current = _transform.value;
                      // Two fingers zoom; one finger pans a zoomed image.
                      if (_activePointers.length == 2) {
                        final scale = (_baseScale * details.scale).clamp(0.5, 4.0);
                        _transform.value = (scale: scale, offset: _clampOffset(current.offset, scale, viewportSize));
                      } else if (_activePointers.length == 1 && current.scale > 1.0) {
                        _transform.value = (
                          scale: current.scale,
                          offset: _clampOffset(current.offset + details.focalPointDelta, current.scale, viewportSize),
                        );
                      }
                    },
                    onScaleEnd: (_) {
                      if (_transform.value.scale < 1.0) {
                        _animateToTransform(scale: 1.0, offset: Offset.zero, curve: Curves.easeOutBack);
                      }
                    },
                    child: ClipRect(
                      child: Center(
                        child: Transform.translate(
                          offset: transform.offset,
                          child: Transform.scale(
                            scale: transform.scale,
                            alignment: Alignment.center,
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.contain,
                              width: viewportSize.width,
                              height: viewportSize.height,
                              placeholder: (context, url) =>
                                  const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54)),
                              errorWidget: (context, url, error) =>
                                  const Center(child: Icon(Icons.error, color: Colors.white54, size: 32)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
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
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFFFFFFF), size: 20.0),
          ),
        ),
      ),
    );
  }
}
