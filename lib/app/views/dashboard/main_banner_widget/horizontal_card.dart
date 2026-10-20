import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Tablet & Desktop View: Horizontal Card UI
class HorizontalMovieCard extends StatelessWidget {
  const HorizontalMovieCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Horizontal Card Image URL
    const imageUrl = 'https://image.tmdb.org/t/p/w1280//8CIgg0gCHIYz0jrx5IcZEOy047J.jpg';
    const titleImageUrl = 'https://image.tmdb.org/t/p/w500/kDdRAxIYPWwmhDqU8PgDPcwFEOt.png';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image using cached_network_image ^4.0.4
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
            ),
            // Gradient Overlay
            // DecoratedBox(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.centerLeft,
            //       end: Alignment.centerRight,
            //       colors: [
            //         Colors.black.withValues(alpha: 0.9),
            //         Colors.black.withValues(alpha: 0.5),
            //         Colors.transparent,
            //       ],
            //       stops: const [0.0, 0.5, 1.0],
            //     ),
            //   ),
            // ),
            // Content
            Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Title Logo Image
                  CachedNetworkImage(
                    imageUrl: titleImageUrl,
                    height: 80,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(height: 80),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white54),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Film · Chilling · Scary · Supernatural Horror',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons Row
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 26),
                            SizedBox(width: 8),
                            Text(
                              'Play Movie',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C).withValues(alpha: 0.85),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'My List',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}