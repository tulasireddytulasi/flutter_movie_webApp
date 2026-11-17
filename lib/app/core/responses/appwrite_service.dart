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