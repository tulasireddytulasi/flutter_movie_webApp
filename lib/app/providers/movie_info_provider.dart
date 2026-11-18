import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviewebapp/app/core/responses/appwrite_service.dart';
import 'package:moviewebapp/app/models/get_movie_info_model.dart';
import 'package:moviewebapp/app/models/review_model.dart';
import 'package:moviewebapp/app/models/youtube_video_model.dart';
import 'package:moviewebapp/app/views/actors_page/actors_page.dart';
import 'package:moviewebapp/app/views/movie_info_screen/movie_info.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';

class MovieInfoProvider extends ChangeNotifier {
  MovieInfoProvider({AppwriteService? appwriteService}) : _appwriteService = appwriteService ?? AppwriteService();

  final AppwriteService _appwriteService;

  bool _isLoadingMovie = false;
  bool get isLoadingMovie => _isLoadingMovie;

  String? _movieError;
  String? get movieError => _movieError;

  int _movieRequestId = 0;

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
    final requestId = ++_movieRequestId;
    _isLoadingMovie = true;
    _movieError = null;
    _getMovieInfo = GetMovieInfo();
    _currentMovieId = movieId;
    _movieTitle = '';
    _overview = '';
    _backdropPath = '';
    _releaseDate = '';
    _releaseYear = '';
    _releaseMonth = '';
    _releaseDay = '';
    _runtime = '';
    _voteCount = '';
    _rating = '';
    _genre = '';
    _genresList.clear();
    _actorId.clear();
    _actorImageUrl.clear();
    _actorName.clear();
    notifyListeners();

    try {
      final row = await _appwriteService.fetchMovieById(movieId);
      if (requestId != _movieRequestId) return;
      final genreRows = row['genres'];
      final genres = <Genre>[];
      if (genreRows is List) {
        for (final genreRow in genreRows.whereType<Map>()) {
          final genreData = Map<String, dynamic>.from(genreRow);
          genres.add(
            Genre(
              id: int.tryParse(genreData[r'$id']?.toString() ?? ''),
              name: genreData['name'] as String?,
            ),
          );
        }
      }

      final castRows = row['cast'];
      final cast = <Cast>[];
      if (castRows is List) {
        for (final castRow in castRows.whereType<Map>()) {
          final castData = Map<String, dynamic>.from(castRow);
          final personRow = castData['person'];
          if (personRow is! Map) continue;

          final personData = Map<String, dynamic>.from(personRow);
          final personId = int.tryParse(personData[r'$id']?.toString() ?? '');
          if (personId == null) continue;

          cast.add(
            Cast(
              id: personId,
              name: personData['name'] as String?,
              profilePath: personData['profile_path'] as String?,
              character: castData['character'] as String?,
              order: (castData['order'] as num?)?.toInt(),
            ),
          );
        }
      }
      cast.sort((first, second) => (first.order ?? 0).compareTo(second.order ?? 0));

      _getMovieInfo = GetMovieInfo(
        adult: row['adult'] as bool?,
        backdropPath: row['backdrop_path'] as String?,
        budget: (row['budget'] as num?)?.toInt(),
        genres: genres,
        id: int.tryParse(row[r'$id']?.toString() ?? movieId),
        originalLanguage: row['language'] as String?,
        originalTitle: row['original_title'] as String?,
        overview: row['overview'] as String?,
        popularity: (row['popularity'] as num?)?.toDouble(),
        posterPath: row['poster_path'] as String?,
        releaseDate: row['release_date'] as String?,
        revenue: (row['revenue'] as num?)?.toInt(),
        runtime: (row['runtime'] as num?)?.toInt(),
        status: row['status'] as String?,
        tagline: row['tagline'] as String?,
        title: row['title'] as String?,
        voteAverage: (row['vote_average'] as num?)?.toDouble(),
        voteCount: (row['vote_count'] as num?)?.toInt(),
        credits: Credits(cast: cast),
      );

      _movieTitle = _getMovieInfo.title ?? '';
      _overview = _getMovieInfo.overview ?? 'NA';
      _currentMovieId = _getMovieInfo.id?.toString() ?? movieId;
      _backdropPath = _getMovieInfo.backdropPath ?? '';

      final movieReleaseDate = DateTime.tryParse(_getMovieInfo.releaseDate ?? '');
      _releaseDate = '';
      _releaseYear = '';
      _releaseMonth = '';
      _releaseDay = '';
      if (movieReleaseDate != null) {
        _releaseDate = DateFormat('yyyy-MM-dd').format(movieReleaseDate);
        _releaseYear = movieReleaseDate.year.toString();
        _releaseMonth = movieReleaseDate.month.toString();
        _releaseDay = movieReleaseDate.day.toString();
      }

      final runtime = _getMovieInfo.runtime;
      _runtime = runtime == null ? 'NA' : '${runtime ~/ 60}h ${runtime % 60}min';
      _voteCount = _getMovieInfo.voteCount?.toString() ?? '0';
      _rating = ((_getMovieInfo.voteAverage ?? 0) / 2).toStringAsFixed(1);

      _genresList
        ..clear()
        ..addAll(genres.map((genre) => genre.name).whereType<String>().where((name) => name.isNotEmpty));
      _genre = _genresList.join(', ');

      _actorId.clear();
      _actorImageUrl.clear();
      _actorName.clear();
      for (final castInfo in cast) {
        if (castInfo.profilePath == null || castInfo.profilePath!.isEmpty) continue;
        _actorImageUrl.add(castInfo.profilePath!);
        _actorName.add(castInfo.name ?? '');
        _actorId.add(castInfo.id?.toString() ?? '');
      }

    } catch (error, stackTrace) {
      if (requestId != _movieRequestId) return;
      log('getMoviesInfoAPI failed', error: error, stackTrace: stackTrace);
      _movieError = error is AppwriteServiceException && error.code == 404
          ? 'This movie is not available in our catalog yet.'
          : 'Unable to load movie details. Please try again.';
    } finally {
      if (requestId == _movieRequestId) {
        _isLoadingMovie = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _movieRequestId++;
    super.dispose();
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
