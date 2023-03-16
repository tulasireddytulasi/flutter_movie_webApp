import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/cast.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/movie_banner_widget.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/rating_row_widget.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/reviews_list_widget.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/similar_movies.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/trailer_button.dart';
import 'package:moviewebapp/providers/movie_info_provider.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:provider/provider.dart';

class MovieInfoScreen extends StatefulWidget {
  final String movieId;
  const MovieInfoScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  _MovieInfoScreenState createState() => _MovieInfoScreenState();
}

class _MovieInfoScreenState extends State<MovieInfoScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final movieInfoProvider =
        Provider.of<MovieInfoProvider>(context, listen: false);
    final movieProvider = Provider.of<MoviesProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      movieInfoProvider.getMoviesInfoAPI(
          movieId: widget.movieId, appendToResponse: "credits");
      movieProvider.getSimilarMoviesAPI(movieId: widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Consumer<MovieInfoProvider>(
        builder: (context, movieInfoProvider, child) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          controller: scrollController,
          child: Center(
            child: Container(
              alignment: Alignment.bottomCenter,
              width: getBottomSheetWidth(screenWidth: _screenWidth) + 30,
              decoration: const BoxDecoration(
                color: tealishBlue,
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
                        right: _screenWidth <= 525 ? 0 : 50),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const RatingWidget(),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 15, top: 5),
                          child: Text(
                            movieInfoProvider.movieTitle,
                            style: const TextStyle(fontSize: 26, color: WHITE),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 15, top: 5),
                          child: Text(
                            "${movieInfoProvider.runtime} . ${movieInfoProvider.genre} . ${movieInfoProvider.releaseYear}",
                            style:
                                const TextStyle(fontSize: 14, color: ICON_GREY),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 15, top: 20),
                          child: const Text(
                            "A noble family becomes embroiled in a war for control over the galaxy's most valuable asset while its heir becomes troubled by visions of a dark future.",
                            style: TextStyle(fontSize: 14, color: ICON_GREY),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 15, top: 20),
                          child: const Text(
                            "Top Cast",
                            style: TextStyle(fontSize: 22, color: GREY),
                          ),
                        ),
                        Container(
                          height:
                              getActorSectionHeight(screenSize: _screenWidth),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: DARK_JUNGLE_GREEN_1, width: 1),
                          ),
                          margin: const EdgeInsets.only(top: 20),
                          child: const Cast(),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 15, top: 20),
                          child: const Text(
                            "Similar Movies",
                            style: TextStyle(fontSize: 22, color: GREY),
                          ),
                        ),
                        Container(
                          height: getSimilarMoviesSectionHeight(
                              screenSize: _screenWidth),
                          margin: const EdgeInsets.only(top: 20),
                          child:
                              SimilarMovies(scrollController: scrollController),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 20, bottom: 20, left: 10),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: tuna),
                              height: 50,
                              width: 130,
                              child: const Text(
                                "TRAILER",
                                style: TextStyle(fontSize: 20, color: WHITE),
                              ),
                            ),
                            const TrailerButtons(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 15, top: 20),
                          child: const Text(
                            "Movie reviews",
                            style: TextStyle(fontSize: 22, color: GREY),
                          ),
                        ),
                        SizedBox(
                          height: 228,
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
