import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviewebapp/models/get_movies_model.dart';
import 'package:moviewebapp/responses/movie_apis.dart';

class MoviesProvider extends ChangeNotifier {
  MoviesModel _getPopularMoviesModel = MoviesModel();
  MoviesModel get getPopularMoviesModel => _getPopularMoviesModel;

  final List<String> _title = [];
  List<String> get title => _title;

  final List<String> _movieId = [];
  List<String> get movieId => _movieId;

  final List<String> _img = [];
  List<String> get img => _img;

  final List<String> _date = [];
  List<String> get date => _date;

  final List<String> _similarMovieTitle = [];
  List<String> get similarMovieTitle => _similarMovieTitle;

  final List<String> _similarMovieId = [];
  List<String> get similarMovieId => _similarMovieId;

  final List<String> _similarMoviePosters = [];
  List<String> get similarMoviePosters => _similarMoviePosters;

  getPopularMoviesAPI({required String pageNo}) async {
    _getPopularMoviesModel = await getPopularMoviesList(
        movieType: "popular", pageNo: pageNo, withOriginalLanguage: "en");
    _getPopularMoviesModel.results?.forEach((element) {
      _title.add(element.title!);
      _date.add(element.releaseDate?.toIso8601String() ?? "0000-00-00");
      _img.add(element.posterPath!);
      _movieId.add(element.id.toString());
    });
    notifyListeners();
  }

  getSimilarMoviesAPI({required String movieId}) async {
    _similarMovieTitle.clear();
    _similarMoviePosters.clear();
    _similarMovieId.clear();
    try {
      _getPopularMoviesModel = await getSimilarMoviesListData(
          movieId: movieId, pageNo: "1", withOriginalLanguage: "en");

      _getPopularMoviesModel.results?.forEach((element) {
        if (element.posterPath != null && element.posterPath!.isNotEmpty) {
          _similarMovieTitle.add(element.title ?? "");
          // _date.add(element.releaseDate!.toIso8601String());
          _similarMoviePosters.add(element.posterPath ?? "");
          _similarMovieId.add(element.id.toString());
        }
      });

      // _similarMoviePosters.forEach((element) {
      //   // log("_actorImageUrl: ${ApiConstants.movieImageBaseUrl + element}");
      // });
      log("_similarMoviePosters 55: ${_similarMoviePosters.length}");
      log("_similarMovieTitle: ${_similarMovieTitle.length}");
    } catch (error) {
      log("_similarMoviePosters error: $error");
    }

    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}
