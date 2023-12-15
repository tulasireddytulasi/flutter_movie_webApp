import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/views/all_movies_screen/widgets/movie_card.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';

import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:moviewebapp/app/core/utils/commom_functions.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:moviewebapp/app/core/utils/styles.dart';
import 'package:provider/provider.dart';

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
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final PagingController<int, Movies> _pagingController = PagingController(firstPageKey: 1);

  int columns = 5;
  Map<String, dynamic> layoutData = {};
  bool isMovieTitleVisible = true;

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
      _pagingController.appendPage(movies, pageKey + 1);
    } catch (error, stackTrace) {
      log("error: $error");
      log("stackTrace: $stackTrace");
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  String getReleaseDate({required DateTime? releaseDate}) {
    String movieReleaseDateValue;
    if (releaseDate != null) {
      movieReleaseDateValue = DateFormat("yyyy-MM-dd").format(releaseDate).toString();
      return movieReleaseDateValue;
    } else {
      return Constants.time00;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    final bool _screenWidth600 = _screenWidth >= 600;
    layoutData = getMovieCardWidth(screenWidth: _screenWidth);
    columns = layoutData["columns"];
    isMovieTitleVisible = layoutData["isMovieTitleVisible"];

    return Consumer<MoviesProvider>(builder: (context, movieProvider, child) {
      return Scaffold(
        backgroundColor: tealishBlue,
        appBar: widget.showAppBar
            ? AppBar(
                backgroundColor: tealishBlue,
                leading: widget.showLeadingIcon
                    ? IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: WHITE,
                        ),
                      )
                    : null,
                title: Text(
                  widget.screenTitle,
                  style: semiBoldGrey30,
                ),
              )
            : null,
        body: SafeArea(
          child: PagedGridView<int, Movies>(
            showNewPageProgressIndicatorAsGridChild: false,
            showNewPageErrorIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            pagingController: _pagingController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: _screenWidth >= 900 ? 0.56666 : 0.66666,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: columns,
            ),
            builderDelegate: PagedChildBuilderDelegate<Movies>(
              itemBuilder: (context, item, index) => InkWell(
                onTap: () {
                  Navigation().navigateToMoviesInfoPage(
                    context: context,
                    movieId: item.id.toString(),
                    screenWidth: _screenWidth,
                  );
                },
                child: MovieCard(
                  movieName: item.title ?? "",
                  imageURL: item.posterPath ?? "",
                  movieReleaseDate: getReleaseDate(releaseDate: item.releaseDate),
                  isMovieTitleVisible: isMovieTitleVisible,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}