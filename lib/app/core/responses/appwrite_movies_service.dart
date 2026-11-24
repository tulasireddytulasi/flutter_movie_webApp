import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:moviewebapp/app/core/config/appwrite_config.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';

class AppwriteMoviesService {
  // Use the supplied database service, or connect to the configured project.
  AppwriteMoviesService({TablesDB? tables})
    : _tables =
          tables ??
          TablesDB(
            Client()
              ..setEndpoint(AppwriteConfig.endpoint)
              ..setProject(AppwriteConfig.projectId),
          );

  static const int mcuFranchiseId = 3010;
  static const int conjuringFranchiseId = 1030;
  static const int horrorGenreId = 27;
  static const String monsterTheme = 'monster';
  static const int _pageSize = 20;

  final TablesDB _tables;
  // Coordinate writes per user/movie without blocking unrelated movies.
  final Map<(String, String), Future<void>> _pendingLikeWrites = {};

  // Return the user's like row ID, or null when the movie is not liked.
  Future<String?> findLike(String userId, String movieId) async {
    final key = (userId, movieId);
    var pending = _pendingLikeWrites[key];
    // A movie reopened during a write must read the updated status.
    while (pending != null) {
      await pending;
      pending = _pendingLikeWrites[key];
    }

    final result = await _tables.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.likesTableId,
      ttl: 0, // Like status must not use cached query results.
      queries: [
        Query.equal('user_id', userId),
        Query.equal('item_type', 'movie'),
        Query.equal('item_id', movieId),
        Query.limit(1),
      ],
    );
    return result.rows.isEmpty ? null : result.rows.first.$id;
  }

  // Delete an existing like or create one; return the new row ID or null after deletion.
  Future<String?> toggleLike(
    String userId,
    String movieId, {
    required String? likeId,
  }) async {
    final key = (userId, movieId);
    var pending = _pendingLikeWrites[key];
    while (pending != null) {
      await pending;
      pending = _pendingLikeWrites[key];
    }

    final completed = Completer<void>();
    _pendingLikeWrites[key] = completed.future;
    try {
      if (likeId != null) {
        await _tables.deleteRow(
          databaseId: AppwriteConfig.databaseId,
          tableId: AppwriteConfig.likesTableId,
          rowId: likeId,
        );
        return null;
      }

      final row = await _tables.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.likesTableId,
        rowId: ID.unique(),
        data: {'user_id': userId, 'item_type': 'movie', 'item_id': movieId},
        // Table permissions allow public reads; only the owner may delete.
        permissions: [Permission.delete(Role.user(userId))],
      );
      return row.$id;
    } finally {
      // Unblock waiting requests on failure too; errors still reach the caller.
      _pendingLikeWrites.remove(key);
      completed.complete();
    }
  }

  // Fetch up to 20 non-adult movies, ordered by newest release first.
  Future<List<Movies>> getLatestMovies() => _listMovies([Query.equal('adult', false)], latestFirst: true);

  // Fetch a franchise's movies, ordered oldest first unless latestFirst is enabled.
  Future<List<Movies>> getMoviesByFranchise(int franchiseId, {bool latestFirst = false}) => _listMovies([
    Query.equal('franchise', [franchiseId]),
  ], latestFirst: latestFirst);

  // Fetch movies matching a theme, ordered newest first by default.
  Future<List<Movies>> getMoviesByTheme(String theme, {bool latestFirst = true}) => _listMovies([
    Query.equal('theme', [theme]),
  ], latestFirst: latestFirst);

  // Read a genre's related movies, optionally sort newest first, and return up to 20.
  Future<List<Movies>> getMoviesByGenre(int genreId, {bool latestFirst = true}) async {
    final genre = await _tables.getRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.genresTableId,
      rowId: '$genreId',
      queries: [
        Query.select(['movies.\$id', 'movies.title', 'movies.poster_path', 'movies.release_date']),
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
    return List.unmodifiable(movies.take(_pageSize));
  }

  // Apply filters and release-date ordering to a cached, single-page movie query.
  Future<List<Movies>> _listMovies(List<String> filters, {required bool latestFirst}) async {
    final page = await _tables.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.moviesTableId,
      ttl: 3600,
      queries: [
        ...filters,
        Query.select(['title', 'poster_path', 'release_date']),
        if (latestFirst) Query.orderDesc('release_date') else Query.orderAsc('release_date'),
        Query.limit(_pageSize),
      ],
    );

    final movies = page.rows.map((row) => _movieFromRow(row.$id, row.data)).take(_pageSize).toList();
    return List.unmodifiable(movies);
  }

  // Sort the list in place by newest release, putting missing dates last.
  void _sortLatestFirst(List<Movies> movies) {
    movies.sort((first, second) {
      final firstDate = first.releaseDate;
      final secondDate = second.releaseDate;
      if (firstDate == null) return secondDate == null ? 0 : 1;
      if (secondDate == null) return -1;
      return secondDate.compareTo(firstDate);
    });
  }

  // Convert an Appwrite row to a movie, rejecting nonnumeric IDs.
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
