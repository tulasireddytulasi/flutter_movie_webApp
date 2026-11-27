import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/platform_utils.dart';
import 'package:moviewebapp/app/providers/universal_provider.dart';
import 'package:moviewebapp/app/views/image_preview_screen/widget/carousel_arrow_button.dart';
import 'package:moviewebapp/app/views/image_preview_screen/widget/custom_app_bar.dart';
import 'package:provider/provider.dart';

typedef _ImageTransform = ({double scale, Offset offset});

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({
    super.key,
    required this.actorsImages,
    required this.actorNames,
    required this.currentIndex,
  });

  final List<String> actorsImages;
  final List<String> actorNames;
  final int currentIndex;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> with SingleTickerProviderStateMixin {
  late final UniversalProvider universalProvider;
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final ValueNotifier<int> _currentIndex;

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
    universalProvider = Provider.of<UniversalProvider>(context, listen: false);
    _pageController = PageController(initialPage: widget.currentIndex);
    _currentIndex = ValueNotifier<int>(widget.currentIndex);
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
    _currentIndex.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Arrow buttons step one image at a time; zoom is cleared first so the
  // carousel is never locked by the zoomed-image scroll physics.
  void _showAdjacentImage(int delta) {
    final target = _currentIndex.value + delta;
    if (target < 0 || target >= widget.actorsImages.length) return;
    _resetTransform();
    _pageController.animateToPage(target, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  // Start each newly selected image at its original scale and position.
  void _resetTransform() {
    _animationController.stop();
    _baseScale = 1.0;
    _transform.value = (scale: 1.0, offset: Offset.zero);
  }

  // Keep a zoomed image inside the same viewport bounds used by the gallery.
  Offset _clampOffset(Offset offset, double scale, Size viewportSize) {
    if (scale <= 1.0) return Offset.zero;
    final maxDx = viewportSize.width * (scale - 1) / 2;
    final maxDy = viewportSize.height * (scale - 1) / 2;
    return Offset(offset.dx.clamp(-maxDx, maxDx), offset.dy.clamp(-maxDy, maxDy));
  }

  // Animate double-tap zoom and the spring-back after zooming below 1x.
  void _animateToTransform({required double scale, required Offset offset, Curve curve = Curves.easeOutCubic}) {
    final animation = _animationController.drive(CurveTween(curve: curve));
    _scaleAnimation = Tween<double>(begin: _transform.value.scale, end: scale).animate(animation);
    _offsetAnimation = Tween<Offset>(begin: _transform.value.offset, end: offset).animate(animation);
    _animationController.forward(from: 0);
  }

  // Zoom toward the tapped point, or return an already zoomed image to 1x.
  void _handleDoubleTap(Size viewportSize) {
    if (_activePointers.length > 1) return;
    final scale = _transform.value.scale > 1.0 ? 1.0 : 2.5;
    final center = Offset(viewportSize.width / 2, viewportSize.height / 2);
    final offset = -(_doubleTapPosition - center) * (scale - 1);
    _animateToTransform(scale: scale, offset: _clampOffset(offset, scale, viewportSize));
  }

  // Track fingers so pinching cannot also swipe to another image.
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
      appBar: customAppBar(
        context: context,
        voidCallback: () async {
          if (widget.actorsImages.isEmpty || widget.actorNames.isEmpty) return;
          final String nameVal = widget.actorNames.length == 1
              ? widget.actorNames.first
              : widget.actorNames[_currentIndex.value];
          final String name = "Actor Name: $nameVal";
          await universalProvider.shareImage(
            baseUrl: ApiConstants.movieImageBaseUrlw500,
            imgUrl: widget.actorsImages[_currentIndex.value],
            descText: name,
          );
        },
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Listener(
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
                          physics: allowPageSwipe ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
                          itemCount: widget.actorsImages.length,
                          onPageChanged: (value) {
                            _currentIndex.value = value;
                            _resetTransform();
                          },
                          itemBuilder: (context, index) => GestureDetector(
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
                                _transform.value = (
                                  scale: scale,
                                  offset: _clampOffset(current.offset, scale, viewportSize),
                                );
                              } else if (_activePointers.length == 1 && current.scale > 1.0) {
                                _transform.value = (
                                  scale: current.scale,
                                  offset: _clampOffset(
                                    current.offset + details.focalPointDelta,
                                    current.scale,
                                    viewportSize,
                                  ),
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
                                    child: Image.network(
                                      ApiConstants.movieImageBaseUrlw780 + widget.actorsImages[index],
                                      fit: BoxFit.contain,
                                      width: viewportSize.width,
                                      height: viewportSize.height,
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
            ),
          ),
          if (showDesktopWebControls) _buildNavigationArrows(),
        ],
      ),
    );
  }

  Widget _buildNavigationArrows() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndex,
      builder: (context, index, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (index > 0)
              CarouselArrowButton(
                icon: Icons.chevron_left,
                tooltip: 'Previous image',
                onPressed: () => _showAdjacentImage(-1),
              )
            else
              const SizedBox.shrink(),
            if (index < widget.actorsImages.length - 1)
              CarouselArrowButton(
                icon: Icons.chevron_right,
                tooltip: 'Next image',
                onPressed: () => _showAdjacentImage(1),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
