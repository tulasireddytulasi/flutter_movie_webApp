import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/extensions.dart';

class _LikeState {
  final bool isLiked;
  final int likeCount;

  _LikeState({required this.isLiked, required this.likeCount});
}

class TwitterLikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final ValueChanged<bool>? onTap;
  final double iconSize;
  final double textSize;

  const TwitterLikeButton(
      {Key? key,
      required this.isLiked,
      required this.likeCount,
      this.onTap,
      required this.iconSize,
      required this.textSize})
      : super(key: key);

  @override
  State<TwitterLikeButton> createState() => _TwitterLikeButtonState();
}

class _TwitterLikeButtonState extends State<TwitterLikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _circleAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _opacityAnimation;

  late final ValueNotifier<_LikeState> _likeNotifier;
  static const double _size = 48.0;

  @override
  void initState() {
    super.initState();
    _likeNotifier = ValueNotifier<_LikeState>(
      _LikeState(isLiked: widget.isLiked, likeCount: widget.likeCount),
    );

    _controller = AnimationController(duration: const Duration(milliseconds: 650), vsync: this);

    // FIXED: Apply elastic curve per segment inside TweenSequence
    // instead of passing Curves.easeOutBack to the parent controller.
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.35).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller); // Pass controller directly

    // Outer Expanding Ring
    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.decelerate),
      ),
    );

    // Sparkle Particle Outward Distance
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    // Fade-out Opacity Window
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.88, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TwitterLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked || oldWidget.likeCount != widget.likeCount) {
      _likeNotifier.value = _LikeState(isLiked: widget.isLiked, likeCount: widget.likeCount);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _likeNotifier.dispose();
    super.dispose();
  }

  void _handleTap() {
    final currentState = _likeNotifier.value;
    final newIsLiked = !currentState.isLiked;
    final newLikeCount = currentState.likeCount + (newIsLiked ? 1 : -1);

    _likeNotifier.value = _LikeState(isLiked: newIsLiked, likeCount: newLikeCount);

    if (newIsLiked) {
      _controller.forward(from: 0.0);
    } else {
      _controller.reset();
    }

    if (widget.onTap != null) {
      widget.onTap!(newIsLiked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_LikeState>(
      valueListenable: _likeNotifier,
      builder: (context, state, child) {
        return GestureDetector(
          onTap: _handleTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 35.0),
                child: Text(
                  state.likeCount.toCompactCurrencyFormat(),
                  style: TextStyle(
                    fontSize: widget.textSize,
                    fontWeight: FontWeight.w500,
                    color: state.isLiked ? const Color(0xFFE0245E) : const Color(0xFF71767B),
                  ),
                ),
              ),
              SizedBox(
                width: _size,
                height: _size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sparkle & Ring Layer
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        if (!state.isLiked || _controller.value == 0) return const SizedBox();
                        return CustomPaint(
                          size: const Size(48, 48),
                          painter: _SparklesPainter(
                            particleProgress: _particleAnimation.value,
                            circleProgress: _circleAnimation.value,
                            opacity: _opacityAnimation.value,
                          ),
                        );
                      },
                    ),

                    // Heart Icon
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: state.isLiked ? _scaleAnimation.value : 1.0,
                          child: Icon(
                            state.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: widget.iconSize,
                            color: state.isLiked ? const Color(0xFFE0245E) : const Color(0xFF71767B),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SparklesPainter extends CustomPainter {
  final double particleProgress;
  final double circleProgress;
  final double opacity;

  _SparklesPainter({required this.particleProgress, required this.circleProgress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.0) return; // Completely invisible, skip render

    final center = Offset(size.width / 2, size.height / 2);
    final maxTravelDistance = size.width / 2; // 24px travel

    // 1. Expanding Ring
    if (circleProgress < 1.0) {
      final ringRadius = circleProgress * maxTravelDistance * 0.75;
      final ringOpacity = ((1.0 - circleProgress) * opacity).clamp(0.0, 1.0);

      final ringPaint = Paint()
        ..color = const Color(0xFFE0245E).withValues(alpha: ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - circleProgress) * 4.5;

      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // 2. Outward Flying Sparkles with Dual Shrink + Fade
    if (particleProgress > 0.0) {
      const int particleCount = 7;
      final double angleStep = (2 * math.pi) / particleCount;

      // Smooth outward trajectory
      final double distance = particleProgress * maxTravelDistance;

      // Accelerated shrinking: dots shrink to zero WELL BEFORE the animation ends
      final double shrinkFactor = (1.0 - particleProgress).clamp(0.0, 1.0);
      final double primaryRadius = math.pow(shrinkFactor, 1.5) * 3.8;
      final double secondaryRadius = primaryRadius * 0.6;

      if (primaryRadius <= 0.01) return; // Prevent zero-radius draws

      final primaryPaint = Paint()..color = const Color(0xFFE0245E).withValues(alpha: opacity);
      final secondaryPaint = Paint()..color = const Color(0xFFFFAD1F).withValues(alpha: opacity);

      for (int i = 0; i < particleCount; i++) {
        final double angle = (i * angleStep) - (math.pi / 2);

        // Main primary dot flight trajectory
        final double x = center.dx + (math.cos(angle) * distance);
        final double y = center.dy + (math.sin(angle) * distance);

        canvas.drawCircle(Offset(x, y), primaryRadius, i % 2 == 0 ? primaryPaint : secondaryPaint);

        // Secondary sub-dot flying at a slight offset angle
        final double subAngle = angle + 0.22;
        final double subDistance = distance * 0.85;
        final double subX = center.dx + (math.cos(subAngle) * subDistance);
        final double subY = center.dy + (math.sin(subAngle) * subDistance);

        canvas.drawCircle(Offset(subX, subY), secondaryRadius, i % 2 == 0 ? secondaryPaint : primaryPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) {
    return oldDelegate.particleProgress != particleProgress ||
        oldDelegate.circleProgress != circleProgress ||
        oldDelegate.opacity != opacity;
  }
}
