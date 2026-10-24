import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moviewebapp/app/models/movie_banner_model.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';

/// Mobile View: Vertical Card UI
class VerticalMovieCard extends StatelessWidget {
  const VerticalMovieCard({Key? key, this.movieInfo}) : super(key: key);
  final MoviesList? movieInfo;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool screenWidth600 = screenWidth >= 600;
    final String posterSize = screenWidth600 ? ApiConstants.movieImageBaseUrlw1280 : ApiConstants.movieImageBaseUrlw500;
    final String id = movieInfo?.id ?? "";
    final List<String> genre = movieInfo?.genre ?? [];
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
        aspectRatio: 3 / 4,
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
            // Gradient Overlay for readability
            // DecoratedBox(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //       colors: [
            //         Colors.transparent,
            //         Colors.black.withValues(alpha: 0.2),
            //         Colors.black.withValues(alpha: 0.85),
            //       ],
            //       stops: const [0.4, 0.65, 1.0],
            //     ),
            //   ),
            // ),
            // Card Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Movie Title Logo Image
                  CachedNetworkImage(
                    imageUrl: logoUrl,
                    height: 80,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(height: 80),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white54),
                  ),
                  const SizedBox(height: 14),
                  // Genres
                  RichText(
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    text: TextSpan(
                      children: List.generate(
                        genre.length,
                            (index) => TextSpan(
                          text: genre.length - 1 != index ? "${genre[index]} . " : genre[index],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Play Movie Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigation().youTubeScreen(context: context, youTubeVideoKey: youTubeVideoKey),
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