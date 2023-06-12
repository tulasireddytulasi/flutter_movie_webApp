import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviewebapp/models/get_movies_model.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/responses/movie_apis.dart';
import 'package:moviewebapp/utils/constants.dart';
import 'package:provider/provider.dart';

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
      "movieLabel": Constants.popularMovies,
      "movieType": Constants.popular,
      "withOriginalLanguage": Constants.english,
      "withGenres": "",
    },
    "1": {
      "movieLabel": Constants.topRatedMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": "",
    },
    "2": {
      "movieLabel": Constants.nowPlayingMovies,
      "movieType": Constants.nowPlaying,
      "withOriginalLanguage": Constants.english,
      "withGenres": "",
    },
    "3": {
      "movieLabel": Constants.horrorMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": "27",
    },
    "4": {
      "movieLabel": Constants.thrillerMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": "53",
    },
    "5": {
      "movieLabel": Constants.romanceMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": "10749",
    },
    "6": {
      "movieLabel": Constants.scificMovies,
      "movieType": Constants.topRated,
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

  Future<void> getAllMoviesList() async {
    try {
      for (Map<String, dynamic> moviesDataMapObject in _moviesDataMapObject.values) {
        final MoviesModel _movieModel = await getPopularMoviesList(
          movieType: moviesDataMapObject["movieType"],
          pageNo: 1,
          withOriginalLanguage: moviesDataMapObject["withOriginalLanguage"],
          withGenres: moviesDataMapObject["withGenres"],
        );
        _moviesLabelList.add(moviesDataMapObject["movieLabel"]);
        _moviesModelList.add(_movieModel);
      }
      notifyListeners();
    } catch (error, stackTrace) {
      log("getAllMoviesList error: $error");
      log("getAllMoviesList stackTrace: $stackTrace");
    }
  }

  bool _isDataLoaded = false;
  bool get isDataLoaded => _isDataLoaded;
  getDashBoardData({required BuildContext context}) async {
    try {
      _isDataLoaded = false;
      MoviesProvider _moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
      _moviesProvider.getMovieDetails(pageNo: 1, movieType: "popular");
      await Future.wait([_moviesProvider.getMovieDetails(pageNo: 1, movieType: "popular"), getAllMoviesList()]);
      _isDataLoaded = true;
    } catch (error, stackTrace) {
      log("getDashBoardData error: $error");
      log("getDashBoardData stackTrace: $stackTrace");
    }
  }
}
