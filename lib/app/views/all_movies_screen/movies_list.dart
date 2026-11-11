import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/views/all_movies_screen/widgets/movie_card.dart';

import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
    Key? key,
    required this.withOriginalLanguage,
    required this.movieType,
    this.withGenres,
    required this.screenTitle,
    required this.showAppBar,
    this.showLeadingIcon = true,
  }) : super(key: key);
  final String withOriginalLanguage;
  final String movieType;
  final String? withGenres;
  final String screenTitle;
  final bool showAppBar;
  final bool showLeadingIcon;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final PagingController<int, Movies> _pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchMovies(pageKey: pageKey);
    });
  }

  _fetchMovies({required int pageKey}) async {
    try {
      final List<Movies> movies = await fetchMovies(
        movieType: widget.movieType,
        pageKey: pageKey,
        withOriginalLanguage: widget.withOriginalLanguage,
        withGenres: widget.withGenres,
      );
      if (!mounted) return;
      if (movies.isEmpty) {
        _pagingController.appendLastPage(movies);
      } else {
        _pagingController.appendPage(movies, pageKey + 1);
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
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              leading: widget.showLeadingIcon
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    )
                  : null,
              title: Text(
                widget.screenTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
