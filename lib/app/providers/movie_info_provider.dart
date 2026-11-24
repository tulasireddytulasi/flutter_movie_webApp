import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviewebapp/app/core/responses/appwrite_movies_service.dart';
import 'package:moviewebapp/app/core/responses/appwrite_service.dart';
import 'package:moviewebapp/app/models/get_movie_info_model.dart';
import 'package:moviewebapp/app/models/review_model.dart';
import 'package:moviewebapp/app/models/youtube_video_model.dart';
import 'package:moviewebapp/app/views/actors_page/actors_page.dart';
import 'package:moviewebapp/app/views/movie_info_screen/movie_info.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';
import 'package:moviewebapp/app/providers/auth_session.dart';

class MovieInfoProvider extends ChangeNotifier {
  MovieInfoProvider({
    required AuthSession authSession,
    AppwriteService? appwriteService,
    AppwriteMoviesService? appwriteMoviesService,
  }) : _authSession = authSession,
       _appwriteService = appwriteService ?? AppwriteService(),
       _appwriteMoviesService =
           appwriteMoviesService ??
           AppwriteMoviesService(tables: TablesDB(authSession.client)) {
    // Login/logout refreshes the current movie's like without involving the widget.
    _lastAuthState = _authSession.state;
    _authSession.addListener(_onAuthSessionChanged);
  }

  final AppwriteService _appwriteService;
  final AppwriteMoviesService _appwriteMoviesService;
  final AuthSession _authSession;
  late AsyncSnapshot<models.User?> _lastAuthState;

  void _onAuthSessionChanged() {
    final session = _authSession.state;
    // OTP form updates do not change the session or require another like query.
    if (identical(session, _lastAuthState)) return;
    _lastAuthState = session;
    _loadMovieLike();
  }

  String? _likeRowId;
  String? _likeError;
  bool _loadingLike = false;
  bool _savingLike = false;
  bool _loginOpen = false;
  bool _disposed = false;
  int _likeRequestId = 0;

  bool get _likeAvailable =>
      _currentMovieId.isNotEmpty && !_isLoadingMovie && _movieError == null;
  bool get hasLikedMovie => _likeRowId != null;
  bool get isMovieLikeBusy =>
      _loadingLike ||
      _savingLike ||
      _loginOpen ||
      _authSession.state.connectionState == ConnectionState.waiting;
  bool get canToggleMovieLike => _likeAvailable && !isMovieLikeBusy;
  String? get movieLikeError => _authSession.state.hasError
      ? 'Could not check login status. Tap retry to try again.'
      : _likeError;

  void _setMovieLikeState({
    String? rowId,
    bool loading = false,
    bool saving = false,
    String? error,
  }) {
    if (_disposed) return;
    _likeRowId = rowId;
    _loadingLike = loading;
    _savingLike = saving;
    _likeError = error;
    notifyListeners();
  }

  Future<void> _loadMovieLike() async {
    if (_disposed) return;
    final requestId = ++_likeRequestId;
    final session = _authSession.state;
    final userId = session.data?.$id;
    final movieId = _currentMovieId;
    if (!_likeAvailable ||
        session.connectionState == ConnectionState.waiting ||
        session.hasError ||
        userId == null) {
      _setMovieLikeState();
      return;
    }

    _setMovieLikeState(loading: true);
    try {
      final rowId = await _appwriteMoviesService.findLike(userId, movieId);
      // Discard responses for a previous movie, user or disposed provider.
      if (!_disposed && requestId == _likeRequestId) {
        _setMovieLikeState(rowId: rowId);
      }
    } catch (error, stack) {
      log('Could not load movie like', error: error, stackTrace: stack);
      if (!_disposed && requestId == _likeRequestId) {
        _setMovieLikeState(
          error: 'Could not load your like. Tap retry to try again.',
        );
      }
    }
  }

  bool _isCurrentLike(String movieId, String userId) =>
      !_disposed &&
      _likeAvailable &&
      _currentMovieId == movieId &&
      _authSession.state.data?.$id == userId;

