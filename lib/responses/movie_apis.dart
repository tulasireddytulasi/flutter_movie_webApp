import 'package:http/http.dart';
import 'package:moviewebapp/models/get_popular_movies_model.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/responses/api_services.dart';

Future<Response> getMovies({
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

Future<GetPopularMovies> getPopularMovies({
  required String movieType,
  required String pageNo,
  required String withOriginalLanguage,
}) async {
  GetPopularMovies getPopularMoviesModel;
  try {
    Response response = await getMovies(
        movieType: movieType,
        pageNo: pageNo,
        withOriginalLanguage: withOriginalLanguage);
    getPopularMoviesModel = getPopularMoviesFromJson(response.body);
    return getPopularMoviesModel;
  } catch (error, stackTrace) {
    rethrow;
  }
}
