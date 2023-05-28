import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviewebapp/models/get_movies_model.dart';
import 'package:moviewebapp/models/movie_banner_model.dart';
import 'package:moviewebapp/models/movie_logos_and_posters_model.dart';
import 'package:moviewebapp/responses/movie_apis.dart';

class MoviesProvider extends ChangeNotifier {
  MoviesModel _getPopularMoviesModel = MoviesModel();
  MoviesModel get getPopularMoviesModel => _getPopularMoviesModel;

  MovieLogosAndPostersModel _movieLogosAndPostersModel = MovieLogosAndPostersModel();
  MovieLogosAndPostersModel get movieLogosAndPostersModel => _movieLogosAndPostersModel;

  String _movieLogo = "";
  String get movieLogo => _movieLogo;

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

  MovieBannerModel _movieBannerModel = MovieBannerModel();
  MovieBannerModel get movieBannerModel => _movieBannerModel;

  Future<void> getMovieDetails({required int pageNo, required String movieType}) async {
    try {
      await getPopularMoviesAPI(pageNo: pageNo, movieType: movieType);
      final _data = _getPopularMoviesModel.results?.first;
      await getMovieLogos(movieId: _data?.id.toString() ?? "");
      Map<String, dynamic> _movieData = {
        "moviesList": [
          {
            "id": _data?.id.toString(),
            "title": _data?.title.toString(),
            "description": _data?.overview.toString(),
            "poster": _data?.posterPath.toString(),
            "backDrop": _data?.backdropPath.toString(),
            "logo": _movieLogo,
            "genre": ["drama", "horror"]
          }
        ]
      };
      _movieBannerModel = movieBannerModelFromJson(jsonEncode(_movieData));
    } catch (error, stackTrace) {
      log("getMovieDetails error: $error");
      log("getMovieDetails stackTrace: $stackTrace");
    }

    notifyListeners();
    //  return _movieBannerModel;
  }

  Future<void> getPopularMoviesAPI({required int pageNo, required String movieType}) async {
    _getPopularMoviesModel = await getPopularMoviesList(
      movieType: movieType,
      pageNo: pageNo,
      withOriginalLanguage: "en",
    );
    _getPopularMoviesModel.results?.forEach((element) {
      _title.add(element.title!);
      _date.add(element.releaseDate?.toIso8601String() ?? "0000-00-00");
      _img.add(element.posterPath!);
      _movieId.add(element.id.toString());
    });
  }

  Future<void> getSimilarMoviesAPI({required String movieId}) async {
    _similarMovieTitle.clear();
    _similarMoviePosters.clear();
    _similarMovieId.clear();
    try {
      _getPopularMoviesModel =
          await getSimilarMoviesListData(movieId: movieId, pageNo: "1", withOriginalLanguage: "en");

      _getPopularMoviesModel.results?.forEach((element) {
        if (element.posterPath != null && element.posterPath!.isNotEmpty) {
          _similarMovieTitle.add(element.title ?? "");
          // _date.add(element.releaseDate!.toIso8601String());
          _similarMoviePosters.add(element.posterPath ?? "");
          _similarMovieId.add(element.id.toString());
        }
      });
    } catch (error) {
      log("_similarMoviePosters error: $error");
    }
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> getMovieLogos({required String movieId}) async {
    try {
      _movieLogosAndPostersModel = await getMovieLogosAPI(movieId: movieId);
      _movieLogosAndPostersModel.logos?.forEach((element) {
        if (element.iso6391 != null && element.iso6391?.length != 0 && element.iso6391 == "en") {
          _movieLogo = element.filePath ?? "";
        }
      });
    } catch (error) {
      log("getMovieLogos error: $error");
    }
  }

  Future<List> getMovieData({required String movieId}) async {
    var movieData = await getMovieLogosAPI(movieId: movieId);
    var movieData2 = await getSimilarMoviesListData(movieId: movieId, pageNo: "1", withOriginalLanguage: "en");

    return await Future.wait([movieData, movieData2] as Iterable<Future>);
  }
}
