import 'package:flutter/material.dart';
import 'package:moviewebapp/models/get_movie_info_model.dart';
import 'package:moviewebapp/responses/movie_apis.dart';

class MovieInfoProvider extends ChangeNotifier {
  GetMovieInfo _getMovieInfo = GetMovieInfo();
  GetMovieInfo get getMovieInfo => _getMovieInfo;

  String _movieTitle = "";
  String get movieTitle => _movieTitle;

  String _backdropPath = "";
  String get backdropPath => _backdropPath;

  final String _budget = "";
  String get budget => _budget;

  final String _overview = "";
  String get overview => _overview;

  final String _popularity = "";
  String get popularity => _popularity;

  final String _releaseDate = "";
  String get releaseDate => _releaseDate;

  final String _revenue = "";
  String get revenue => _revenue;

  final String _runtime = "";
  String get runtime => _runtime;

  final String _voteAverage = "";
  String get voteAverage => _voteAverage;

  final List<String> _actorImageUrl = [];
  List<String> get actorImageUrl => _actorImageUrl;

  final List<String> _actorName = [];
  List<String> get actorName => _actorName;

  final List<String> _similarMoviesUrl = [];
  List<String> get similarMoviesUrl => _similarMoviesUrl;

  final List<String> _similarMoviesName = [];
  List<String> get similarMoviesUrlName => _similarMoviesName;

  clearBackdropPath() {
    _backdropPath = "";
  }

  getMoviesInfoAPI(
      {required String movieId, required String appendToResponse}) async {
    _getMovieInfo = await getMoviesInfoData(
        movieId: movieId, appendToResponse: appendToResponse);

    _movieTitle = _getMovieInfo.title ?? "";

    _backdropPath = _getMovieInfo.backdropPath ?? "";
    print("_backdropPath: $_backdropPath");

    _actorImageUrl.clear();
    _actorName.clear();

    _getMovieInfo.credits?.cast?.forEach((castInfo) {
      if (castInfo.profilePath != null && castInfo.profilePath!.isNotEmpty) {
        _actorImageUrl.add(castInfo.profilePath ?? "");
        _actorName.add(castInfo.name ?? "");
      }
    });

    _actorImageUrl.forEach((element) {
      // print("_actorImageUrl: ${ApiConstants.movieImageBaseUrl + element}");
    });
    print("_actorName: ${_actorName}");
    print("_actorImageUrl 55: ${_actorImageUrl.length}");
    print("_actorName55: ${_actorName.length}");

    notifyListeners();
  }
}
