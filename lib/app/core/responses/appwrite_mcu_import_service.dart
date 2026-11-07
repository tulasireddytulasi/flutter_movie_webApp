import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:moviewebapp/app/models/mcu_import_models.dart';

abstract class McuImportStore {
  Future<void> preflight(McuImportCancellation cancellation);

  Future<List<McuImportRow>> credits(String table, String movieId, McuImportCancellation cancellation);

  Future<void> upsert(McuImportRow row, McuImportCancellation cancellation);

  Future<bool> personExists(String id, McuImportCancellation cancellation);

  Future<bool> movieExists(String id, McuImportCancellation cancellation);

  Future<bool> createPersonIfMissing(McuImportRow row, McuImportCancellation cancellation);
}

class AppwriteMcuImportService implements McuImportStore {
  AppwriteMcuImportService({TablesDB? tables})
      : _tables = tables ??
            TablesDB(Client()
              ..setEndpoint(endpoint)
              ..setProject(projectId));

  static const endpoint = 'https://nyc.cloud.appwrite.io/v1';
  static const projectId = '6a566f7e0020a7ca4f55';
  static const databaseId = '6ae9d8f70009a29b3b5b';
  static const tableIds = {
    'movies': '6aeeda38001f609f0ca2',
    'genres': 'genres',
    'people': 'people',
    'movie_cast': 'movie_cast',
    'movie_crew': 'movie_crew',
  };
  static const setupNotice = 'Anonymous uploads require Any create/read/update on all five tables. '
      'Register this app hostname in Appwrite. Existing rows must also allow '
      'read/update when row security is enabled. Revoke temporary public writes '
      'after importing. Column metadata cannot be inspected by this client SDK: '
      'confirm franchise is an optional writable String sized for your value, all '
      'schema columns/relationships exist, and budget/revenue support values '
      'above 2,147,483,647. Schema or permission failures stop the run.';

  final TablesDB _tables;

  Future<bool> _rowExists(String table, String id, McuImportCancellation cancellation) =>
      _request('Check $table/$id', () async {
        try {
          await _tables.getRow(
            databaseId: databaseId,
            tableId: tableIds[table]!,
            rowId: id,
            queries: [
              Query.select(['\$id'])
            ],
          );
          return true;
        } on AppwriteException catch (error) {
          if (error.code == 404 && error.type == 'row_not_found') return false;
          rethrow;
        }
      }, cancellation);

  @override
  Future<bool> movieExists(String id, McuImportCancellation cancellation) => _rowExists('movies', id, cancellation);

  @override
  Future<bool> personExists(String id, McuImportCancellation cancellation) => _rowExists('people', id, cancellation);

  static void checkExistingCredits(List<McuImportRow> stored, List<McuImportRow> incoming, List<String> warnings) {
    for (final old in stored) {
      final exact = incoming.where((row) => row.id == old.id);
      if (exact.isNotEmpty) {
        if (referenceId(old.data['person']) != exact.first.data['person']) {
          throw McuImportException('Existing ${old.table}/${old.id} references a different person.');
        }
        continue;
      }
      final duplicates = incoming.where((row) =>
          referenceId(old.data['person']) == row.data['person'] &&
          (old.table == 'movie_cast'
              ? old.data['character'] == row.data['character']
              : old.data['job'] == row.data['job'] && old.data['department'] == row.data['department']));
      if (duplicates.isNotEmpty) {
        throw McuImportException('Legacy ${old.table} row ${old.id} has a nonmatching credit ID. '
            'Migrate existing credits before retrying; no rows were deleted.');
      }
      warnings.add('${old.table}/${old.id} is outside this selected import; kept unchanged.');
    }
  }

  @override
  Future<bool> createPersonIfMissing(McuImportRow row, McuImportCancellation cancellation) async {
    if (row.table != 'people') {
      throw const McuImportException('Expected a people row.');
    }
    if (await personExists(row.id, cancellation)) return false;
    final created = await _request('Create people/${row.id}', () async {
      try {
        await _tables.createRow(
          databaseId: databaseId,
          tableId: tableIds['people']!,
          rowId: row.id,
          data: row.data,
        );
        return true;
      } on AppwriteException catch (error) {
        // A concurrent importer may have created the person after our read.
        if (error.code == 409 && await personExists(row.id, cancellation)) {
          return false;
        }
        rethrow;
      }
    }, cancellation);
    cancellation.check();
    if (created) {
      final stored = await _request(
          'Verify people/${row.id}',
          () => _tables.getRow(
                databaseId: databaseId,
                tableId: tableIds['people']!,
                rowId: row.id,
              ),
          cancellation);
      verify(row, stored.data);
    }
    return created;
  }

  List<String> _select(String table) => [
        '*',
        if (table == 'movies') 'genres.\$id',
        if (table.startsWith('movie_')) ...['movie.\$id', 'person.\$id'],
      ];

