import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:moviewebapp/app/views/all_movies_screen/widgets/movie_card.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:provider/provider.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
    super.key,
    required this.withOriginalLanguage,
    required this.movieType,
    this.withGenres,
    required this.screenTitle,
  });
  final String withOriginalLanguage;
  final String movieType;
  final String? withGenres;
  final String screenTitle;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final PagingController<int, Movies> _pagingController = PagingController(
    firstPageKey: 1,
  );
  final Map<int, String> _cursorByPage = {};
  late final MoviesProvider _moviesProvider;

  @override
  void initState() {
    super.initState();
    _moviesProvider = context.read<MoviesProvider>();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchMovies(pageKey: pageKey);
    });
  }

  Future<void> _fetchMovies({required int pageKey}) async {
    try {
      final page = await _moviesProvider.fetchMovies(
        cursorAfter: _cursorByPage[pageKey],
      );
      if (!mounted) return;

      if (page.nextCursor == null) {
        _pagingController.appendLastPage(page.movies);
      } else {
        _cursorByPage[pageKey + 1] = page.nextCursor!;
        _pagingController.appendPage(page.movies, pageKey + 1);
      }
    } catch (error, stackTrace) {
      log("fetchMovies error: $error");
      log("fetchMovies stackTrace: $stackTrace");
      if (mounted) _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktopOrTablet = screenWidth >= 600;
    return Scaffold(
      appBar: !isDesktopOrTablet
          ? AppBar(
              title: Text(
                widget.screenTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => PagedGridView<int, Movies>(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            showNewPageProgressIndicatorAsGridChild: false,
            showNewPageErrorIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            pagingController: _pagingController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              crossAxisCount: MovieCard.columnsFor(constraints.maxWidth),
            ),
            builderDelegate: PagedChildBuilderDelegate<Movies>(
              itemBuilder: (context, item, index) => MovieCard(
                key: ValueKey(item.id ?? index),
                onTap: () {
                  Navigation().navigateToMoviesInfoPage(
                    context: context,
                    movieId: item.id.toString(),
                    screenWidth: screenWidth,
                    title: item.title ?? 'movie',
                  );
                },
                movieName: item.title ?? "",
                imageURL: item.posterPath ?? "",
                movieId: item.id?.toString() ?? '',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
