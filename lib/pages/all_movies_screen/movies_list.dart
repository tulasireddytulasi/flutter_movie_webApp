import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import 'package:moviewebapp/models/movie_model.dart';
import 'package:moviewebapp/pages/all_movies_screen/widgets/movie_card.dart';
import 'package:moviewebapp/providers/movies_provider.dart';

import 'package:moviewebapp/responses/movie_apis.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:moviewebapp/utils/constants.dart';
import 'package:moviewebapp/utils/navigation/navigation.dart';
import 'package:provider/provider.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
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
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final PagingController<int, Movie> _pagingController =
      PagingController(firstPageKey: 1);

  int columns = 5;
  Map<String, dynamic> layoutData = {};
  bool isMovieTitleVisible = true;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey).then((movies) {
        _pagingController.appendPage(movies, pageKey + 1);
      }).catchError((error) {
        _pagingController.error = error;
      });
    });
  }

  Future<List<Movie>> _fetchPage(int pageKey) async {
    final response = await getMoviesList(
      movieType: widget.movieType,
      pageNo: pageKey,
      withOriginalLanguage: widget.withOriginalLanguage,
      withGenres: widget.withGenres,
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData['results'];
      final List<Movie> movies =
          results.map((movieData) => Movie.fromJson(movieData)).toList();
      return movies;
    } else {
      throw Exception('Failed to load page');
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Widget messageText({required String text}) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: BLACK,
        ),
      ),
    );
  }

  String getReleaseDate({required DateTime? releaseDate}) {
    String movieReleaseDateValue;
    if (releaseDate != null) {
      movieReleaseDateValue =
          DateFormat("yyyy-MM-dd").format(releaseDate).toString();
      return movieReleaseDateValue;
    } else {
      return Constants.time00;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    layoutData = getMovieCardWidth(screenWidth: screenWidth);
    columns = layoutData["columns"];
    isMovieTitleVisible = layoutData["isMovieTitleVisible"];

    return Consumer<MoviesProvider>(builder: (context, movieProvider, child) {
      return Scaffold(
        backgroundColor: tealishBlue,
        appBar: AppBar(
          backgroundColor: tealishBlue,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: WHITE,
            ),
          ),
          title: Text(
            widget.screenTitle,
            style: const TextStyle(fontSize: 18, color: WHITE),
          ),
        ),
        body: PagedGridView<int, Movie>(
          showNewPageProgressIndicatorAsGridChild: false,
          showNewPageErrorIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          pagingController: _pagingController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: screenWidth >= 900 ? 0.56666 : 0.66666,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: columns,
          ),
          builderDelegate: PagedChildBuilderDelegate<Movie>(
            itemBuilder: (context, item, index) => InkWell(
              onTap: () {
                Navigation().navigateToMoviesInfoPage(
                  context: context,
                  movieId: item.id.toString(),
                  screenWidth: screenWidth,
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
      );
    });
  }
}
