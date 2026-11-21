import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/widgets/similar_movie_card_widget.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:provider/provider.dart';

class SimilarMovies extends StatefulWidget {
  const SimilarMovies({
    Key? key,
    required this.movieId,
    this.franchiseId,
    this.theme,
    this.genreIds = const [],
    this.scrollController,
    this.canNavigateToNewPage = false,
  }) : super(key: key);
  final String movieId;
  final int? franchiseId;
  final String? theme;
  final List<String> genreIds;
  final ScrollController? scrollController;
  final bool canNavigateToNewPage;

  @override
  State<SimilarMovies> createState() => _SimilarMoviesState();
}

class _SimilarMoviesState extends State<SimilarMovies> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSimilarMovies());
  }

  @override
  void didUpdateWidget(covariant SimilarMovies oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movieId != widget.movieId ||
        oldWidget.franchiseId != widget.franchiseId ||
        oldWidget.theme != widget.theme ||
        oldWidget.genreIds.join('|') != widget.genreIds.join('|')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSimilarMovies());
    }
  }

  void _loadSimilarMovies() {
    if (!mounted) return;
    context.read<MoviesProvider>().getSimilarMoviesAPI(
      movieId: widget.movieId,
      franchiseId: widget.franchiseId,
      theme: widget.theme,
      genreIds: widget.genreIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoviesProvider>(
      builder: (context, movieProvider, child) {
        return movieProvider.similarMoviePosters.isNotEmpty
            ? ListView.builder(
                itemCount: movieProvider.similarMoviePosters.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return SimilarMovieCard(
                    actorName: movieProvider.similarMovieTitle[index]
                        .toString(),
                    castImage: movieProvider.similarMoviePosters[index]
                        .toString(),
                    movieId: movieProvider.similarMovieId[index].toString(),
                    scrollController: widget.scrollController,
                    canNavigateToNewPage: widget.canNavigateToNewPage,
                  );
                },
              )
            : Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  "No Similar Movies",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
      },
    );
  }
}
