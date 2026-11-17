import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:moviewebapp/app/core/responses/appwrite_service.dart';
import 'package:moviewebapp/app/models/popular_actors_model.dart';

typedef PeoplePage = ({List<Actors> actors, String? nextCursor});

class PeopleProvider extends ChangeNotifier {
  PeopleProvider({AppwriteService? appwriteService})
      : _appwriteService = appwriteService ?? AppwriteService();

  final AppwriteService _appwriteService;

    Future<PeoplePage> fetchPopularPeoplePage({String? cursorAfter}) async {
        try {
            final page = await _appwriteService.fetchPopularPeoplePage(cursorAfter: cursorAfter);
            final actors = <Actors>[];

            for (final row in page.rows) {
                final id = int.tryParse(row[r'$id']?.toString() ?? '');
                if (id == null) continue;

                actors.add(
                    Actors(
                        adult: row['adult'] as bool?,
                        gender: (row['gender'] as num?)?.toInt(),
                        id: id,
                        knownForDepartment: row['known_for_department'] as String?,
                        name: row['name'] as String?,
                        popularity: (row['popularity'] as num?)?.toDouble(),
                        profilePath: row['profile_path'] as String?,
                    ),
                );
            }

            return (actors: List<Actors>.unmodifiable(actors), nextCursor: page.nextCursor);
        } catch (error, stackTrace) {
            log(
                'PeopleProvider.fetchPopularPeoplePage failed',
                error: error,
                stackTrace: stackTrace,
            );
            rethrow;
    }
    }
}