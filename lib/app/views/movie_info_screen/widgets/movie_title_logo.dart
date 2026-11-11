import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';

class MovieTitleLogo extends StatefulWidget {
  const MovieTitleLogo({Key? key, required this.movieId}) : super(key: key);

  final String movieId;

  @override
  State<MovieTitleLogo> createState() => _MovieTitleLogoState();
}

class _MovieTitleLogoState extends State<MovieTitleLogo> {
  late Future<String?> _logo;

  @override
  void initState() {
    super.initState();
    _logo = _load();
  }

  @override
  void didUpdateWidget(covariant MovieTitleLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movieId != widget.movieId) _logo = _load();
  }

  Future<String?> _load() async {
    final id = widget.movieId;
    try {
      final images = await getMovieLogosAPI(movieId: id);
      final logos = images.logos ?? [];
      final valid = logos.where((logo) => logo.filePath?.startsWith('/') == true);
      final english = valid.where((logo) => logo.iso6391 == 'en');
      final neutral = valid.where((logo) => logo.iso6391 == null);
      if (english.isNotEmpty) return english.first.filePath;
      if (neutral.isNotEmpty) return neutral.first.filePath;
      return null;
    } on Exception catch (error, stack) {
      log('Could not load movie title logo for $id', error: error, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
        key: ValueKey(widget.movieId),
        future: _logo,
        builder: (context, snapshot) {
          final path = snapshot.data;
          if (snapshot.hasError || path == null) return const SizedBox.shrink();
          return Image.network(
            ApiConstants.movieImageBaseUrlw500 + path,
            width: 220,
            height: 100,
            fit: BoxFit.contain,
            alignment: Alignment.bottomLeft,
            excludeFromSemantics: true,
            errorBuilder: (_, error, stack) {
              log('Could not display movie title logo', error: error, stackTrace: stack);
              return const SizedBox.shrink();
            },
            frameBuilder: (context, child, frame, synchronous) {
              if (frame == null) return const SizedBox.shrink();
              if (MediaQuery.of(context).disableAnimations) return child;
              return TweenAnimationBuilder<double>(
                key: ValueKey('${widget.movieId}:$path'),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                child: child,
                builder: (_, value, image) => Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 1.15 - .15 * value,
                    alignment: Alignment.bottomLeft,
                    child: image,
                  ),
                ),
              );
            },
          );
        },
      );
}
