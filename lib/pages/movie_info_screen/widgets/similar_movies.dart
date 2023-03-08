import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/widgets/similar_movie_card_widget.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:provider/provider.dart';

class SimilarMovies extends StatefulWidget {
  const SimilarMovies(
      {Key? key, this.scrollController, this.canNavigateToNewPage = false})
      : super(key: key);
  final ScrollController? scrollController;
  final bool canNavigateToNewPage;

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
                  canNavigateToNewPage: widget.canNavigateToNewPage,
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
