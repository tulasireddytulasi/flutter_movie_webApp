import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviewebapp/app/core/routing/detail_navigation.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/movie_title_logo.dart';
import 'package:provider/provider.dart';

class MovieBannerWidget extends StatefulWidget {
  final String movieBannerImage;
  final bool showBanner;
  final String movieId;
  final String? movieLogoPath;

  const MovieBannerWidget({
    super.key,
    required this.movieBannerImage,
    required this.showBanner,
    this.movieId = '',
    this.movieLogoPath,
  });

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
                ).createShader(Rect.fromLTRB(0, 1, rect.width, rect.height));
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
                          ApiConstants.movieImageBaseUrlw1280 +
                              widget.movieBannerImage,
                          width:
                              getBottomSheetWidth(screenWidth: screenWidth) +
                              30,
                          fit: BoxFit.cover,
                          key: ValueKey(widget.movieBannerImage),
                        )
                      : Image.asset(
                          movieBackDrop2,
                          width:
                              getBottomSheetWidth(screenWidth: screenWidth) +
                              30,
                          fit: BoxFit.cover,
                          key: const ValueKey('fallback-banner'),
                        ),
                ),
              ),
            ),
          ),
          if (widget.movieId.isNotEmpty)
            Positioned(
              bottom: 24,
              left: screenWidth > 600 ? 40 : 0,
              right: screenWidth > 600 ? 40 : 0,
              child: Align(
                alignment: screenWidth > 600
                    ? Alignment.bottomLeft
                    : Alignment.bottomCenter,
                child: MovieTitleLogo(
                  key: ValueKey(widget.movieId),
                  movieId: widget.movieId,
                  logoPath: widget.movieLogoPath,
                ),
              ),
            ),
          Positioned(
            top: isVisible ? 0 : 30,
            right: 0,
            child: InkWell(
              onTap: () {
                handleDetailClose(context, fallbackRoute: '/');
              },
              child: context.canPop()
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      padding: const EdgeInsets.all(2),
                      margin: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.clear,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: isVisible ? 0 : 30,
            left: 0,
            child: InkWell(
              onTap: () {
               // handleDetailClose(context, fallbackRoute: '/');

                final movieInfoProvider = Provider.of<MovieInfoProvider>(context, listen: false);
                if (movieInfoProvider.previousMoviesIds.isNotEmpty) {
                  String movieId = movieInfoProvider.previousMoviesIds.elementAt(0);
                  movieInfoProvider.getMoviesInfoAPI(movieId: movieId, appendToResponse: "credits");
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

  const ImageViewWidget({Key? key, required this.url, required this.width})
    : super(key: key);

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
