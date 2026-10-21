import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moviewebapp/app/core/utils/extensions.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:moviewebapp/app/models/movie_banner_model.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';

/// Tablet & Desktop View: Horizontal Card UI
class HorizontalMovieCard extends StatelessWidget {
  const HorizontalMovieCard({Key? key, this.movieInfo}) : super(key: key);
  final MoviesList? movieInfo;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool screenWidth600 = screenWidth >= 600;
    final String posterSize = screenWidth600 ? ApiConstants.movieImageBaseUrlw1280 : ApiConstants.movieImageBaseUrlw500;
    // Horizontal Card Image URL
    const imageUrl = 'https://image.tmdb.org/t/p/w1280//8CIgg0gCHIYz0jrx5IcZEOy047J.jpg';
    const titleImageUrl = 'https://image.tmdb.org/t/p/w500/kDdRAxIYPWwmhDqU8PgDPcwFEOt.png';

    final String id = movieInfo?.id ?? "";
    final List<String> genre = movieInfo?.genre ?? [];
    List<String>? genreList = genre.capitalizeFirstLetter();
    final String logo = movieInfo?.logo ?? "";
    final String logoUrl = ApiConstants.movieImageBaseUrlw500 + logo;
    final String youTubeVideoKey = movieInfo?.youTubeVideoKey ?? "";
    final String description = movieInfo?.description ?? "";
    final String posterUrl = screenWidth600 ? movieInfo?.backDrop ?? "" : movieInfo?.poster ?? "";
    final String posterImageUrl = posterSize + posterUrl;

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
              imageUrl: posterImageUrl,
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
                  logo.isNotEmpty ? CachedNetworkImage(
                    imageUrl: logoUrl,
                    height: 80,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(height: 80),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white54),
                  ) : const SizedBox.shrink(),
                  const SizedBox(height: 14),
                  RichText(
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    text: TextSpan(
                      children: List.generate(
                        genreList.length,
                        (index) => TextSpan(
                          text: genreList.length - 1 != index ? "${genreList[index]} . " : genreList[index],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          // style: const TextStyle(fontSize: 12, color: WHITE, fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                  // const Text(
                  //   'Film · Chilling · Scary · Supernatural Horror',
                  //   style: TextStyle(
                  //     color: Colors.white70,
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  // Action Buttons Row
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigation().youTubeScreen(context: context, youTubeVideoKey: youTubeVideoKey),
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
