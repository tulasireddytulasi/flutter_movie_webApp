import 'dart:convert';

import 'package:http/http.dart';
import 'package:moviewebapp/models/actor_images_model.dart';
import 'package:moviewebapp/models/actor_movie_model.dart';
import 'package:moviewebapp/models/actors_info_model.dart';
import 'package:moviewebapp/models/get_movie_info_model.dart';
import 'package:moviewebapp/models/get_movies_model.dart';
import 'package:moviewebapp/models/popular_actors_model.dart';
import 'package:moviewebapp/models/review_model.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/responses/api_services.dart';

Future<Response> getMoviesList({
  required String movieType,
  required int pageNo,
  required String withOriginalLanguage,
  String? withGenres,
}) async {
  final String getPopularMoviesURL =
      "movie/$movieType?api_key=${ApiConstants.apiKey}&with_original_language="
      "$withOriginalLanguage&page=$pageNo&with_genres=$withGenres";
  try {
    Response response = await getMethod(getPopularMoviesURL);
    return response;
  } catch (error) {
    rethrow;
  }
}

Future<MoviesModel> getPopularMoviesList({
  required String movieType,
  required int pageNo,
  required String withOriginalLanguage,
  String? withGenres,
}) async {
  MoviesModel getMoviesModel;
  try {
    Response response = await getMoviesList(
        movieType: movieType,
        pageNo: pageNo,
        withOriginalLanguage: withOriginalLanguage,
        withGenres: withGenres);
    getMoviesModel = getMoviesFromJson(response.body);
    await Future.delayed(const Duration(seconds: 1));
    return getMoviesModel;
  } catch (error, stackTrace) {
    rethrow;
  }
}

Future<List<Movies>> fetchMovies(
    {required int pageKey,
    required String movieType,
    required String withOriginalLanguage,
    String? withGenres}) async {
  try {
    final response = await getMoviesList(
      movieType: movieType,
      pageNo: pageKey,
      withOriginalLanguage: withOriginalLanguage,
      withGenres: withGenres,
    );
    if (response.statusCode == 200) {
      MoviesModel getMoviesModel = getMoviesFromJson(response.body);
      final List<Movies> movies = getMoviesModel.results!;
      return movies;
    } else {
      throw Exception('Failed to load page');
    }
  } catch (error) {
    rethrow;
  }
}

Future<Response> getMoviesInfo({
  required String movieId,
  required String appendToResponse,
}) async {
  final String getPopularMoviesURL =
      "movie/$movieId?api_key=${ApiConstants.apiKey}&append_to_response="
      "$appendToResponse";
  try {
    Response response = await getMethod(getPopularMoviesURL);
    return response;
  } catch (error) {
    rethrow;
  }
}

Future<GetMovieInfo> getMoviesInfoData({
  required String movieId,
  required String appendToResponse,
}) async {
  GetMovieInfo getPopularMoviesModel;
  try {
    Response response = await getMoviesInfo(
      movieId: movieId,
      appendToResponse: appendToResponse,
    );
    getPopularMoviesModel = getMovieInfoFromJson(response.body);
    return getPopularMoviesModel;
  } catch (error, stackTrace) {
    rethrow;
  }
}

Future<Response> getSimilarMoviesList({
  required String movieId,
  required String pageNo,
  required String withOriginalLanguage,
}) async {
  final String getPopularMoviesURL =
      "movie/$movieId/recommendations?api_key=${ApiConstants.apiKey}&with_original_language="
      "$withOriginalLanguage&page=$pageNo";
  try {
    Response response = await getMethod(getPopularMoviesURL);
    return response;
  } catch (error) {
    rethrow;
  }
}

Future<MoviesModel> getSimilarMoviesListData({
  required String movieId,
  required String pageNo,
  required String withOriginalLanguage,
}) async {
  MoviesModel getSimilarMoviesModel;
  try {
    Response response = await getSimilarMoviesList(
        movieId: movieId,
        pageNo: pageNo,
        withOriginalLanguage: withOriginalLanguage);
    getSimilarMoviesModel = getMoviesFromJson(response.body);
    return getSimilarMoviesModel;
  } catch (error, stackTrace) {
    rethrow;
  }
}

Future<ActorImagesModel> getPopularActorsImages(
    {required String actorId}) async {
  ActorImagesModel getMoviesModel;
  final String _popularActorsImages =
      "person/$actorId/images?api_key=${ApiConstants.apiKey}";
  try {
    Response response = await getMethod(_popularActorsImages);
    getMoviesModel = actorImagesModelFromJson(response.body);
    return getMoviesModel;
  } catch (error, stackTrace) {
    rethrow;
  }
}

Future<ActorInfoModel> getActorsInfo({required String actorId}) async {
  ActorInfoModel getActorsInfo;
  final String _actorsInfo = "person/$actorId?api_key=${ApiConstants.apiKey}";
  try {
    Response response = await getMethod(_actorsInfo);
    // log("info: ${response.body}");
    getActorsInfo = actorInfoModelFromJson(response.body);
    return getActorsInfo;
  } catch (error, stackTrace) {
    rethrow;
  }
}

Future<PopularActorsModel> getPopularActorsInfo(
    {required String languageCode, required int pageNo}) async {
  PopularActorsModel getPopularActorsInfo;
  final String _actorsInfo =
      "person/popular/?&language=$languageCode&page=$pageNo&api_key=${ApiConstants.apiKey}";
  try {
    Response response = await getMethod(_actorsInfo);
    getPopularActorsInfo = popularActorsModelFromJson(response.body);
    return getPopularActorsInfo;
  } catch (error, stackTrace) {
    rethrow;
  }
}

Future<List<Actors>> fetchPopularActors({
  required int pageNo,
  required String languageCode,
}) async {
  try {
    PopularActorsModel _popularActorsModel =
        await getPopularActorsInfo(languageCode: languageCode, pageNo: pageNo);
    final List<Actors> actorsList = _popularActorsModel.actors!;
    return actorsList;
  } catch (error) {
    rethrow;
  }
}

Future<ActorMovieModel> getActorsActedMoviesInfo(
    {required String actorId}) async {
  ActorMovieModel actorsMovieModel;
  final String _actorsInfo =
      "person/$actorId/movie_credits?&api_key=${ApiConstants.apiKey}";
  try {
    Response response = await getMethod(_actorsInfo);
    actorsMovieModel = ActorMovieModel.fromJson(json.decode(response.body));
    return actorsMovieModel;
  } catch (error, stackTrace) {
    rethrow;
  }
}

Future<ReviewModel> getMovieReviews({
  required String movieId,
  required String pageNo,
}) async {
  ReviewModel _reviewModel;
  final String _reviewsAPI =
      "movie/$movieId/reviews?api_key=${ApiConstants.apiKey}&page=$pageNo";
  try {
    Response response = await getMethod(_reviewsAPI);
    _reviewModel = reviewModelFromJson(response.body);
    return _reviewModel;
  } catch (error, stackTrace) {
    rethrow;
  }
}
