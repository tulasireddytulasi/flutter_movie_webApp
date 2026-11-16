import 'package:appwrite/appwrite.dart';
import 'package:moviewebapp/app/core/config/appwrite_config.dart';
import 'package:moviewebapp/app/models/popular_actors_model.dart';

typedef AppwritePeoplePage = ({List<Actors> actors, String? nextCursor});

class AppwritePeopleService {
  AppwritePeopleService({TablesDB? tables})
      : _tables = tables ??
            TablesDB(Client()
              ..setEndpoint(AppwriteConfig.endpoint)
              ..setProject(AppwriteConfig.projectId));

  static const int pageSize = 20;

  final TablesDB _tables;

  Future<AppwritePeoplePage> fetchPopularPage({String? cursorAfter}) async {
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

    final actors = <Actors>[];
    for (final row in result.rows) {
      final id = int.tryParse(row.$id);
      if (id == null) continue;

      final data = row.data;
      actors.add(
        Actors(
          adult: data['adult'] as bool?,
          gender: (data['gender'] as num?)?.toInt(),
          id: id,
          knownForDepartment: data['known_for_department'] as String?,
          name: data['name'] as String?,
          popularity: (data['popularity'] as num?)?.toDouble(),
          profilePath: data['profile_path'] as String?,
        ),
      );
    }

    return (
      actors: List<Actors>.unmodifiable(actors),
      nextCursor: result.rows.length < pageSize ? null : result.rows.last.$id,
    );
  }
}