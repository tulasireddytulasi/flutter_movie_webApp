import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';

class MovieTitleLogo extends StatelessWidget {
  const MovieTitleLogo({super.key, required this.movieId, required this.logoPath});

  final String movieId;
  final String? logoPath;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktopOrTablet = screenWidth >= 600;
    final path = logoPath;
    if (path == null || path.isEmpty) return const SizedBox.shrink();
    if (!path.startsWith('/')) {
      log('Invalid movie title logo path for $movieId: $path');
      return const SizedBox.shrink();
    }
    return Image.network(
      ApiConstants.movieImageBaseUrlw500 + path,
      width: 220,
      height: isDesktopOrTablet ? 100 : 50,
      fit: BoxFit.contain,
      alignment: isDesktopOrTablet ? Alignment.bottomLeft : Alignment.bottomCenter,
      excludeFromSemantics: true,
      errorBuilder: (_, error, stack) {
        log('Could not display movie title logo', error: error, stackTrace: stack);
        return const SizedBox.shrink();
      },
      frameBuilder: (context, child, frame, synchronous) {
        if (frame == null) return const SizedBox.shrink();
        if (MediaQuery.of(context).disableAnimations) return child;
        return TweenAnimationBuilder<double>(
          key: ValueKey('$movieId:$path'),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          child: child,
          builder: (_, value, image) => Opacity(
            opacity: value,
            child: Transform.scale(scale: 1.15 - .15 * value, alignment: Alignment.bottomLeft, child: image),
          ),
        );
      },
    );
  }
}
