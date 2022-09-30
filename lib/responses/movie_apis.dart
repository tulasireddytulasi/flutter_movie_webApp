import 'package:http/http.dart';
import 'package:moviewebapp/models/get_movie_info_model.dart';
import 'package:moviewebapp/models/get_movies_model.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/responses/api_services.dart';

Future<Response> getMoviesList({
  required String movieType,
  required String pageNo,
  required String withOriginalLanguage,
}) async {
  final String getPopularMoviesURL =
      "movie/popular?api_key=${ApiConstants.apiKey}&with_original_language="
      "$withOriginalLanguage&page=$pageNo";
  try {
    Response response = await getMethod(getPopularMoviesURL);
    return response;
  } catch (error) {
    rethrow;
  }
}

Future<GetMovies> getPopularMoviesList({
  required String movieType,
  required String pageNo,
  required String withOriginalLanguage,
}) async {
  GetMovies getMoviesModel;
  try {
    Response response = await getMoviesList(
        movieType: movieType,
        pageNo: pageNo,
        withOriginalLanguage: withOriginalLanguage);
    getMoviesModel = getMoviesFromJson(response.body);
    return getMoviesModel;
  } catch (error, stackTrace) {
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

Future<GetMovies> getSimilarMoviesListData({
  required String movieId,
  required String pageNo,
  required String withOriginalLanguage,
}) async {
  GetMovies getSimilarMoviesModel;
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
