import 'package:flutter/material.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:provider/provider.dart';

class MovieBannerWidget extends StatefulWidget {
  final String movieBannerImage;
  final bool showBanner;

  const MovieBannerWidget({Key? key, required this.movieBannerImage, required this.showBanner}) : super(key: key);

  @override
  State<MovieBannerWidget> createState() => _MovieBannerWidgetState();
}

class _MovieBannerWidgetState extends State<MovieBannerWidget> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isVisible = screenWidth >= 525;
    if (widget.showBanner) {
      return Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(0),
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                  ],
                ).createShader(
                  Rect.fromLTRB(0, 1, rect.width, rect.height),
                );
              },
              blendMode: BlendMode.dstIn,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(isVisible ? 20 : 0),
                  topLeft: Radius.circular(isVisible ? 20 : 0),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1200),
                  child: widget.movieBannerImage.isNotEmpty
                      ? Image.network(
                          ApiConstants.movieImageBaseUrlw1280 + widget.movieBannerImage,
                          width: getBottomSheetWidth(screenWidth: screenWidth) + 30,
                          fit: BoxFit.cover,
                          key: ValueKey(widget.movieBannerImage),
                        )
                      : Image.asset(
                          movieBackDrop2,
                          width: getBottomSheetWidth(screenWidth: screenWidth) + 30,
                          fit: BoxFit.cover,
                          key: const ValueKey('fallback-banner'),
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            top: isVisible ? 0 : 30,
            right: 0,
            child: InkWell(
              onTap: () {
                final movieInfoProvider = Provider.of<MovieInfoProvider>(context, listen: false);
                movieInfoProvider.removePreviousAllMoviesIds();
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                padding: const EdgeInsets.all(2),
                margin: const EdgeInsets.all(10),
                child: Icon(
                  Icons.clear,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Positioned(
            top: isVisible ? 0 : 30,
            left: 0,
            child: InkWell(
              onTap: () {
                final movieInfoProvider = Provider.of<MovieInfoProvider>(context, listen: false);
                final movieProvider = Provider.of<MoviesProvider>(context, listen: false);
                if (movieInfoProvider.previousMoviesIds.isNotEmpty) {
                  String movieId = movieInfoProvider.previousMoviesIds.elementAt(0);
                  movieInfoProvider.getMoviesInfoAPI(movieId: movieId, appendToResponse: "credits");
                  movieProvider.getSimilarMoviesAPI(movieId: movieId);
                  movieInfoProvider.getMovieReviewsInfoAPI(movieId: movieId, pageNo: "1");
                  movieInfoProvider.getMovieVideos(movieId: movieId);
                  movieInfoProvider.removePreviousMoviesIds();
                } else {
                  final movieInfoProvider = Provider.of<MovieInfoProvider>(context, listen: false);
                  movieInfoProvider.removePreviousAllMoviesIds();
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                margin: const EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class ImageViewWidget extends StatelessWidget {
  final String url;
  final double width;

  const ImageViewWidget({Key? key, required this.url, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      placeholder: const AssetImage(moviePlaceHolder),
      image: NetworkImage(url),
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.asset(
          movieBackDrop,
          width: getBottomSheetWidth(screenWidth: width) + 30,
          fit: BoxFit.cover,
        );
      },
      fit: BoxFit.cover,
      width: width,
    );
  }
}
