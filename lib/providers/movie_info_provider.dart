import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviewebapp/models/get_movie_info_model.dart';
import 'package:moviewebapp/pages/actors_page/actors_page.dart';
import 'package:moviewebapp/pages/movie_info_screen/movie_info.dart';
import 'package:moviewebapp/responses/movie_apis.dart';

class MovieInfoProvider extends ChangeNotifier {
  GetMovieInfo _getMovieInfo = GetMovieInfo();
  GetMovieInfo get getMovieInfo => _getMovieInfo;

  String _movieTitle = "";
  String get movieTitle => _movieTitle;

  String _currentMovieId = "";
  String get currentMovieId => _currentMovieId;

  String _backdropPath = "";
  String get backdropPath => _backdropPath;

  final String _budget = "";
  String get budget => _budget;

  final String _overview = "";
  String get overview => _overview;

  final String _popularity = "";
  String get popularity => _popularity;

  String _releaseDate = "";
  String get releaseDate => _releaseDate;

  String _releaseYear = "";
  String get releaseYear => _releaseYear;

  String _releaseMonth = "";
  String get releaseMonth => _releaseMonth;

  String _releaseDay = "";
  String get releaseDay => _releaseDay;

  final String _revenue = "";
  String get revenue => _revenue;

  String _runtime = "";
  String get runtime => _runtime;

  final List<String> _actorId = [];
  List<String> get actorId => _actorId;

  final List<String> _actorImageUrl = [];
  List<String> get actorImageUrl => _actorImageUrl;

  final List<String> _actorName = [];
  List<String> get actorName => _actorName;

  final List<String> _similarMoviesUrl = [];
  List<String> get similarMoviesUrl => _similarMoviesUrl;

  final List<String> _similarMoviesName = [];
  List<String> get similarMoviesUrlName => _similarMoviesName;

  final List<String> _genresList = [];
  String _genre = "";
  String get genre => _genre;

  String _voteCount = "";
  String get voteCount => _voteCount;

  String _rating = "";
  String get rating => _rating;

  final List<String> _previousMoviesIds = [];
  List<String> get previousMoviesIds => _previousMoviesIds;

  String _currentActorId = "";
  String get currentActorId => _currentActorId;

  int _currentScreenIndex = 0;
  int get currentScreenIndex => _currentScreenIndex;

  setCurrentScreenIndex({required int currentScreenIndex}) {
    _currentScreenIndex = currentScreenIndex;
    notifyListeners();
  }

  final List _screensList = [
    const MovieInfoScreen(movieId: ""),
    const ActorsPage(actorId: ''),
  ];
  List get screensList => _screensList;

  /// Updating [_screensList] variable
  setMovieInfoScreen({required String movieId}) {
    _screensList[0] = MovieInfoScreen(movieId: movieId);
  }

  /// Updating [_screensList] variable
  setActorsPage({required String actorId}) {
    _screensList[1] = ActorsPage(
      actorId: actorId,
    );
  }

  addPreviousMoviesIds({required String movieId}) {
    _previousMoviesIds.insert(0, movieId);
  }

  removePreviousMoviesIds() {
    _previousMoviesIds.removeAt(0);
  }

  removePreviousAllMoviesIds() {
    _previousMoviesIds.clear();
  }

  clearBackdropPath() {
    _backdropPath = "";
  }

  void getMoviesInfoAPI(
      {required String movieId, required String appendToResponse}) async {
    _getMovieInfo = await getMoviesInfoData(
        movieId: movieId, appendToResponse: appendToResponse);
    _movieTitle = _getMovieInfo.title ?? "";
    _currentMovieId = _getMovieInfo.id.toString();
    _backdropPath = _getMovieInfo.backdropPath ?? "";
    if (_getMovieInfo.releaseDate!.toString() != null &&
        _getMovieInfo.releaseDate!.toString().isNotEmpty) {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateTime movieReleaseDate =
          dateFormat.parse(_getMovieInfo.releaseDate!.toString());
      String formattedDate = DateFormat('yyyy-MM-dd').format(movieReleaseDate);
      _releaseDate = formattedDate;
      _releaseYear = movieReleaseDate.year.toString();
      _releaseMonth = movieReleaseDate.month.toString();
      _releaseDay = movieReleaseDate.day.toString();
    }

    int t = _getMovieInfo.runtime!;
    int hours = (t ~/ 60).toInt();
    int minutes = t % 60;
    _runtime = "${hours}h ${minutes}min";

    _voteCount = _getMovieInfo.voteCount.toString();
    _rating = (_getMovieInfo.voteAverage! / 2).toStringAsFixed(1);

    _genresList.clear();
    for (var element in _getMovieInfo.genres!) {
      if (element.name != null && element.name!.isNotEmpty) {
        _genresList.add(element.name!);
      }
    }
    _genre = _genresList.join(", ");
    _actorId.clear();
    _actorImageUrl.clear();
    _actorName.clear();

    _getMovieInfo.credits?.cast?.forEach((castInfo) {
      if (castInfo.profilePath != null && castInfo.profilePath!.isNotEmpty) {
        _actorImageUrl.add(castInfo.profilePath ?? "");
        _actorName.add(castInfo.name ?? "");
        _actorId.add(castInfo.id.toString());
        log("_actorName: ${castInfo.name}");
        log("_actorImageUrl 666: ${castInfo.profilePath}");
      }
    });

    notifyListeners();
  }
}
