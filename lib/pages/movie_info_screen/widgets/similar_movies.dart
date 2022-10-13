import 'package:flutter/material.dart';
import 'package:moviewebapp/providers/movie_info_provider.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:provider/provider.dart';

class SimilarMovies extends StatefulWidget {
  SimilarMovies({Key? key, required this.scrollController}) : super(key: key);
  ScrollController scrollController;

  @override
  _SimilarMoviesState createState() => _SimilarMoviesState();
}

class _SimilarMoviesState extends State<SimilarMovies> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoviesProvider>(builder: (context, movieProvider, child) {
      return movieProvider.similarMoviePosters.isNotEmpty
          ? ListView.builder(
              itemCount: movieProvider.similarMoviePosters.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return SimilarMovieCard(
                  actorName: movieProvider.similarMovieTitle[index].toString(),
                  castImage:
                      movieProvider.similarMoviePosters[index].toString(),
                  movieId: movieProvider.similarMovieId[index].toString(),
                  scrollController: widget.scrollController,
                );
              })
          : Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                "No Similar Movies",
                style: TextStyle(fontSize: 18, color: GREY),
              ),
            );
    });
  }
}

class SimilarMovieCard extends StatelessWidget {
  SimilarMovieCard({
    Key? key,
    required this.castImage,
    required this.actorName,
    required this.movieId,
    required this.scrollController,
  }) : super(key: key);

  final String castImage;
  final String actorName;
  final String movieId;
  ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        InkWell(
          onTap: () {
            final movieInfoProvider =
                Provider.of<MovieInfoProvider>(context, listen: false);
            final movieProvider =
                Provider.of<MoviesProvider>(context, listen: false);

            WidgetsBinding.instance!.addPostFrameCallback((_) {
              movieInfoProvider.addPreviousMoviesIds(
                  movieId: movieInfoProvider.currentMovieId);
              movieInfoProvider.getMoviesInfoAPI(
                  movieId: movieId, appendToResponse: "credits");
              movieProvider.getSimilarMoviesAPI(movieId: movieId);
            });
            scrollController.animateTo(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
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
