import 'package:appwrite/appwrite.dart';
import 'package:moviewebapp/app/core/config/appwrite_config.dart';

typedef AppwriteDataPage = ({List<Map<String, dynamic>> rows, String? nextCursor});

class AppwriteServiceException implements Exception {
  const AppwriteServiceException({
    required this.operation,
    required this.message,
    this.code,
    this.cause,
  });

  final String operation;
  final String message;
  final int? code;
  final Object? cause;

  @override
  String toString() => 'AppwriteServiceException: $operation failed: $message';
}

class AppwriteService {
  AppwriteService({TablesDB? tables})
      : _tables = tables ??
            TablesDB(Client()
              ..setEndpoint(AppwriteConfig.endpoint)
              ..setProject(AppwriteConfig.projectId));

  static const int pageSize = 20;

  final TablesDB _tables;

  Future<AppwriteDataPage> fetchPopularPeoplePage({String? cursorAfter}) async {
    try {
      final result = await _tables.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.peopleTableId,
        ttl: 3600, // Caches identical query results in Appwrite memory for 1 hour (3600s)
        queries: [
          Query.orderDesc('popularity'),
          Query.select([
            r'$id',
            'adult',
            'gender',
            'known_for_department',
            'name',
            'popularity',
            'profile_path',
          ]),
          Query.limit(pageSize),
          if (cursorAfter != null) Query.cursorAfter(cursorAfter),
        ],
      );

      return (
        rows: List<Map<String, dynamic>>.unmodifiable(
          result.rows.map((row) => <String, dynamic>{r'$id': row.$id, ...row.data}),
        ),
        nextCursor: result.rows.length < pageSize ? null : result.rows.last.$id,
      );
    } catch (error, stackTrace) {
      _throwRequestError('fetchPopularPeoplePage', error, stackTrace);
    }
  }

  Future<AppwriteDataPage> fetchMoviesPage({String? cursorAfter}) async {
    try {
      final result = await _tables.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.moviesTableId,
        ttl: 3600, // Caches identical query results in Appwrite memory for 1 hour (3600s)
        queries: [
          Query.orderDesc('release_date'),
          Query.orderDesc('popularity'),
          Query.select([
            r'$id',
            'title',
            'poster_path',
            'release_date',
            'popularity',
          ]),
          Query.limit(pageSize),
          if (cursorAfter != null) Query.cursorAfter(cursorAfter),
        ],
      );

      return (
        rows: List<Map<String, dynamic>>.unmodifiable(
          result.rows.map((row) => <String, dynamic>{r'$id': row.$id, ...row.data}),
        ),
        nextCursor: result.rows.length < pageSize ? null : result.rows.last.$id,
      );
    } catch (error, stackTrace) {
      _throwRequestError('fetchMoviesPage', error, stackTrace);
    }
  }

  Future<Map<String, dynamic>> fetchMovieById(String movieId) async {
    try {
      final row = await _tables.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.moviesTableId,
        rowId: movieId,
        queries: [
          Query.select([
            'title',
            'original_title',
            'overview',
            'release_date',
            'runtime',
            'budget',
            'revenue',
            'status',
            'adult',
            'popularity',
            'vote_average',
            'vote_count',
            'poster_path',
            'backdrop_path',
            'language',
            'genres.\$id',
            'genres.name',
            'cast.\$id',
            'cast.character',
            'cast.order',
            'cast.person.\$id',
            'cast.person.name',
            'cast.person.profile_path',
          ]),
        ],
      );

      return Map<String, dynamic>.unmodifiable({r'$id': row.$id, ...row.data});
    } catch (error, stackTrace) {
      _throwRequestError('fetchMovieById/$movieId', error, stackTrace);
    }
  }

  Future<Map<String, dynamic>> fetchPersonById(String personId) async {
    try {
      final row = await _tables.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.peopleTableId,
        rowId: personId,
        queries: [
          Query.select([
            'adult',
            'also_known_as',
            'biography',
            'birthday',
            'deathday',
            'gender',
            'homepage',
            'imdb_id',
            'known_for_department',
            'name',
            'place_of_birth',
            'popularity',
            'profile_path',
          ]),
        ],
      );

      return Map<String, dynamic>.unmodifiable({...row.data, r'$id': row.$id});
    } catch (error, stackTrace) {
      _throwRequestError('fetchPersonById/$personId', error, stackTrace);
    }
  }

  Future<List<Map<String, dynamic>>> fetchPersonMovieCredits(String personId) async {
    try {
      final credits = <Map<String, dynamic>>[];
      String? cursor;

      do {
        final page = await _tables.listRows(
          databaseId: AppwriteConfig.databaseId,
          tableId: AppwriteConfig.movieCastTableId,
          ttl: 3600,
          queries: [
            Query.equal('person.\$id', [personId]),
            Query.select([
              r'$id',
              'character',
              'order',
              'movie.\$id',
              'movie.title',
              'movie.poster_path',
              'movie.release_date',
              'movie.popularity',
            ]),
            Query.limit(pageSize),
            if (cursor != null) Query.cursorAfter(cursor),
          ],
        );

        credits.addAll(page.rows.map((row) => <String, dynamic>{...row.data, r'$id': row.$id}));
        cursor = page.rows.length == pageSize ? page.rows.last.$id : null;
      } while (cursor != null);

      return List<Map<String, dynamic>>.unmodifiable(credits);
    } catch (error, stackTrace) {
      _throwRequestError('fetchPersonMovieCredits/$personId', error, stackTrace);
    }
  }

  Never _throwRequestError(String operation, Object error, StackTrace stackTrace) {
    final appwriteError = error is AppwriteException ? error : null;
    Error.throwWithStackTrace(
      AppwriteServiceException(
        operation: operation,
        message: appwriteError?.message ?? appwriteError?.type ?? 'Unexpected request failure',
        code: appwriteError?.code,
        cause: error,
      ),
      stackTrace,
    );
  }
}