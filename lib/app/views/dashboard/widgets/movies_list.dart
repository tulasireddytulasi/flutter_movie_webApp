import 'package:flutter/material.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/views/widgets/movies_card.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';

class MoviesList extends StatefulWidget {
  const MoviesList({
    Key? key,
    required this.moviesModel,
  }) : super(key: key);

  final MoviesModel moviesModel;

  @override
  _MoviesListState createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesList> {
  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return ListView.builder(
      itemCount: widget.moviesModel.results?.length,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return MoviesCard(
          movieName: widget.moviesModel.results?[index].title ?? "",
          poster: widget.moviesModel.results?[index].posterPath ?? "",
          movieId: widget.moviesModel.results?[index].id.toString() ?? "",
          voidCallback: () => Navigation().navigateToMoviesInfoPage(
            context: context,
            movieId: widget.moviesModel.results?[index].id.toString() ?? "",
            screenWidth: _screenWidth,
          ),
        );
      },
    );
  }
}
