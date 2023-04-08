import 'package:flutter/material.dart';
import 'package:moviewebapp/models/get_movies_model.dart';
import 'package:moviewebapp/responses/movie_apis.dart';

class DashBoardProvider extends ChangeNotifier {
  MoviesModel _popularMoviesModel = MoviesModel();
  MoviesModel get popularMoviesModel => _popularMoviesModel;

  MoviesModel _horrorMoviesModel = MoviesModel();
  MoviesModel get horrorMoviesModel => _horrorMoviesModel;

  MoviesModel _actionMoviesModel = MoviesModel();
  MoviesModel get actionMoviesModel => _actionMoviesModel;

  MoviesModel _topRatedMoviesModel = MoviesModel();
  MoviesModel get topRatedMoviesModel => _topRatedMoviesModel;

  getPopularMoviesAPI({required int pageNo}) async {
    _popularMoviesModel = await getPopularMoviesList(
      movieType: "popular",
      pageNo: pageNo,
      withOriginalLanguage: "en",
    );
    notifyListeners();
  }
}
