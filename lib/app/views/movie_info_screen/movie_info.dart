import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/cast.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/expandable_text_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/movie_banner_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/rating_row_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/reviews_list_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/similar_movies.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/trailer_button.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:provider/provider.dart';

class MovieInfoScreen extends StatefulWidget {
  final String movieId;

  const MovieInfoScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieInfoScreen> createState() => _MovieInfoScreenState();
}

class _MovieInfoScreenState extends State<MovieInfoScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final movieInfoProvider = Provider.of<MovieInfoProvider>(context, listen: false);
    final movieProvider = Provider.of<MoviesProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await movieInfoProvider.getMoviesInfoAPI(movieId: widget.movieId, appendToResponse: "credits");
      await movieProvider.getSimilarMoviesAPI(movieId: widget.movieId);
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
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Consumer<MovieInfoProvider>(builder: (context, movieInfoProvider, child) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Container(
              alignment: Alignment.bottomCenter,
              width: getBottomSheetWidth(screenWidth: _screenWidth) + 30,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                shape: BoxShape.rectangle,
              ),
              margin: EdgeInsets.only(
                top: _screenWidth >= 525 ? 50 : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MovieBannerWidget(
                    movieBannerImage: movieInfoProvider.backdropPath,
                    showBanner: true,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: _screenWidth <= 525 ? 0 : 40,
                      right: _screenWidth <= 525 ? 0 : 50,
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
                          child: Text(
                            "Top Cast",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Container(
                          height: getActorSectionHeight(screenSize: _screenWidth),
                          margin: const EdgeInsets.only(top: 20),
                          child: const Cast(),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 15, top: 20),
                          child: Text(
                            "Similar Movies",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Container(
                          height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
                          margin: const EdgeInsets.only(top: 20),
                          child: SimilarMovies(scrollController: _scrollController),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                if (movieInfoProvider.youTubeKey.isNotEmpty) {
                                  Navigation()
                                      .youTubeScreen(context: context, youTubeVideoKey: movieInfoProvider.youTubeKey);
                                } else {
                                  showAlert(context: context);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 20, bottom: 20, left: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                height: 50,
                                width: 130,
                                child: Text(
                                  "TRAILER",
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (movieInfoProvider.youTubeKey.isNotEmpty) {
                                  Navigation()
                                      .youTubeScreen(context: context, youTubeVideoKey: movieInfoProvider.youTubeKey);
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
                          child: Text(
                            "Movie reviews",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        SizedBox(
                          height: 234,
                          child: ReviewsList(movieId: widget.movieId),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

void showAlert({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (context) => Center(
      child: AlertDialog(
        content: Text(
          "Video unavailable for this movie",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
}
