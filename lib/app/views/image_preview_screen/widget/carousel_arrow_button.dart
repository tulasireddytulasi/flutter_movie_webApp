import 'package:flutter/material.dart';

class CarouselArrowButton extends StatelessWidget {
  const CarouselArrowButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      iconSize: 28,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        fixedSize: const Size.square(48),
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        hoverColor: Colors.white24,
      ),
    );
  }
}
