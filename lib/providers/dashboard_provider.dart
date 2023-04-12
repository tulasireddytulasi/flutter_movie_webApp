import 'package:flutter/material.dart';

class DashBoardProvider extends ChangeNotifier {
  String _movieTitle = "";
  String get movieTitle => _movieTitle;

  String _movieID = "";
  String get movieID => _movieID;

  String _moviePoster = "";
  String get moviePoster => _moviePoster;

  String _backdropPath = "";
  String get backdropPath => _backdropPath;

  setMovieData({
    required String movieTitle,
    required String movieID,
    required String moviePoster,
    required String backdropPath,
  }) {
    _movieTitle = movieTitle;
    _movieID = movieID;
    _moviePoster = moviePoster;
    _backdropPath = backdropPath;
    notifyListeners();
  }
}