  Future<T> _request<T>(String context, Future<T> Function() operation, McuImportCancellation cancellation) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      cancellation.check();
      try {
        // Await in-flight writes instead of timing out and leaving late writes.
        return await operation();
      } on AppwriteException catch (error) {
        final code = error.code;
        final transient = code == 0 || code == null || (code >= 500 && code <= 599);
        if (transient && attempt < 2) {
          await cancellation.wait(Duration(seconds: 1 << attempt));
          continue;
        }
        throw McuImportException(
          '$context: Appwrite ${code ?? "network error"} '
          '${error.message ?? error.type ?? "request failed"}. '
          '${code == 401 || code == 403 ? "Check Any permissions and row security." : ""}'
          '${code == 400 ? "Check column sizes/types, franchise, relationships, and integer ranges." : ""}'
          '${code == 429 ? "Rate limited; retry later (SDK does not expose Retry-After)." : ""}',
          global: code == 400 || code == 401 || code == 403 || code == 429,
        );
      }
    }
    throw McuImportException('$context: retries exhausted.');
  }

  @override
  Future<void> preflight(McuImportCancellation cancellation) async {
    for (final entry in tableIds.entries) {
      await _request(
          'Read ${entry.key}',
          () => _tables.listRows(
                databaseId: databaseId,
                tableId: entry.value,
                queries: [Query.limit(1), Query.select(_select(entry.key))],
              ),
          cancellation);
    }
  }

  @override
  Future<List<McuImportRow>> credits(String table, String movieId, McuImportCancellation cancellation) async {
    final tableId = tableIds[table];
    if (tableId == null || !table.startsWith('movie_')) {
      throw McuImportException('Invalid credit table $table.');
    }
    final result = <McuImportRow>[];
    String? cursor;
    do {
      final page = await _request(
          'Read $table for movie $movieId',
          () => _tables.listRows(
                databaseId: databaseId,
                tableId: tableId,
                queries: [
                  Query.equal('movie.\$id', [movieId]),
                  Query.select(_select(table)),
                  Query.limit(100),
                  if (cursor != null) Query.cursorAfter(cursor),
                ],
              ),
          cancellation);
      cancellation.check();
      for (final row in page.rows) {
        result.add(McuImportRow(table, row.$id, row.data));
      }
      cursor = page.rows.length == 100 ? page.rows.last.$id : null;
    } while (cursor != null);
    return result;
  }

  static String? referenceId(dynamic value) {
    if (value is String) return value;
    if (value is Map && value['\$id'] is String) {
      return value['\$id'] as String;
    }
    return null;
  }

  static List<String> _genreIds(dynamic value) {
    if (value is! List) {
      throw const McuImportException('Movie genres must be a relationship array.');
    }
    final ids = <String>[];
    for (final reference in value) {
      final id = referenceId(reference);
      if (id == null || id.isEmpty) {
        throw const McuImportException('Movie genres contain an invalid reference.');
      }
      ids.add(id);
    }
    return ids;
  }

  static bool _sameGenres(List<String> actual, List<String> expected) {
    final unique = actual.toSet();
    return actual.length == unique.length &&
        actual.length == expected.length &&
        expected.toSet().length == expected.length &&
        expected.every(unique.contains);
  }

  static void verify(McuImportRow row, Map<String, dynamic> stored) {
    for (final entry in row.data.entries) {
      final actual = stored[entry.key];
      final expected = entry.value;
      bool matches;
      if (entry.key == 'movie' || entry.key == 'person') {
        matches = referenceId(actual) == expected;
      } else if (entry.key == 'genres' && expected is List) {
        matches = _sameGenres(_genreIds(actual), _genreIds(expected));
      } else if (expected is List) {
        matches = actual is List &&
            actual.length == expected.length &&
            List.generate(expected.length, (i) => actual[i] == expected[i]).every((value) => value);
      } else if (['release_date', 'birthday', 'deathday'].contains(entry.key) && expected is String) {
        matches = actual is String && DateTime.tryParse(actual) == DateTime.tryParse(expected);
      } else {
        matches = stored.containsKey(entry.key) && actual == expected;
      }
      if (!matches) {
        throw McuImportException('${row.table}/${row.id}.${entry.key}: stored value failed readback verification.');
      }
    }
  }

  Future<void> _writeGenre(McuImportRow row, McuImportCancellation cancellation) async {
    final tableId = tableIds['genres']!;
    final name = row.data['name'];
    if (name is! String || name.trim().isEmpty) {
      throw McuImportException('genres/${row.id}: a nonempty name is required.');
    }
    await _request('Write genres/${row.id}', () async {
      Map<String, dynamic>? existing;
      try {
        final stored = await _tables.getRow(
          databaseId: databaseId,
          tableId: tableId,
          rowId: row.id,
          queries: [
            Query.select(['name'])
          ],
        );
        existing = stored.data;
      } on AppwriteException catch (error) {
        if (error.code != 404 || error.type != 'row_not_found') rethrow;
      }
      cancellation.check();
      if (existing == null) {
        try {
          await _tables.createRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: row.id,
            data: {'name': name},
          );
          return;
        } on AppwriteException catch (error) {
          if (error.code != 409) rethrow;
          final stored = await _tables.getRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: row.id,
            queries: [
              Query.select(['name'])
            ],
          );
          existing = stored.data;
        }
      }
      cancellation.check();
      if (existing['name'] != name) {
        // Genre upserts can replay inverse movie links. Update only the name.
        await _tables.updateRow(
          databaseId: databaseId,
          tableId: tableId,
          rowId: row.id,
          data: {'name': name},
        );
      }
    }, cancellation);
  }

  Future<void> _writeMovie(McuImportRow row, McuImportCancellation cancellation) async {
    final tableId = tableIds['movies']!;
    final desired = _genreIds(row.data['genres']).toSet().toList();
    final payload = Map<String, dynamic>.from(row.data)..['genres'] = desired;
    await _request('Write movies/${row.id}', () async {
      Map<String, dynamic>? existing;
      try {
        final stored = await _tables.getRow(
          databaseId: databaseId,
          tableId: tableId,
          rowId: row.id,
          queries: [
            Query.select(['genres.\$id'])
          ],
        );
        existing = stored.data;
      } on AppwriteException catch (error) {
        if (error.code != 404 || error.type != 'row_not_found') rethrow;
      }
      cancellation.check();
      if (existing == null) {
        try {
          await _tables.createRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: row.id,
            data: payload,
          );
          return;
        } on AppwriteException catch (error) {
          if (error.code != 409) rethrow;
          final stored = await _tables.getRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: row.id,
            queries: [
              Query.select(['genres.\$id'])
            ],
          );
          existing = stored.data;
        }
      }
      final current = _genreIds(existing['genres']);
      final changes = Map<String, dynamic>.from(payload);
      if (_sameGenres(current, desired)) {
        changes.remove('genres');
      } else if (current.length != current.toSet().length) {
        // PATCH retains existing duplicate join rows. Clear only the genre
        // links before restoring the intended set; never delete genre rows.
        await _tables.updateRow(
          databaseId: databaseId,
          tableId: tableId,
          rowId: row.id,
          data: {'genres': <String>[]},
        );
        final cleared = await _tables.getRow(
          databaseId: databaseId,
          tableId: tableId,
          rowId: row.id,
          queries: [
            Query.select(['genres.\$id'])
          ],
        );
        if (_genreIds(cleared.data['genres']).isNotEmpty) {
          throw McuImportException(
              'movies/${row.id}: could not clear duplicate genre links. Retry '
              'with intended genres ${desired.join(", ")}.',
              global: true);
        }
        // Finish restoration even when cancel was requested during clearing.
      }
      await _tables.updateRow(
        databaseId: databaseId,
        tableId: tableId,
        rowId: row.id,
        data: changes,
      );
    }, cancellation);
  }

  @override
  Future<void> upsert(McuImportRow row, McuImportCancellation cancellation) async {
    final tableId = tableIds[row.table];
    if (tableId == null) {
      throw McuImportException('Unknown table ${row.table}.');
    }
    if (row.table.startsWith('movie_')) {
      await _request('Check existing ${row.table}/${row.id}', () async {
        try {
          final existing = await _tables.getRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: row.id,
            queries: [Query.select(_select(row.table))],
          );
          if (referenceId(existing.data['movie']) != row.data['movie'] ||
              referenceId(existing.data['person']) != row.data['person']) {
            throw McuImportException('${row.table}/${row.id}: existing credit references a different '
                'movie or person; refusing to overwrite it.');
          }
        } on AppwriteException catch (error) {
          if (error.code == 404 && error.type == 'row_not_found') return;
          rethrow;
        }
      }, cancellation);
    }
    if (row.table == 'movies') {
      await _writeMovie(row, cancellation);
    } else if (row.table == 'genres') {
      await _writeGenre(row, cancellation);
    } else {
      await _request(
          'Write ${row.table}/${row.id}',
          () => _tables.upsertRow(
                databaseId: databaseId,
                tableId: tableId,
                rowId: row.id,
                data: row.data,
              ),
          cancellation);
    }
    // A cancelled run keeps the completed write, but does not start a new read.
    cancellation.check();
    final stored = await _request(
        'Verify ${row.table}/${row.id}',
        () => _tables.getRow(
              databaseId: databaseId,
              tableId: tableId,
              rowId: row.id,
              queries: [Query.select(_select(row.table))],
            ),
        cancellation);
    verify(row, stored.data);
  }
}
