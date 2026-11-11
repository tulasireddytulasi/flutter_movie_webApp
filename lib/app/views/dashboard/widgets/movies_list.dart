import 'package:flutter/material.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/providers/dashboard_provider.dart';
import 'package:moviewebapp/app/views/widgets/movies_card.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
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
  State<MoviesList> createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesList> {
  late DashBoardProvider dashBoardProvider;
  late Future<MoviesModel> _movies;

  @override
  void initState() {
    super.initState();
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    _load();
  }

  void _load() {
    _movies = dashBoardProvider.getAllMovies(
      movieType: widget.movieType,
      withGenres: widget.withGenres,
      withOriginalLanguage: widget.withOriginalLanguage,
    );
  }

  @override
  void didUpdateWidget(covariant MoviesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movieType != widget.movieType ||
        oldWidget.withGenres != widget.withGenres ||
        oldWidget.withOriginalLanguage != widget.withOriginalLanguage) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<MoviesModel>(
      future: _movies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, __) => SizedBox(
              width: MoviesCard.widthFor(screenWidth),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No movies found.'));
        } else {
          final movies = snapshot.data!.results ?? <Movies>[];
          if (movies.isEmpty) return const Center(child: Text('No movies found.'));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
            itemCount: movies.length,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final movie = movies[index];
              return MoviesCard(
                key: ValueKey(movie.id ?? index),
                movieName: movie.title ?? "",
                poster: movie.posterPath ?? "",
                movieId: movie.id?.toString() ?? "",
                voidCallback: () => Navigation().navigateToMoviesInfoPage(
                  context: context,
                  movieId: movie.id?.toString() ?? "",
                  screenWidth: screenWidth,
                ),
              );
            },
          );
        }
      },
    );
  }
}
