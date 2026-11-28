import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviewebapp/app/core/responses/appwrite_service.dart';
import 'package:moviewebapp/app/models/actor_images_model.dart';
import 'package:moviewebapp/app/models/actor_movie_model.dart' as actor_movies;
import 'package:moviewebapp/app/models/actors_info_model.dart';
import 'package:moviewebapp/app/models/popular_actors_model.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ActorsInfoProvider extends ChangeNotifier {
  ActorsInfoProvider({AppwriteService? appwriteService})
      : _appwriteService = appwriteService ?? AppwriteService();

  final AppwriteService _appwriteService;
  int _moviesRequestId = 0;
  int _actorInfoRequestId = 0;

  ActorImagesModel _actorImagesModel = ActorImagesModel();

  ActorImagesModel get actorImagesModel => _actorImagesModel;

  ActorInfoModel _actorInfoModel = ActorInfoModel();

  ActorInfoModel get actorInfoModel => _actorInfoModel;

  PopularActorsModel _popularActorsModel = PopularActorsModel();

  PopularActorsModel get popularActorsModel => _popularActorsModel;

  final List<String> _actorsImages = [];

  List<String> get actorsImages => _actorsImages;

  final List<String> _allActorsImages = [];

  List<String> get allActorsImages => _allActorsImages;

  String _biography = "";

  String get biography => _biography;

  String _profilePic = "";

  String get profilePic => _profilePic;

  String _actorName = "";

  String get actorName => _actorName;

  String _actorId = "";

  String get actorId => _actorId;

  String _dob = "";

  String get dob => _dob;

  String _role = "";

  String get role => _role;

  String _birthPlace = "";

  String get birthPlace => _birthPlace;

  String _gender = "";

  String get gender => _gender;

  String _homePage = "";

  String get homePage => _homePage;

  final List<String> _actorNameList = [];

  List<String> get actorNameList => _actorNameList;

  final List<String> _actorIdList = [];

  List<String> get actorIdList => _actorIdList;

  int _totalMoviesActed = 0;

  int get totalMoviesActed => _totalMoviesActed;

  setTotalMoviesActed({required int totalMoviesActed}) {
    _totalMoviesActed = totalMoviesActed;
    notifyListeners();
  }

  Future<actor_movies.ActorMovieModel> fetchActorMovies({required String actorId}) async {
    final requestId = ++_moviesRequestId;
    _totalMoviesActed = 0;
    try {
      final credits = await _appwriteService.fetchPersonMovieCredits(actorId);
      final moviesById = <int, actor_movies.Cast>{};

      for (final credit in credits) {
        final movie = credit['movie'];
        if (movie is! Map) continue;
        final movieId = int.tryParse(movie[r'$id']?.toString() ?? '');
        if (movieId == null) continue;

        moviesById.putIfAbsent(
          movieId,
          () => actor_movies.Cast(
            id: movieId,
            title: movie['title'] as String?,
            posterPath: movie['poster_path'] as String?,
            releaseDate: movie['release_date'] as String?,
            popularity: (movie['popularity'] as num?)?.toDouble(),
            character: credit['character'] as String?,
            creditId: credit[r'$id'] as String?,
            order: (credit['order'] as num?)?.toInt(),
          ),
        );
      }

      final movies = moviesById.values.toList();
      movies.sort((first, second) {
        final firstDate = DateTime.tryParse(first.releaseDate ?? '');
        final secondDate = DateTime.tryParse(second.releaseDate ?? '');
        if (firstDate == null && secondDate != null) return 1;
        if (firstDate != null && secondDate == null) return -1;
        final dateOrder = firstDate == null ? 0 : secondDate!.compareTo(firstDate);
        return dateOrder != 0 ? dateOrder : (second.popularity ?? 0).compareTo(first.popularity ?? 0);
      });

      if (requestId == _moviesRequestId) {
        _totalMoviesActed = movies.length;
        notifyListeners();
      }
      return actor_movies.ActorMovieModel(id: int.tryParse(actorId), cast: movies);
    } catch (error, stackTrace) {
      log('ActorsInfoProvider.fetchActorMovies failed', error: error, stackTrace: stackTrace);
      if (requestId == _moviesRequestId) notifyListeners();
      rethrow;
    }
  }

  getActorsImagesAPI({required String actorId}) async {
    _actorsImages.clear();
    try {
      _actorImagesModel = await getPopularActorsImages(actorId: actorId);

      _actorImagesModel.profiles?.forEach((element) {
        if (element.filePath != null && element.filePath!.isNotEmpty) {
          _actorsImages.add(element.filePath!);
        }
      });
    } catch (error) {
      log("_actorsImages error: ${error}");
    }
    notifyListeners();
  }

  Future<void> getActorsInfoAPI({required String actorId}) async {
    final requestId = ++_actorInfoRequestId;
    try {
      final row = await _appwriteService.fetchPersonById(actorId);
      if (requestId != _actorInfoRequestId) return;

      final birthday = row['birthday'];
      final aliases = row['also_known_as'];
      _actorInfoModel = ActorInfoModel(
        id: int.tryParse(row[r'$id']?.toString() ?? actorId),
        adult: row['adult'] as bool?,
        alsoKnownAs: aliases is List ? List<String>.from(aliases) : null,
        biography: row['biography'] as String?,
        birthday: birthday is String ? DateTime.tryParse(birthday) : null,
        deathday: row['deathday'],
        gender: (row['gender'] as num?)?.toInt(),
        homepage: row['homepage'] as String?,
        imdbId: row['imdb_id'] as String?,
        knownForDepartment: row['known_for_department'] as String?,
        name: row['name'] as String?,
        placeOfBirth: row['place_of_birth'] as String?,
        popularity: (row['popularity'] as num?)?.toDouble(),
        profilePath: row['profile_path'] as String?,
      );
      _actorName = _actorInfoModel.name ?? "";
      _actorId = _actorInfoModel.id?.toString() ?? actorId;
      _profilePic = _actorInfoModel.profilePath ?? "";
      _biography = _actorInfoModel.biography ?? "";
      _gender = '';
      if (_actorInfoModel.gender == 1) {
        _gender = "Female";
      } else if (_actorInfoModel.gender == 2) {
        _gender = "Male";
      }
      if (_actorInfoModel.birthday != null) {
        _dob = DateFormat('yyyy-MM-dd').format(_actorInfoModel.birthday!);
      } else {
        _dob = Constants.time00;
      }

      _birthPlace = _actorInfoModel.placeOfBirth ?? "";
      _role = _actorInfoModel.knownForDepartment ?? "";
      _homePage = _actorInfoModel.homepage ?? "";
    } catch (error, stackTrace) {
      log('ActorsInfoProvider.getActorsInfoAPI failed', error: error, stackTrace: stackTrace);
      if (requestId != _actorInfoRequestId) return;
      _actorInfoModel = ActorInfoModel();
      _actorName = '';
      _actorId = '';
      _profilePic = '';
      _biography = '';
      _gender = '';
      _dob = Constants.time00;
      _birthPlace = '';
      _role = '';
      _homePage = '';
    }
    notifyListeners();
  }

  getPopularActorsInfoAPI({required String languageCode, required int pageNo}) async {
    try {
      _popularActorsModel = await getPopularActorsInfo(languageCode: languageCode, pageNo: pageNo);

      _popularActorsModel.actors?.forEach((element) {
        if (element.profilePath != null && element.profilePath!.isNotEmpty) {
          _allActorsImages.add(element.profilePath!);
          _actorNameList.add(element.name!);
          _actorIdList.add(element.id.toString());
        }
      });
    } catch (error) {
      log("_actorsImages error: ${error}");
    }
    notifyListeners();
  }

  Future<List<Actors>> fetchPopularActors({
    required int pageNo,
    required String languageCode,
  }) async {
    try {
      _popularActorsModel = await getPopularActorsInfo(languageCode: languageCode, pageNo: pageNo);
      final List<Actors> actorsList = _popularActorsModel.actors!;
      return actorsList;
    } catch (error) {
      rethrow;
    }
  }

  // Share Image with text
  Future<void> shareImage({required String baseUrl, required String imgUrl, required String descText}) async {
    try {
      Uint8List uint8list = await getImageAPI(imgUrl: imgUrl, baseUrl: baseUrl);
      final temp = await getTemporaryDirectory();
      final path = "${temp.path}/image.jpg";
      File(path).writeAsBytesSync(uint8list);
      final result = await Share.shareXFiles([XFile(path)], text: descText);
      if (result.status == ShareResultStatus.success) {
        log('Thank you for sharing the picture!');
      }
    } catch (e, m) {
      log('Error shareImage: $e');
      log('Error Stack shareImage: $m');
    }
  }
}
