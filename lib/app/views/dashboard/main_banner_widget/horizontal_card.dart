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
    final theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool screenWidth600 = screenWidth >= 600;
    final bool screenWidth1000 = screenWidth <= 1000;
    final String posterSize = screenWidth600 ? ApiConstants.movieImageBaseUrlw1280 : ApiConstants.movieImageBaseUrlw500;

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
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: screenWidth1000 ? 16 / 9 : 21 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            posterUrl.isEmpty
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                : ClipRRect(
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
            // Content
            Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Title Logo Image
                  logo.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: logoUrl,
                          height: 80,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const SizedBox(height: 80),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.broken_image, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                        )
                      : const SizedBox.shrink(),
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons Row
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigation().youTubeScreen(context: context, youTubeVideoKey: youTubeVideoKey),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.scaffoldBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 26),
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
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.85),
                          foregroundColor: theme.colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
