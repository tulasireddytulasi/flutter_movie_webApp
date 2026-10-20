import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Mobile View: Vertical Card UI
class VerticalMovieCard extends StatelessWidget {
  const VerticalMovieCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Vertical Card Image URL
    const imageUrl = 'https://image.tmdb.org/t/p/w1280//r2J02Z2OpNTctfOSN1Ydgii51I3.jpg';
    const titleImageUrl = 'https://image.tmdb.org/t/p/w500/kDdRAxIYPWwmhDqU8PgDPcwFEOt.png';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 3 / 4,
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
            // Gradient Overlay for readability
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.4, 0.65, 1.0],
                ),
              ),
            ),
            // Card Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  // Genres
                  const Text(
                    'Film · Indian · Fan Favorite · Action & Adventure',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  // Play Movie Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 28),
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
                  ),
                  const SizedBox(height: 10),
                  // My List Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C).withValues(alpha: 0.85),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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