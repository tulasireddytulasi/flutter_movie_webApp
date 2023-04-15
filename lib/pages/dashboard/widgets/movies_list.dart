import 'dart:math';

import 'package:flutter/material.dart';
import 'package:moviewebapp/models/get_movies_model.dart';
import 'package:moviewebapp/pages/widgets/custom_message.dart';
import 'package:moviewebapp/pages/widgets/movies_card.dart';
import 'package:moviewebapp/providers/dashboard_provider.dart';
import 'package:moviewebapp/responses/movie_apis.dart';
import 'package:moviewebapp/utils/navigation/navigation.dart';
import 'package:provider/provider.dart';

class MoviesList extends StatefulWidget {
  const MoviesList({
    Key? key,
    required this.withOriginalLanguage,
    required this.movieType,
    this.withGenres,
  }) : super(key: key);
  final String withOriginalLanguage;
  final String movieType;
  final String? withGenres;

  @override
  _MoviesListState createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesList> {
  MoviesModel _moviesModel = MoviesModel();

  final List<String> _title = [];
  final List<String> _movieId = [];
  final List<String> _img = [];

  clearData() {
    _title.clear();
    _movieId.clear();
    _img.clear();
  }

  processData({required MoviesModel moviesModel}) {
    final movieProvider =
        Provider.of<DashBoardProvider>(context, listen: false);
    _moviesModel = moviesModel;
    _moviesModel.results?.forEach((element) {
      _title.add(element.title ?? "");
      _img.add(element.posterPath ?? "");
      _movieId.add(element.id.toString());
    });
    if (widget.movieType == "popular") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Create an instance of the Random class
        final random = Random();

        // Generate a random number between 0 and 19
        int randomNumber = random.nextInt(20);
        movieProvider.setMovieData(
          movieTitle: _moviesModel.results?[randomNumber].title ?? "",
          movieID: _moviesModel.results?[randomNumber].id.toString() ?? "",
          moviePoster: _moviesModel.results?[randomNumber].posterPath ?? "",
          backdropPath: _moviesModel.results?[randomNumber].backdropPath ?? "",
        );
      });
    }
  }

  late Future<MoviesModel> _moviesData;

  @override
  void initState() {
    super.initState();
    _moviesData = getPopularMoviesList(
      movieType: widget.movieType,
      pageNo: 1,
      withOriginalLanguage: widget.withOriginalLanguage,
      withGenres: widget.withGenres,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: _moviesData,
      builder: (BuildContext context, AsyncSnapshot<MoviesModel> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const CustomMessage(text: "Error");
          } else if (snapshot.hasData) {
            clearData();
            processData(moviesModel: snapshot.data!);
            return ListView.builder(
                itemCount: _title.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigation().navigateToMoviesInfoPage(
                        context: context,
                        movieId: _movieId[index],
                        screenWidth: _screenWidth,
                      );
                    },
                    child: MoviesCard(
                      actorName: _title[index],
                      castImage: _img[index],
                      movieId: _movieId[index],
                    ),
                  );
                });
          } else {
            return const CustomMessage(text: "No Movies");
          }
        } else {
          return CustomMessage(text: "State: ${snapshot.connectionState}");
        }
      },
    );
  }
}