  Future<String?> toggleMovieLike({
    required Future<models.User?> Function() requestLogin,
  }) async {
    if (_disposed || !canToggleMovieLike) return null;
    final session = _authSession.state;
    if (session.hasError) {
      await _authSession.refresh();
      return movieLikeError;
    }

    final userId = session.data?.$id;
    if (userId == null) {
      final movieId = _currentMovieId;
      models.User? user;
      _loginOpen = true;
      notifyListeners();
      try {
        // The widget supplies the dialog; the provider decides when login is needed.
        user = await requestLogin();
      } catch (error, stack) {
        log('Could not open movie login', error: error, stackTrace: stack);
        return 'Could not open login. Please try again.';
      } finally {
        _loginOpen = false;
        if (!_disposed) notifyListeners();
      }
      if (user == null || !_isCurrentLike(movieId, user.$id)) return null;
      await _loadMovieLike();
      if (!_isCurrentLike(movieId, user.$id)) return null;
      if (_likeError != null) return _likeError;
      // A guest's first tap adds a like, but never removes an existing one.
      if (!hasLikedMovie) {
        return toggleMovieLike(requestLogin: requestLogin);
      }
      return null;
    }

    if (_likeError != null) {
      await _loadMovieLike();
      return _likeError;
    }

    final requestId = ++_likeRequestId;
    final movieId = _currentMovieId;
    final rowId = _likeRowId;
    _setMovieLikeState(rowId: rowId, saving: true);
    try {
      final updatedRowId = await _appwriteMoviesService.toggleLike(
        userId,
        movieId,
        likeId: rowId,
      );
      if (!_disposed && requestId == _likeRequestId) {
        _setMovieLikeState(rowId: updatedRowId);
      }
      return null;
    } catch (error, stack) {
      log('Could not update movie like', error: error, stackTrace: stack);
      if (!_isCurrentLike(movieId, userId)) return null;
      const message = 'Could not update your like. Please try again.';
      if (requestId != _likeRequestId) return message;

      // Another tab may already have created this user's like.
      if (error is AppwriteException && error.code == 409 && rowId == null) {
        await _loadMovieLike();
        if (!_isCurrentLike(movieId, userId)) return null;
        return _likeError ?? (hasLikedMovie ? null : message);
      }
      // Reload after uncertain writes so the heart reflects the server's state.
      if (error is AppwriteException && error.code == 401) {
        await _authSession.refresh();
      } else {
        await _loadMovieLike();
      }
      return message;
    }
  }

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

  String? _logoPath;
  String? get logoPath => _logoPath;

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
  int? _franchiseId;
  int? get franchiseId => _franchiseId;
  String? _theme;
  String? get theme => _theme;
  List<String> _genreIds = const [];
  List<String> get genreIds => _genreIds;

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
    _screensList[1] = ActorsPage(actorId: actorId);
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
      YouTubeVideosModel _youTubeVideosModel = await getMovieVideosAPI(
        movieId: movieId,
      );
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

  Future<void> getMoviesInfoAPI({
    required String movieId,
    required String appendToResponse,
  }) async {
    final requestId = ++_movieRequestId;
    _isLoadingMovie = true;
    _movieError = null;
    _getMovieInfo = GetMovieInfo();
    _currentMovieId = movieId;
    _movieTitle = '';
    _overview = '';
    _backdropPath = '';
    _logoPath = null;
    _releaseDate = '';
    _releaseYear = '';
    _releaseMonth = '';
    _releaseDay = '';
    _runtime = '';
    _voteCount = '';
    _rating = '';
    _genre = '';
    _genresList.clear();
    _franchiseId = null;
    _theme = null;
    _genreIds = const [];
    _actorId.clear();
    _actorImageUrl.clear();
    _actorName.clear();
    // Clear the previous movie's like and invalidate its pending requests.
    _loadMovieLike();

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
      cast.sort(
        (first, second) => (first.order ?? 0).compareTo(second.order ?? 0),
      );

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
      _logoPath = row['logo'] as String?;

      final movieReleaseDate = DateTime.tryParse(
        _getMovieInfo.releaseDate ?? '',
      );
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
      _runtime = runtime == null
          ? 'NA'
          : '${runtime ~/ 60}h ${runtime % 60}min';
      _voteCount = _getMovieInfo.voteCount?.toString() ?? '0';
      _rating = ((_getMovieInfo.voteAverage ?? 0) / 2).toStringAsFixed(1);

      _genresList
        ..clear()
        ..addAll(
          genres
              .map((genre) => genre.name)
              .whereType<String>()
              .where((name) => name.isNotEmpty),
        );
      _genre = _genresList.join(', ');
      _franchiseId = (row['franchise'] as num?)?.toInt();
      final theme = row['theme']?.toString().trim();
      _theme = theme == null || theme.isEmpty ? null : theme;
      _genreIds = genreRows is List
          ? genreRows
                .whereType<Map>()
                .map((genre) => genre[r'$id']?.toString())
                .whereType<String>()
                .where((id) => id.isNotEmpty)
                .toList()
          : const [];

      _actorId.clear();
      _actorImageUrl.clear();
      _actorName.clear();
      for (final castInfo in cast) {
        if (castInfo.profilePath == null || castInfo.profilePath!.isEmpty)
          continue;
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
        // Load likes only when movie details finish, not on trailer/review updates.
        _loadMovieLike();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _likeRequestId++;
    _movieRequestId++;
    _authSession.removeListener(_onAuthSessionChanged);
    super.dispose();
  }

  void notify() => notifyListeners();

  Future<void> getMovieReviewsInfoAPI({
    required String movieId,
    required String pageNo,
  }) async {
    try {
      ReviewModel _reviewModel = await getMovieReviews(
        movieId: movieId,
        pageNo: pageNo,
      );
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
        _avatarImg.add(
          avatarPath.isNotEmpty
              ? ApiConstants.movieImageBaseUrlw185 + avatarPath
              : avatarPath,
        );
      }
      _authorName.add(element.author ?? "");
      final String reviewDate =
          element.updatedAt?.toIso8601String() ?? Constants.time00;
      if (reviewDate.isNotEmpty && reviewDate != Constants.time00) {
        String reviewDateValue = DateFormat(
          "yyyy-MM-dd",
        ).format(element.updatedAt!).toString();
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
