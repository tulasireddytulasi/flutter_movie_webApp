import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviewebapp/app/models/get_movie_info_model.dart';
import 'package:moviewebapp/app/models/review_model.dart';
import 'package:moviewebapp/app/models/youtube_video_model.dart';
import 'package:moviewebapp/app/views/actors_page/actors_page.dart';
import 'package:moviewebapp/app/views/movie_info_screen/movie_info.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';

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

  String _overview = "";
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

  final List<String> _avatarImg = [];
  List<String> get avatarImg => _avatarImg;

  final List<String> _authorName = [];
  List<String> get authorName => _authorName;

  final List<String> _reviewDate = [];
  List<String> get reviewDate => _reviewDate;

  final List<String> _reviewerRating = [];
  List<String> get reviewerRating => _reviewerRating;

  final List<String> _reviewContent = [];
  List<String> get reviewContent => _reviewContent;

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

  String _youTubeKey = "";
  String get youTubeKey => _youTubeKey;

  Future<void> getMovieVideos({required String movieId}) async {
    bool newVideo = false;
    try {
      YouTubeVideosModel _youTubeVideosModel = await getMovieVideosAPI(movieId: movieId);
      for (var videosData in _youTubeVideosModel.results ?? []) {
        if (videosData.type == "Trailer" && videosData.official!) {
          newVideo = true;
          _youTubeKey = videosData.key ?? "";
          break;
        }
      }
      if (!newVideo) _youTubeKey = "";
      notifyListeners();
    } catch (error) {
      log("getMovieVideos error: $error");
    }
  }

  Future<void> getMoviesInfoAPI({required String movieId, required String appendToResponse}) async {
    _getMovieInfo = await getMoviesInfoData(movieId: movieId, appendToResponse: appendToResponse);
    _movieTitle = _getMovieInfo.title ?? "";
    _overview = _getMovieInfo.overview ?? "NA";
    _currentMovieId = _getMovieInfo.id.toString();
    _backdropPath = _getMovieInfo.backdropPath ?? "";
    final String releaseDate = _getMovieInfo.releaseDate.toString();
    if (releaseDate.isNotEmpty) {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateTime movieReleaseDate = dateFormat.parse(releaseDate);
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
      }
    });

    notifyListeners();
  }

  void notify() => notifyListeners();

  Future<void> getMovieReviewsInfoAPI({required String movieId, required String pageNo}) async {
    try {
      ReviewModel _reviewModel = await getMovieReviews(movieId: movieId, pageNo: pageNo);
      clearData();
      processReviewData(reviewModel: _reviewModel);
    } catch (error) {
      log("Movie Review API Error: $error");
    }
    notifyListeners();
  }

  clearData() {
    _avatarImg.clear();
    _authorName.clear();
    _reviewDate.clear();
    _reviewerRating.clear();
    _reviewContent.clear();
  }

  processReviewData({required ReviewModel reviewModel}) {
    reviewModel.results?.forEach((element) {
      String avatarPath = element.authorDetails?.avatarPath ?? "";
      if (avatarPath.isNotEmpty && avatarPath.contains("https")) {
        if (avatarPath[0] == "/") {
          avatarPath = avatarPath.substring(1);
          _avatarImg.add(avatarPath);
        } else {
          _avatarImg.add(avatarPath);
        }
      } else {
        _avatarImg.add(avatarPath.isNotEmpty ? ApiConstants.movieImageBaseUrlw185 + avatarPath : avatarPath);
      }
      _authorName.add(element.author ?? "");
      final String reviewDate = element.updatedAt?.toIso8601String() ?? Constants.time00;
      if (reviewDate.isNotEmpty && reviewDate != Constants.time00) {
        String reviewDateValue = DateFormat("yyyy-MM-dd").format(element.updatedAt!).toString();
        _reviewDate.add(reviewDateValue);
      } else {
        _reviewDate.add(Constants.time00);
      }
      final double? rating = element.authorDetails?.rating;
      if (rating != null) {
        _reviewerRating.add(rating.toString());
      } else {
        _reviewerRating.add("NA");
      }
      _reviewContent.add(element.content ?? "No Reviews");
    });
  }
}
