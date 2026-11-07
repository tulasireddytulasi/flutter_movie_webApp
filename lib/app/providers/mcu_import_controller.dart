import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:moviewebapp/app/core/repository/json_objects/marvel_movies_json.dart';
import 'package:moviewebapp/app/core/responses/appwrite_mcu_import_service.dart';
import 'package:moviewebapp/app/core/responses/tmdb_mcu_import_service.dart';
import 'package:moviewebapp/app/models/mcu_import_models.dart';

enum McuMovieImportStatus { complete, failed, partial, cancelled }

class McuMovieImportResult {
  const McuMovieImportResult(this.movie, this.status, this.message);

  final McuSeedMovie movie;
  final McuMovieImportStatus status;
  final String message;
}

class McuImportController extends ChangeNotifier {
  McuImportController({
    McuTmdbSource? source,
    McuImportStore? store,
    List<McuSeedMovie>? movies,
  })  : _source = source ?? TmdbMcuImportService(),
        _store = store ?? AppwriteMcuImportService(),
        movies = movies ?? McuImportMapper.seeds(MoviesRepo.marvelMovies);

  final McuTmdbSource _source;
  final McuImportStore _store;
  final List<McuSeedMovie> movies;
  final Set<String> selectedIds = {};
  final Map<String, McuMovieImportResult> results = {};
  final List<String> warnings = [];
  final Map<String, int> writes = {};
  final Map<String, McuImportRow> _people = {};
  final Set<String> _writtenPeople = {};
  final Set<String> _knownPeople = {};
  final Set<String> _existingPeople = {};
  McuImportCancellation? _cancellation;
  bool busy = false;
  bool _disposed = false;
  String stage = 'Select movies to import.';
  String? error;
  int processed = 0;
  int total = 0;

  int get peopleFetched => _people.length;

  int get peopleKnown => _knownPeople.length;

  int get peopleReused => _existingPeople.length;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void select(String id, bool value) {
    if (busy) return;
    value ? selectedIds.add(id) : selectedIds.remove(id);
    _notify();
  }

  void selectAll(bool value) {
    if (busy) return;
    selectedIds.clear();
    if (value) selectedIds.addAll(movies.map((movie) => movie.id));
    _notify();
  }

  Set<String> get retryIds => results.entries
      .where((entry) => entry.value.status != McuMovieImportStatus.complete)
      .map((entry) => entry.key)
      .toSet();

  void cancel() {
    _cancellation?.requested = true;
    stage = 'Cancelling after in-flight operations finish; completed rows are kept.';
    _notify();
  }

  void _stage(String value, McuImportCancellation cancellation) {
    cancellation.check();
    stage = value;
    _notify();
  }

  Future<void> _profiles(Set<String> ids, McuImportMapper mapper, McuImportCancellation cancellation) async {
    _knownPeople.addAll(ids);
    final missing = ids.where((id) => !_existingPeople.contains(id)).toList();
    var next = 0;
    Object? failure;
    Future<void> worker() async {
      while (next < missing.length && failure == null && !cancellation.requested) {
        final id = missing[next++];
        try {
          if (await _store.personExists(id, cancellation)) {
            _existingPeople.add(id);
            _notify();
            continue;
          }
          if (_people.containsKey(id)) continue;
          final data = await _source.person(id, cancellation);
          cancellation.check();
          _people[id] = mapper.person(data, id);
          _notify();
        } on Exception catch (e) {
          failure ??= e;
        }
      }
    }

    // Settle all workers before continuing or closing the HTTP client.
    await Future.wait(List.generate(math.min(3, missing.length), (_) => worker()));
    cancellation.check();
    if (failure != null) {
      if (failure is McuImportException) throw failure!;
      throw McuImportException('Person enrichment failed: $failure');
    }
  }

  void _checkLegacy(List<McuImportRow> stored, List<McuImportRow> incoming) {
    AppwriteMcuImportService.checkExistingCredits(stored, incoming, warnings);
  }

  Future<void> _write(McuImportRow row, McuImportCancellation cancellation) async {
    cancellation.check();
    await _store.upsert(row, cancellation);
    writes.update(row.table, (value) => value + 1, ifAbsent: () => 1);
    _notify();
  }

