import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/movie_info_screen/movie_info.dart';
import 'package:moviewebapp/providers/movie_info_provider.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/providers/navigation_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:provider/provider.dart';

class SimilarMovieCard extends StatelessWidget {
  const SimilarMovieCard({
    Key? key,
    required this.castImage,
    required this.actorName,
    required this.movieId,
    this.scrollController,
    required this.canNavigateToNewPage,
  }) : super(key: key);

  final String castImage;
  final String actorName;
  final String movieId;
  final bool canNavigateToNewPage;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (canNavigateToNewPage) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MovieInfoScreen(movieId: movieId)),
              );
            } else {
              final movieInfoProvider =
                  Provider.of<MovieInfoProvider>(context, listen: false);
              final movieProvider =
                  Provider.of<MoviesProvider>(context, listen: false);
              final navigationProvider =
                  Provider.of<NavigationProvider>(context, listen: false);

              if (navigationProvider.currentScreenIndex == 1) {
                navigationProvider.setMovieInfoScreen(movieId: movieId);
                navigationProvider.setCurrentScreenIndex(currentScreenIndex: 0);
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                movieInfoProvider.addPreviousMoviesIds(
                    movieId: movieInfoProvider.currentMovieId);
                movieInfoProvider.getMoviesInfoAPI(
                    movieId: movieId, appendToResponse: "credits");
                movieProvider.getSimilarMoviesAPI(movieId: movieId);
                movieInfoProvider.getMovieReviewsInfoAPI(
                    movieId: movieId, pageNo: "1");
              });
              if (scrollController != null) {
                scrollController!.animateTo(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.network(
                ApiConstants.movieImageBaseUrlw185 + castImage,
                width: getSimilarMoviesImageWidth(screenSize: _screenWidth),
                height: getSimilarMoviesImageHeight(screenSize: _screenWidth),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 15, top: 10),
          width: 100,
          child: Text(
            actorName,
            style: const TextStyle(fontSize: 12, color: GREY),
            maxLines: 2,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
