import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:moviewebapp/app/core/responses/appwrite_mcu_import_service.dart';
import 'package:moviewebapp/app/core/responses/tmdb_mcu_import_service.dart';
import 'package:moviewebapp/app/models/mcu_import_models.dart';
import 'package:moviewebapp/app/models/movie_editor_models.dart';

class MovieEditorController extends ChangeNotifier {
  MovieEditorController({McuTmdbSource? source, McuImportStore? store})
      : _source = source ?? TmdbMcuImportService(),
        _store = store ?? AppwriteMcuImportService();

  static const parallelUploads = 15;
  final McuTmdbSource _source;
  final McuImportStore _store;
  Map<String, dynamic>? _movie;
  final Map<String, Map<String, List<Map<String, dynamic>>>> _creditsByPerson = {};
  List<MovieCreditPerson> cast = [];
  List<MovieCreditPerson> crew = [];
  final Set<String> selectedCast = {};
  final Set<String> selectedCrew = {};
  final Map<String, PersonUploadResult> peopleResults = {};
  final Map<String, List<String>> _personWarnings = {};
  List<String> movieWarnings = [];
  String? error;
  String? movieMessage;
  String peopleMessage = 'Select people after fetching a movie.';
  bool busy = false;
  bool _disposed = false;
  McuImportCancellation? _cancellation;
  int completedPeople = 0;
  int totalPeople = 0;

  String? get movieId => _movie == null ? null : _movie!['id'].toString();

  Map<String, dynamic> get movieData => Map.unmodifiable(_movie ?? {});

  bool get hasMovie => _movie != null;

  List<String> get peopleWarnings => _personWarnings.values.expand((items) => items).toList();

  Set<String> get selectedPeople => {...selectedCast, ...selectedCrew};

  Set<String> get failedPeople => peopleResults.entries
      .where((entry) => entry.value.status == PersonUploadStatus.failed)
      .map((entry) => entry.key)
      .toSet();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  McuImportCancellation _begin() {
    busy = true;
    error = null;
    final token = McuImportCancellation();
    _cancellation = token;
    _notify();
    return token;
  }

  void _finish() {
    busy = false;
    _cancellation = null;
    _notify();
    if (_disposed) _source.close();
  }