  Future<void> run({
    Set<String>? ids,
    McuImportOptions options = const McuImportOptions(),
  }) async {
    if (busy || _disposed) return;
    try {
      options.validate();
    } on McuImportException catch (e) {
      error = e.message;
      _notify();
      return;
    }
    final requested = Set<String>.of(ids ?? selectedIds);
    final selected = movies.where((movie) => requested.contains(movie.id)).toList();
    if (selected.isEmpty) {
      error = 'Select at least one MCU movie.';
      _notify();
      return;
    }
    final cancellation = McuImportCancellation();
    _cancellation = cancellation;
    busy = true;
    error = null;
    processed = 0;
    total = selected.length;
    warnings.clear();
    writes.clear();
    _writtenPeople.clear();
    _existingPeople.clear();
    _knownPeople.clear();
    _people.clear();
    for (final movie in selected) {
      results.remove(movie.id);
    }
    _notify();
    try {
      _stage('Checking anonymous Appwrite access...', cancellation);
      await _store.preflight(cancellation);
      final mapper = McuImportMapper(warnings);
      for (final movie in selected) {
        var startedWriting = false;
        try {
          _stage('${movie.title}: fetching TMDB details and complete credits...', cancellation);
          final bundle = mapper.movie(await _source.movie(movie.id, cancellation), movie.id, options: options);
          _stage('${movie.title}: checking existing credits...', cancellation);
          _checkLegacy(await _store.credits('movie_cast', movie.id, cancellation), bundle.cast);
          _checkLegacy(await _store.credits('movie_crew', movie.id, cancellation), bundle.crew);
          _stage(
              '${movie.title}: checking ${bundle.personIds.length} people; fetching missing profiles...', cancellation);
          await _profiles(bundle.personIds, mapper, cancellation);
          _stage('${movie.title}: uploading genres and people...', cancellation);
          for (final row in bundle.genres) {
            cancellation.check();
            startedWriting = true;
            await _write(row, cancellation);
          }
          for (final id in bundle.personIds) {
            if (_writtenPeople.contains(id) || _existingPeople.contains(id)) {
              continue;
            }
            cancellation.check();
            startedWriting = true;
            final created = await _store.createPersonIfMissing(_people[id]!, cancellation);
            if (created) {
              writes.update('people', (value) => value + 1, ifAbsent: () => 1);
            } else {
              _existingPeople.add(id);
            }
            _writtenPeople.add(id);
            _notify();
          }
          _stage('${movie.title}: uploading movie with franchise=${options.normalizedFranchise ?? "null"}...',
              cancellation);
          startedWriting = true;
          await _write(bundle.movie, cancellation);
          _stage('${movie.title}: uploading and verifying cast and crew...', cancellation);
          for (final row in [...bundle.cast, ...bundle.crew]) {
            await _write(row, cancellation);
          }
          results[movie.id] = McuMovieImportResult(
              movie,
              McuMovieImportStatus.complete,
              'Verified movie, ${bundle.genres.length} genres, '
              '${bundle.personIds.length} people, ${bundle.cast.length} cast, '
              '${bundle.crew.length} crew credits; '
              'franchise=${options.normalizedFranchise ?? "null"}.');
        } on McuImportCancelled {
          results[movie.id] = McuMovieImportResult(
              movie,
              startedWriting ? McuMovieImportStatus.partial : McuMovieImportStatus.cancelled,
              startedWriting ? 'Cancelled; some rows may be stored. Retry safely.' : 'Cancelled before writes.');
          rethrow;
        } on Exception catch (e) {
          final message = e is McuImportException ? e.message : 'Unexpected import error: $e';
          results[movie.id] = McuMovieImportResult(
              movie, startedWriting ? McuMovieImportStatus.partial : McuMovieImportStatus.failed, message);
          if (e is McuImportException && e.global) rethrow;
        }
        processed++;
        _notify();
      }
      stage = 'Finished: ${selected.where((m) => results[m.id]?.status == McuMovieImportStatus.complete).length}'
          ' of $total selected movies fully verified.';
    } on McuImportCancelled {
      stage = 'Cancelled. Completed rows kept; unfinished movies can be retried.';
    } on Exception catch (e) {
      error = 'Import stopped: $e';
      stage = 'Stopped. Check setup/permissions before retrying.';
    } finally {
      for (final movie in selected) {
        results.putIfAbsent(
            movie.id,
            () => McuMovieImportResult(
                movie, McuMovieImportStatus.cancelled, 'Not attempted; retry after resolving the stop.'));
      }
      busy = false;
      _cancellation = null;
      _notify();
      if (_disposed) _source.close();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cancellation?.requested = true;
    if (!busy) _source.close();
    super.dispose();
  }
}
