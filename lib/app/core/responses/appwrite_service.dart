import 'package:appwrite/appwrite.dart';
import 'package:moviewebapp/app/core/config/appwrite_config.dart';

typedef AppwriteDataPage = ({List<Map<String, dynamic>> rows, String? nextCursor});

class AppwriteService {
  AppwriteService({TablesDB? tables})
      : _tables = tables ??
            TablesDB(Client()
              ..setEndpoint(AppwriteConfig.endpoint)
              ..setProject(AppwriteConfig.projectId));

  static const int pageSize = 20;

  final TablesDB _tables;

  Future<AppwriteDataPage> fetchPopularPeoplePage({String? cursorAfter}) async {
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
  }

  Future<AppwriteDataPage> fetchMoviesPage({String? cursorAfter}) async {
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
  }
}