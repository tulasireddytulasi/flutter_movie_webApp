import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/repository/json_objects/marvel_movies_json.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';

class DashBoardProvider extends ChangeNotifier {
  Color _appBarBackgroundColor = Colors.transparent;

  Color get appBarBackgroundColor => _appBarBackgroundColor;

  double _appBarElevation = 0.0;

  double get appBarElevation => _appBarElevation;

  final List<MoviesModel> _moviesModelList = [];

  List<MoviesModel> get moviesModelList => _moviesModelList;
  final List<String> _moviesLabelList = [];

  List<String> get moviesLabelList => _moviesLabelList;

  final Map<String, dynamic> _moviesDataMapObject = {
    "0": {
      "movieLabel": Constants.marvelMovies,
      "movieType": Constants.marvelMovies,
      "withOriginalLanguage": Constants.english,
      "withGenres": "",
    },
    "1": {
      "movieLabel": Constants.popularMovies,
      "movieType": Constants.popular,
      "withOriginalLanguage": Constants.english,
      "withGenres": "",
    },
    "2": {
      "movieLabel": Constants.topRatedMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": "",
    },
    "3": {
      "movieLabel": Constants.nowPlayingMovies,
      "movieType": Constants.nowPlaying,
      "withOriginalLanguage": Constants.english,
      "withGenres": "",
    },
    "4": {
      "movieLabel": Constants.horrorMovies,
      "movieType": Constants.popular,
      "withOriginalLanguage": Constants.english,
      "withGenres": "27",
    },
    "5": {
      "movieLabel": Constants.thrillerMovies,
      "movieType": Constants.popular,
      "withOriginalLanguage": Constants.english,
      "withGenres": "53",
    },
    "6": {
      "movieLabel": Constants.romanceMovies,
      "movieType": Constants.popular,
      "withOriginalLanguage": Constants.english,
      "withGenres": "10749",
    },
    "7": {
      "movieLabel": Constants.scificMovies,
      "movieType": Constants.popular,
      "withOriginalLanguage": Constants.english,
      "withGenres": "878",
    },
  };

  Map<String, dynamic> get moviesDataMapObject => _moviesDataMapObject;

  setAppBarColorAndElevation({required Color color, required double elevation}) {
    _appBarBackgroundColor = color;
    _appBarElevation = elevation;
    notifyListeners();
  }

  Future<MoviesModel> getAllMovies({
    required String withOriginalLanguage,
    required String movieType,
    required String? withGenres,
  }) async {
    MoviesModel _movieModel = MoviesModel();
    try {
      if(movieType == Constants.marvelMovies){
        _movieModel = getMoviesFromJson(json.encode(MoviesRepo.marvelMovies));
        return _movieModel;
      }
      _movieModel = await getPopularMoviesList(
        movieType: movieType,
        pageNo: 1,
        withOriginalLanguage: withOriginalLanguage,
        withGenres: withGenres ?? "",
      );

      return _movieModel;
    } catch (error, stackTrace) {
      log("getAllMoviesList error: $error");
      log("getAllMoviesList stackTrace: $stackTrace");
      return _movieModel;
    }
  }
}
