import 'package:appwrite/appwrite.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';

class AppwriteMovieService {
  static const String endpoint = 'https://nyc.cloud.appwrite.io/v1';
  static const String projectId = '6a566f7e0020a7ca4f55';
  static const String databaseId = '6ae9d8f70009a29b3b5b';
  static const String tableId = '6ae9d976001eff727511';

  late final TablesDB _tablesDB;

  AppwriteMovieService() {
    final client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId);
    _tablesDB = TablesDB(client);
  }

  Future<void> upsertMovie(Movies movie) async {
    final int? movieId = movie.id;
    final String? title = movie.title?.trim();
    if (movieId == null || title == null || title.isEmpty) {
      throw StateError('Movie is missing its ID or title.');
    }

    final Map<String, dynamic> data = <String, dynamic>{
      'title': title,
      'genreIds': movie.genreIds ?? <int>[],
    };

    if (movie.releaseDate != null) {
      final date = movie.releaseDate!;
      data['releaseDate'] = DateTime.utc(date.year, date.month, date.day).toIso8601String();
    }
    if (movie.posterPath != null) data['posterPath'] = movie.posterPath;
    if (movie.backdropPath != null) data['backdropPath'] = movie.backdropPath;
    if (movie.popularity != null) data['popularity'] = movie.popularity;

    await _tablesDB.upsertRow(
      databaseId: databaseId,
      tableId: tableId,
      rowId: movieId.toString(),
      data: data,
    );
  }
}