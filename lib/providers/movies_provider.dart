import 'package:flutter/material.dart';
import 'package:moviewebapp/models/get_popular_movies_model.dart';
import 'package:moviewebapp/responses/movie_apis.dart';

class MoviesProvider extends ChangeNotifier {
  GetPopularMovies _getPopularMoviesModel = GetPopularMovies();

  GetPopularMovies get getPopularMoviesModel => _getPopularMoviesModel;

  final List<String> _title = [];
  List<String> get title => _title;

  final List<String> _img = [];
  List<String> get img => _img;

  final List<String> _date = [];
  List<String> get date => _date;

  getPopularMoviesAPI({required String pageNo}) async {
    _getPopularMoviesModel = await getPopularMovies(
        movieType: "popular", pageNo: pageNo, withOriginalLanguage: "en");

    _getPopularMoviesModel.results?.forEach((element) {
      _title.add(element.title!);
      _date.add(element.releaseDate!.toIso8601String());
      _img.add(element.posterPath!);
    });
    notifyListeners();
  }
}
