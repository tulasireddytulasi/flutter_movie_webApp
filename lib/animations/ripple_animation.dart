import 'package:flutter/material.dart';
import 'package:moviewebapp/animations/circle_painter.dart';
import 'package:moviewebapp/animations/curve_wave.dart';
import 'package:moviewebapp/utils/colors.dart';

class RipplesAnimation extends StatefulWidget {
  const RipplesAnimation({
    Key? key,
    this.size = 80.0,

    //  this.onPressed,
    //  required this.child,
  }) : super(key: key);
  final double size;

  // final Widget child;
  // final VoidCallback? onPressed;
  @override
  _RipplesAnimationState createState() => _RipplesAnimationState();
}

class _RipplesAnimationState extends State<RipplesAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                pickledBlueWood,
                Color.lerp(pickledBlueWood, Colors.black, .05) ?? pickledBlueWood,
              ],
            ),
          ),
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const CurveWave(),
              ),
            ),
            child: const Text(
              "Loading...",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: CirclePainter(
          _controller,
          color: pickledBlueWood,
        ),
        child: SizedBox(
          width: widget.size * 4.125,
          height: widget.size * 4.125,
          child: _button(),
        ),
      ),
    );
  }
}
