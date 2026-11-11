import 'package:flutter/material.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/views/all_movies_screen/widgets/movie_card.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';

class MovieHomePage extends StatefulWidget {
  const MovieHomePage({
    Key? key,
    required this.withOriginalLanguage,
    required this.movieType,
    this.withGenres,
    required this.screenTitle,
  }) : super(key: key);

  final String withOriginalLanguage;
  final String movieType;
  final String? withGenres;
  final String screenTitle;

  @override
  State<MovieHomePage> createState() => _MovieHomePageState();
}

class _MovieHomePageState extends State<MovieHomePage> {
  late Future<MoviesModel> _moviesData;

  void _load() {
    _moviesData = getPopularMoviesList(
      movieType: widget.movieType,
      pageNo: 1,
      withOriginalLanguage: widget.withOriginalLanguage,
      withGenres: widget.withGenres,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant MovieHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movieType != widget.movieType ||
        oldWidget.withOriginalLanguage != widget.withOriginalLanguage ||
        oldWidget.withGenres != widget.withGenres) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(widget.screenTitle),
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        body: SafeArea(
          child: FutureBuilder<MoviesModel>(
            future: _moviesData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Could not load movies: ${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: () => setState(_load), child: const Text('Retry')),
                      ],
                    ),
                  ),
                );
              }
              final movies = snapshot.data?.results ?? <Movies>[];
              if (movies.isEmpty) return const Center(child: Text('No movies found.'));
              return LayoutBuilder(
                builder: (context, constraints) => GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MovieCard.columnsFor(constraints.maxWidth),
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieCard(
                      key: ValueKey(movie.id ?? index),
                      movieName: movie.title ?? 'Untitled movie',
                      imageURL: movie.posterPath ?? '',
                      movieId: movie.id?.toString() ?? '',
                      onTap: () => Navigation().navigateToMoviesInfoPage(
                        context: context,
                        movieId: movie.id?.toString() ?? '',
                        screenWidth: MediaQuery.of(context).size.width,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
}
