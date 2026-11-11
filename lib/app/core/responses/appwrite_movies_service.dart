import 'package:appwrite/appwrite.dart';
import 'package:moviewebapp/app/core/config/appwrite_config.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';

class AppwriteMoviesService {
  AppwriteMoviesService({TablesDB? tables})
      : _tables = tables ??
            TablesDB(Client()
              ..setEndpoint(AppwriteConfig.endpoint)
              ..setProject(AppwriteConfig.projectId));

  static const int mcuFranchiseId = 3010;
  static const int _pageSize = 100;

  final TablesDB _tables;

  Future<List<Movies>> getMcuMovies() async {
    final movies = <Movies>[];
    String? cursor;

    do {
      final page = await _tables.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.moviesTableId,
        queries: [
          Query.equal('franchise', [mcuFranchiseId]),
          Query.select(['title', 'poster_path', 'release_date']),
          Query.orderAsc('release_date'),
          Query.limit(_pageSize),
          if (cursor != null) Query.cursorAfter(cursor),
        ],
      );

      movies.addAll(page.rows.map((row) => _movieFromRow(row.$id, row.data)));
      cursor = page.rows.length == _pageSize ? page.rows.last.$id : null;
    } while (cursor != null);

    return List.unmodifiable(movies);
  }

  Movies _movieFromRow(String rowId, Map<String, dynamic> data) {
    final id = int.tryParse(rowId);
    if (id == null) {
      throw FormatException('Movie row ID must be numeric: $rowId');
    }

    final releaseDate = data['release_date'];

    return Movies(
      id: id,
      title: data['title'] as String?,
      posterPath: data['poster_path'] as String?,
      releaseDate: releaseDate is String ? DateTime.tryParse(releaseDate) : null,
    );
  }
}