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
  static const int conjuringFranchiseId = 1030;
  static const int horrorGenreId = 27;
  static const String monsterTheme = 'monster';
  static const int _pageSize = 100;

  final TablesDB _tables;

  Future<List<Movies>> getMoviesByFranchise(
    int franchiseId, {
    bool latestFirst = false,
  }) =>
      _listMovies(
        [Query.equal('franchise', [franchiseId])],
        latestFirst: latestFirst,
      );

  Future<List<Movies>> getMoviesByTheme(
    String theme, {
    bool latestFirst = true,
  }) =>
      _listMovies(
        [Query.equal('theme', [theme])],
        latestFirst: latestFirst,
      );

  Future<List<Movies>> getMoviesByGenre(
    int genreId, {
    bool latestFirst = true,
  }) async {
    final genre = await _tables.getRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.genresTableId,
      rowId: '$genreId',
      queries: [
        Query.select([
          'movies.\$id',
          'movies.title',
          'movies.poster_path',
          'movies.release_date',
        ]),
      ],
    );

    final relatedMovies = genre.data['movies'];
    if (relatedMovies is! List) return const <Movies>[];

    final movies = <Movies>[];
    for (final relatedMovie in relatedMovies) {
      if (relatedMovie is! Map) continue;
      final data = Map<String, dynamic>.from(relatedMovie);
      final rowId = data[r'$id']?.toString();
      if (rowId == null) continue;
      movies.add(_movieFromRow(rowId, data));
    }

    if (latestFirst) _sortLatestFirst(movies);
    return List.unmodifiable(movies);
  }

  Future<List<Movies>> _listMovies(
    List<String> filters, {
    required bool latestFirst,
  }) async {
    final movies = <Movies>[];
    String? cursor;

    do {
      final page = await _tables.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.moviesTableId,
        queries: [
          ...filters,
          Query.select(['title', 'poster_path', 'release_date']),
          if (latestFirst) Query.orderDesc('release_date') else Query.orderAsc('release_date'),
          Query.limit(_pageSize),
          if (cursor != null) Query.cursorAfter(cursor),
        ],
      );

      movies.addAll(page.rows.map((row) => _movieFromRow(row.$id, row.data)));
      cursor = page.rows.length == _pageSize ? page.rows.last.$id : null;
    } while (cursor != null);

    return List.unmodifiable(movies);
  }

  void _sortLatestFirst(List<Movies> movies) {
    movies.sort((first, second) {
      final firstDate = first.releaseDate;
      final secondDate = second.releaseDate;
      if (firstDate == null) return secondDate == null ? 0 : 1;
      if (secondDate == null) return -1;
      return secondDate.compareTo(firstDate);
    });
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