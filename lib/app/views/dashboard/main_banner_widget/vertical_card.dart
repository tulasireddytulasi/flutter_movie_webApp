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
    final theme = Theme.of(context);
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
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: posterImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error, color: theme.colorScheme.error),
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
                    imageUrl: logoUrl,
                    height: 80,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(height: 80),
                    errorWidget: (context, url, error) => Icon(Icons.broken_image, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'Play Movie',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.scaffoldBackgroundColor,
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
                        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.85),
                        foregroundColor: theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'My List',
                            style: theme.textTheme.labelLarge,
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
