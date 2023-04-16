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

  Color _appBarBackgroundColor = Colors.transparent;
  Color get appBarBackgroundColor => _appBarBackgroundColor;

  double _appBarElevation = 0.0;
  double get appBarElevation => _appBarElevation;

  setAppBarColorAndElevation(
      {required Color color, required double elevation}) {
    _appBarBackgroundColor = color;
    _appBarElevation = elevation;
    notifyListeners();
  }

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
