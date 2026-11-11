import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/appwrite_movies_service.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/providers/dashboard_provider.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/movie_label.dart';
import 'package:moviewebapp/app/views/widgets/movies_card.dart';
import 'package:provider/provider.dart';

class AppwriteMoviesSections extends StatefulWidget {
  const AppwriteMoviesSections({super.key});

  @override
  State<AppwriteMoviesSections> createState() => _AppwriteMoviesSectionsState();
}

class _AppwriteMoviesSectionsState extends State<AppwriteMoviesSections> {
  late final List<_MoviesSectionData> _sections;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DashBoardProvider>();
    _sections = [
      _MoviesSectionData(
        title: 'MCU Movies',
        movies: provider.getMoviesByFranchise(AppwriteMoviesService.mcuFranchiseId),
      ),
      _MoviesSectionData(
        title: 'The Conjuring Universe',
        movies: provider.getMoviesByFranchise(
          AppwriteMoviesService.conjuringFranchiseId,
          latestFirst: true,
        ),
      ),
      _MoviesSectionData(
        title: 'Latest Horror Movies',
        movies: provider.getMoviesByGenre(
          AppwriteMoviesService.horrorGenreId,
          latestFirst: true,
        ),
      ),
      _MoviesSectionData(
        title: 'Latest Monster Movies',
        movies: provider.getMoviesByTheme(
          AppwriteMoviesService.monsterTheme,
          latestFirst: true,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final section in _sections)
            _AppwriteMoviesSection(data: section),
        ],
      );
}

class _MoviesSectionData {
  const _MoviesSectionData({required this.title, required this.movies});

  final String title;
  final Future<List<Movies>> movies;
}

class _AppwriteMoviesSection extends StatelessWidget {
  const _AppwriteMoviesSection({required this.data});

  final _MoviesSectionData data;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MovieLabel(movieLabel: data.title),
          SizedBox(
            height: MoviesCard.widthFor(screenWidth) * 1.5 + 12,
            child: FutureBuilder<List<Movies>>(
              future: data.movies,
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
                  return Center(child: Text('Unable to load ${data.title}.'));
                }

                final movies = snapshot.data ?? const <Movies>[];
                if (movies.isEmpty) {
                  return Center(child: Text('No ${data.title.toLowerCase()} found.'));
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