  List<MovieCreditPerson> _people(List<Map<String, dynamic>> rows, String kind) {
    final people = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final id = McuImportMapper.entityId(row['id'], '$kind person');
      people.putIfAbsent(id, () => []).add(row);
    }
    return people.entries.map((entry) {
      final name = entry.value.first['name'];
      if (name is! String || name.trim().isEmpty) {
        throw McuImportException('$kind person ${entry.key}: missing name.');
      }
      final details = entry.value
          .map((row) => kind == 'cast'
              ? '${row['character'] ?? "Unspecified role"}'
              : '${row['department'] ?? "Unknown department"}: ${row['job'] ?? "Unknown job"}')
          .toSet()
          .join(', ');
      return MovieCreditPerson(id: entry.key, name: name, details: details);
    }).toList();
  }

  Future<bool> fetchMovie(String input) async {
    if (busy || _disposed) return false;
    final id = int.tryParse(input.trim());
    if (id == null || id <= 0 || id > 9007199254740991) {
      error = 'Enter a positive TMDB movie ID.';
      _notify();
      return false;
    }
    final token = _begin();
    try {
      final data = await _source.movie(id.toString(), token);
      token.check();
      if (McuImportMapper.entityId(data['id'], 'Movie response') != id.toString()) {
        throw const McuImportException('TMDB returned the wrong movie ID.');
      }
      final credits = McuImportMapper.object(data['credits'], 'Movie credits');
      final castRows = McuImportMapper.array(credits['cast'], 'Cast')
          .map((row) => McuImportMapper.object(row, 'Cast credit'))
          .toList();
      final crewRows = McuImportMapper.array(credits['crew'], 'Crew')
          .map((row) => McuImportMapper.object(row, 'Crew credit'))
          .toList();
      final indexed = castRows.asMap().entries.toList();
      for (final entry in indexed) {
        final order = entry.value['order'];
        if (order is! int || order < 0) {
          throw const McuImportException('Cast credit has an invalid order.');
        }
      }
      indexed.sort((a, b) {
        final comparison = (a.value['order'] as int).compareTo(b.value['order'] as int);
        return comparison == 0 ? a.key.compareTo(b.key) : comparison;
      });
      final sortedCast = indexed.map((entry) => entry.value).toList();
      final castPeople = _people(sortedCast, 'cast');
      final crewPeople = _people(crewRows, 'crew');
      _movie = data;
      _creditsByPerson['cast'] = _groupCredits(sortedCast);
      _creditsByPerson['crew'] = _groupCredits(crewRows);
      cast = castPeople;
      crew = crewPeople;
      selectedCast.clear();
      selectedCrew.clear();
      peopleResults.clear();
      _personWarnings.clear();
      movieWarnings = [];
      movieMessage = 'Fetched TMDB movie $id. Edit the fields, then upload the movie separately.';
      peopleMessage = '${cast.length} unique cast and ${crew.length} unique crew people available.';
      completedPeople = 0;
      totalPeople = 0;
      return true;
    } on McuImportCancelled {
      error = 'Fetch cancelled.';
      return false;
    } on Exception catch (e) {
      error = 'Could not fetch movie: $e';
      return false;
    } finally {
      _finish();
    }
  }

  void selectPerson(String kind, String id, bool selected) {
    if (busy) return;
    final selection = kind == 'cast' ? selectedCast : selectedCrew;
    selected ? selection.add(id) : selection.remove(id);
    // Selection changes add/remove roles, so a previous successful result is no
    // longer a guarantee that all newly selected credits have been uploaded.
    if (peopleResults[id]?.status != PersonUploadStatus.failed) {
      peopleResults.remove(id);
    }
    _notify();
  }

  bool selectFirst(String kind, String count) {
    if (busy) return false;
    final number = int.tryParse(count.trim());
    if (number == null || number < 0) {
      error = 'Enter a non-negative whole number for $kind people.';
      _notify();
      return false;
    }
    error = null;
    final people = kind == 'cast' ? cast : crew;
    final selection = kind == 'cast' ? selectedCast : selectedCrew;
    final affected = {...selection, ...people.take(number).map((person) => person.id)};
    selection
      ..clear()
      ..addAll(people.take(number).map((person) => person.id));
    for (final id in affected) {
      if (peopleResults[id]?.status != PersonUploadStatus.failed) {
        peopleResults.remove(id);
      }
    }
    _notify();
    return true;
  }

  Future<void> uploadMovie(Map<String, String> fields) async {
    if (busy || _disposed || _movie == null) return;
    final token = _begin();
    movieMessage = null;
    movieWarnings = [];
    try {
      final edited = Map<String, dynamic>.from(_movie!);
      for (final field in movieEditorFields) {
        if (!fields.containsKey(field.key)) {
          throw McuImportException('Missing editor field ${field.label}.');
        }
        edited[field.key] = field.parse(fields[field.key]!);
      }
      final franchise = edited['franchise'];
      final bundle = McuImportMapper(movieWarnings).movie(
        edited,
        movieId!,
        options: McuImportOptions(castLimit: 0, crewLimit: 0, franchise: franchise is String ? franchise : null),
      );
      for (final genre in bundle.genres) {
        token.check();
        await _store.upsert(genre, token);
      }
      token.check();
      await _store.upsert(bundle.movie, token);
      movieMessage = 'Success: movie $movieId and ${bundle.genres.length} genres verified. '
          'No people or credits were uploaded by this tab.';
    } on McuImportCancelled {
      error = 'Movie upload cancelled; completed rows were kept.';
    } on Exception catch (e) {
      error = 'Movie upload failed (some genre/movie rows may be stored): $e';
    } finally {
      _finish();
    }
  }

  List<McuImportRow> _personCredits(String id, List<String> warnings) {
    final mapper = McuImportMapper(warnings);
    return [
      if (selectedCast.contains(id)) ...mapper.creditRows(_creditsByPerson['cast']![id]!, movieId!, 'cast', limit: 1),
      if (selectedCrew.contains(id)) ...mapper.creditRows(_creditsByPerson['crew']![id]!, movieId!, 'crew', limit: 1),
    ];
  }

  Map<String, List<Map<String, dynamic>>> _groupCredits(List<Map<String, dynamic>> credits) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final credit in credits) {
      final id = McuImportMapper.entityId(credit['id'], 'Credit person');
      grouped.putIfAbsent(id, () => []).add(credit);
    }
    return grouped;
  }

  Map<String, List<McuImportRow>> _groupStoredCredits(List<McuImportRow> credits) {
    final grouped = <String, List<McuImportRow>>{};
    for (final credit in credits) {
      final id = AppwriteMcuImportService.referenceId(credit.data['person']);
      if (id != null) grouped.putIfAbsent(id, () => []).add(credit);
    }
    return grouped;
  }

  Future<void> uploadPeople({bool retryFailed = false}) async {
    if (busy || _disposed || _movie == null) return;
    final ids = (retryFailed ? selectedPeople.intersection(failedPeople) : selectedPeople).toList();
    if (ids.isEmpty) {
      error = retryFailed ? 'Select failed people to retry.' : 'Select at least one cast or crew person.';
      _notify();
      return;
    }
    final token = _begin();
    completedPeople = 0;
    totalPeople = ids.length;
    for (final id in ids) {
      peopleResults[id] = const PersonUploadResult(PersonUploadStatus.pending, 'Queued');
      _personWarnings.remove(id);
    }
    final planned = <String, List<McuImportRow>>{};
    Object? globalFailure;
    try {
      if (!await _store.movieExists(movieId!, token)) {
        throw const McuImportException('Upload the movie in Movie Info first. It does not exist in Appwrite.');
      }
      // Check legacy credits once per table, rather than querying inside each worker.
      final storedCast = selectedCast.intersection(ids.toSet()).isEmpty
          ? <McuImportRow>[]
          : await _store.credits('movie_cast', movieId!, token);
      final storedCrew = selectedCrew.intersection(ids.toSet()).isEmpty
          ? <McuImportRow>[]
          : await _store.credits('movie_crew', movieId!, token);
      final castByPerson = _groupStoredCredits(storedCast);
      final crewByPerson = _groupStoredCredits(storedCrew);
      for (final id in ids) {
        token.check();
        final warnings = <String>[];
        _personWarnings[id] = warnings;
        try {
          final credits = _personCredits(id, warnings);
          AppwriteMcuImportService.checkExistingCredits(
              castByPerson[id] ?? [], credits.where((row) => row.table == 'movie_cast').toList(), warnings);
          AppwriteMcuImportService.checkExistingCredits(
              crewByPerson[id] ?? [], credits.where((row) => row.table == 'movie_crew').toList(), warnings);
          planned[id] = credits;
          peopleResults[id] = const PersonUploadResult(PersonUploadStatus.pending, 'Queued');
        } on McuImportException catch (e) {
          peopleResults[id] = PersonUploadResult(PersonUploadStatus.failed, e.message);
          completedPeople++;
        }
      }
      final queue = planned.keys.toList();
      var next = 0;
      Future<void> worker() async {
        while (next < queue.length && !token.requested && globalFailure == null) {
          final id = queue[next++];
          peopleResults[id] = const PersonUploadResult(
              PersonUploadStatus.uploading, 'Checking profile, then uploading selected credits...');
          _notify();
          try {
            var exists = await _store.personExists(id, token);
            token.check();
            if (!exists) {
              final profile = await _source.person(id, token);
              token.check();
              final row = McuImportMapper(_personWarnings[id]!).person(profile, id);
              exists = !await _store.createPersonIfMissing(row, token);
            }
            for (final credit in planned[id]!) {
              token.check();
              await _store.upsert(credit, token);
            }
            peopleResults[id] = PersonUploadResult(
                exists ? PersonUploadStatus.alreadyExists : PersonUploadStatus.success,
                '${exists ? "Existing profile kept" : "Profile created and verified"}; '
                '${planned[id]!.length} selected credits verified.');
          } on McuImportCancelled {
            peopleResults[id] = const PersonUploadResult(
                PersonUploadStatus.failed, 'Cancelled; some profile/credit rows may be stored. Retry safely.');
          } on Exception catch (e) {
            peopleResults[id] =
                PersonUploadResult(PersonUploadStatus.failed, 'Upload failed; some rows may be stored: $e');
            if (e is McuImportException && e.global) globalFailure ??= e;
          } finally {
            completedPeople++;
            _notify();
          }
        }
      }

      peopleMessage = 'Uploading up to $parallelUploads people in parallel...';
      _notify();
      await Future.wait(List.generate(math.min(parallelUploads, queue.length), (_) => worker()));
      if (globalFailure != null) error = 'Uploads stopped: $globalFailure';
      for (final id in ids) {
        if (peopleResults[id]?.status == PersonUploadStatus.pending) {
          peopleResults[id] = PersonUploadResult(
              PersonUploadStatus.failed,
              token.requested
                  ? 'Cancelled before upload; retry available.'
                  : 'Not attempted after a global failure; retry available.');
        }
      }
      final success = ids
          .where((id) =>
              peopleResults[id]?.status == PersonUploadStatus.success ||
              peopleResults[id]?.status == PersonUploadStatus.alreadyExists)
          .length;
      peopleMessage = '$success of ${ids.length} people and their selected credits verified. '
          'Failed people can be retried independently.';
    } on McuImportCancelled {
      error = 'People upload cancelled; completed rows were kept.';
      peopleMessage = 'Cancelled. Retry unfinished people to repair partial uploads.';
      for (final id in ids) {
        if (peopleResults[id]?.status == PersonUploadStatus.pending ||
            peopleResults[id]?.status == PersonUploadStatus.uploading) {
          peopleResults[id] = const PersonUploadResult(
              PersonUploadStatus.failed, 'Cancelled; some rows may be stored. Retry available.');
        }
      }
    } on Exception catch (e) {
      error = 'Could not start people uploads: $e';
      for (final id in ids) {
        peopleResults[id] = PersonUploadResult(PersonUploadStatus.failed, '$e');
      }
    } finally {
      _finish();
    }
  }

  void cancel() {
    _cancellation?.requested = true;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancellation?.requested = true;
    if (!busy) _source.close();
    super.dispose();
  }
}
