import 'package:flutter/material.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/providers/dashboard_provider.dart';
import 'package:moviewebapp/app/views/widgets/movies_card.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:moviewebapp/app/views/widgets/shimmer_widget.dart';
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
  late DashBoardProvider dashBoardProvider;

  @override
  void initState() {
    super.initState();
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: dashBoardProvider.getAllMovies(
        movieType: widget.movieType,
        withGenres: widget.withGenres,
        withOriginalLanguage: widget.withOriginalLanguage,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerWidget(); // Loading indicator
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No movies found.'));
        } else {
          MoviesModel _movieModel = (snapshot.data!) as MoviesModel;
          return ListView.builder(
            itemCount: _movieModel.results?.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return MoviesCard(
                movieName: _movieModel.results?[index].title ?? "",
                poster: _movieModel.results?[index].posterPath ?? "",
                movieId: _movieModel.results?[index].id.toString() ?? "",
                voidCallback: () => Navigation().navigateToMoviesInfoPage(
                  context: context,
                  movieId: _movieModel.results?[index].id.toString() ?? "",
                  screenWidth: _screenWidth,
                ),
              );
            },
          );
        }
      },
    );
  }
}
