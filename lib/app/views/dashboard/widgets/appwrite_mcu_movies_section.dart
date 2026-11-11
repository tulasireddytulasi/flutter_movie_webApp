import 'package:flutter/material.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/providers/dashboard_provider.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/movie_label.dart';
import 'package:moviewebapp/app/views/widgets/movies_card.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:provider/provider.dart';

class AppwriteMcuMoviesSection extends StatefulWidget {
  const AppwriteMcuMoviesSection({super.key});

  @override
  State<AppwriteMcuMoviesSection> createState() => _AppwriteMcuMoviesSectionState();
}

class _AppwriteMcuMoviesSectionState extends State<AppwriteMcuMoviesSection> {
  late final Future<List<Movies>> _movies;

  @override
  void initState() {
    super.initState();
    _movies = context.read<DashBoardProvider>().getMcuMovies();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MovieLabel(movieLabel: 'Marvel Cinematic Universe'),
          SizedBox(
            height: MoviesCard.widthFor(screenWidth) * 1.5 + 12,
            child: FutureBuilder<List<Movies>>(
              future: _movies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 8,
                    separatorBuilder: (_, __) => const SizedBox(width: 2),
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
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load MCU movies.'));
                }

                final movies = snapshot.data ?? const <Movies>[];
                if (movies.isEmpty) {
                  return const Center(child: Text('No MCU movies found.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
                  itemCount: movies.length,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => const SizedBox(width: 2),
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final movieId = movie.id?.toString() ?? '';
                    return MoviesCard(
                      key: ValueKey(movie.id ?? index),
                      movieName: movie.title ?? '',
                      poster: movie.posterPath ?? '',
                      movieId: movieId,
                      voidCallback: () => Navigation().navigateToMoviesInfoPage(
                        context: context,
                        movieId: movieId,
                        screenWidth: screenWidth,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}