import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/cast.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/expandable_text_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/movie_banner_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/rating_row_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/reviews_list_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/similar_movies.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/trailer_button.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:provider/provider.dart';

class MovieInfoScreen extends StatefulWidget {
  final String movieId;
  final bool fullPage;

  const MovieInfoScreen({super.key, required this.movieId, this.fullPage = false});

  @override
  State<MovieInfoScreen> createState() => _MovieInfoScreenState();
}

class _MovieInfoScreenState extends State<MovieInfoScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final movieInfoProvider = Provider.of<MovieInfoProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await movieInfoProvider.getMoviesInfoAPI(movieId: widget.movieId, appendToResponse: "credits");
      await movieInfoProvider.getMovieVideos(movieId: widget.movieId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<MovieInfoProvider>(
      builder: (context, movieInfoProvider, child) {
        return Scaffold(
          backgroundColor: widget.fullPage
              ? Colors.transparent
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0),
          extendBodyBehindAppBar: widget.fullPage,
          body: SafeArea(
            child: Stack(
              children: [
                if (widget.fullPage && movieInfoProvider.backdropPath.isNotEmpty)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.28,
                      child: Image.network(
                        ApiConstants.movieImageBaseUrlw1280 + movieInfoProvider.backdropPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
                      ),
                    ),
                  ),
                if (widget.fullPage) const Positioned.fill(child: ColoredBox(color: Color(0x99000000))),
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Center(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        width: getBottomSheetWidth(screenWidth: screenWidth) + 30,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          ),
                          shape: BoxShape.rectangle,
                        ),
                        margin: EdgeInsets.only(top: screenWidth >= 525 ? 50 : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MovieBannerWidget(
                              movieId: movieInfoProvider.currentMovieId,
                              movieBannerImage: movieInfoProvider.backdropPath,
                              movieLogoPath: movieInfoProvider.logoPath,
                              showBanner: true,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: screenWidth <= 525 ? 0 : 40,
                                right: screenWidth <= 525 ? 0 : 50,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const RatingWidget(),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(left: 15, top: 5),
                                    child: SelectableText(
                                      movieInfoProvider.movieTitle,
                                      showCursor: true,
                                      cursorColor: Theme.of(context).colorScheme.primary,
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(left: 15, top: 5),
                                    child: SelectableText(
                                      "${movieInfoProvider.runtime} . ${movieInfoProvider.genre} . ${movieInfoProvider.releaseYear}",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      showCursor: true,
                                      cursorColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(left: 15, top: 20),
                                    child: ExpandableText(
                                      text: movieInfoProvider.overview,
                                      maxLines: 3,
                                      textStyle: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(left: 15, top: 20),
                                    child: Text("Top Cast", style: Theme.of(context).textTheme.titleLarge),
                                  ),
                                  Container(
                                    height: getActorSectionHeight(screenSize: screenWidth),
                                    margin: const EdgeInsets.only(top: 20),
                                    child: const Cast(),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(left: 15, top: 20),
                                    child: Text("Similar Movies", style: Theme.of(context).textTheme.titleLarge),
                                  ),
                                  Container(
                                    height: getSimilarMoviesSectionHeight(screenSize: screenWidth),
                                    margin: const EdgeInsets.only(top: 20),
                                    child: SimilarMovies(
                                      movieId: movieInfoProvider.currentMovieId,
                                      franchiseId: movieInfoProvider.franchiseId,
                                      theme: movieInfoProvider.theme,
                                      genreIds: movieInfoProvider.genreIds,
                                      scrollController: _scrollController,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // InkWell(
                                      //   onTap: () {
                                      //     if (movieInfoProvider
                                      //         .youTubeKey
                                      //         .isNotEmpty) {
                                      //       Navigation().youTubeScreen(
                                      //         context: context,
                                      //         youTubeVideoKey:
                                      //             movieInfoProvider.youTubeKey,
                                      //       );
                                      //     } else {
                                      //       showAlert(context: context);
                                      //     }
                                      //   },
                                      //   child: Container(
                                      //     margin: const EdgeInsets.only(
                                      //       top: 20,
                                      //       bottom: 20,
                                      //       left: 10,
                                      //     ),
                                      //     alignment: Alignment.center,
                                      //     decoration: BoxDecoration(
                                      //       shape: BoxShape.rectangle,
                                      //       borderRadius: BorderRadius.circular(
                                      //         5,
                                      //       ),
                                      //       color: Theme.of(context)
                                      //           .colorScheme
                                      //           .surfaceContainerHighest,
                                      //     ),
                                      //     height: 50,
                                      //     width: 130,
                                      //     child: Text(
                                      //       "TRAILER",
                                      //       style: Theme.of(context)
                                      //           .textTheme
                                      //           .labelLarge
                                      //           ?.copyWith(fontSize: 20),
                                      //     ),
                                      //   ),
                                      // ),
                                      InkWell(
                                        onTap: () {
                                          if (movieInfoProvider.youTubeKey.isNotEmpty) {
                                            Navigation().youTubeScreen(
                                              context: context,
                                              youTubeVideoKey: movieInfoProvider.youTubeKey,
                                            );
                                          } else {
                                            showAlert(context: context);
                                          }
                                        },
                                        child: const TrailerButtons(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(left: 15, top: 20),
                                    child: Text("Movie reviews", style: Theme.of(context).textTheme.titleLarge),
                                  ),
                                  SizedBox(height: 234, child: ReviewsList(movieId: widget.movieId)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void showAlert({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (context) => Center(
      child: AlertDialog(
        content: Text("Video unavailable for this movie", style: Theme.of(context).textTheme.bodyLarge),
      ),
    ),
  );
}
