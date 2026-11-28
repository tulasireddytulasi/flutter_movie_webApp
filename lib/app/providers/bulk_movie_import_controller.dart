import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:moviewebapp/app/core/responses/appwrite_mcu_import_service.dart';
import 'package:moviewebapp/app/core/responses/tmdb_mcu_import_service.dart';
import 'package:moviewebapp/app/models/bulk_movie_import_models.dart';
import 'package:moviewebapp/app/models/mcu_import_models.dart';
import 'package:moviewebapp/app/models/movie_editor_models.dart';

class BulkMovieImportController extends ChangeNotifier {
  BulkMovieImportController({McuTmdbSource? source, McuImportStore? store})
      : _source = source ?? TmdbMcuImportService(),
        _store = store ?? AppwriteMcuImportService();

  static const parallelMovies = 3;
  static const parallelPeople = 15;
  final McuTmdbSource _source;
  final McuImportStore _store;
  final List<BulkMovieEntry> movies = [];
  final Map<String, Future<_BulkProfileResult>> _profiles = {};
  final Map<String, Future<void>> _genres = {};
  final _peoplePool = _BulkUploadPool(parallelPeople);
  McuImportCancellation? _cancellation;
  McuImportException? _globalFailure;
  bool _disposed = false;
  bool busy = false;
  String? error;
  String message = 'Paste TMDB movie IDs to build a batch.';
  int completed = 0;
  int total = 0;

  bool get hasFetchFailures => movies.any((movie) => movie.data == null);
  bool get hasUploadFailures => movies.any((movie) =>
      movie.selected &&
      movie.data != null &&
      (movie.status == BulkMovieStatus.failed || movie.status == BulkMovieStatus.partial));
  int get uploadCount =>
      movies.where((movie) => movie.selected && movie.data != null && movie.status != BulkMovieStatus.success).length;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  McuImportCancellation _begin(int count, String stage) {
    busy = true;
    error = null;
    _globalFailure = null;
    completed = 0;
    total = count;
    message = stage;
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

  void _check(McuImportCancellation token) {
    token.check();
    final failure = _globalFailure;
    if (failure != null) throw failure;
  }

  void _failure(BulkMovieEntry movie, Object failure) {
    if (failure is McuImportException && failure.global) {
      _globalFailure ??= failure;
      error = 'Batch paused: $failure. Resolve the issue, then retry unfinished work.';
    }
    movie.status = movie.hasWrites ? BulkMovieStatus.partial : BulkMovieStatus.failed;
    movie.message =
        failure is McuImportCancelled ? 'Cancelled; completed rows were kept. Retry unfinished work.' : '$failure';
  }

  void select(BulkMovieEntry movie, bool value) {
    if (busy) return;
    movie.selected = value;
    _notify();
  }

  void selectAll(bool value) {
    if (busy) return;
    for (final movie in movies) {
      movie.selected = value;
    }
    _notify();
  }

  void remove(BulkMovieEntry movie) {
    if (busy) return;
    movies.remove(movie);
    _notify();
  }

  void clear() {
    if (busy) return;
    movies.clear();
    _profiles.clear();
    _genres.clear();
    completed = 0;
    total = 0;
    error = null;
    message = 'Review queue cleared. Fetch movie details to build a new batch.';
    _notify();
  }

  void edit(BulkMovieEntry movie, Map<String, dynamic> data, BulkMovieSettings? settings) {
    if (busy) return;
    movie.data = data;
    movie.overrideSettings = settings;
    movie.resetUpload();
    _notify();
  }

  Future<void> fetch(String input, {bool retry = false}) async {
    if (busy || _disposed) return;
    List<BulkMovieEntry> queue;
    if (retry) {
      queue = movies.where((movie) => movie.data == null).toList();
    } else {
      final parts = input.split(RegExp(r'[\s,;]+')).where((part) => part.isNotEmpty).toList();
      if (parts.isEmpty) {
        error = 'Enter at least one TMDB movie ID.';
        _notify();
        return;
      }
      final ids = <String>{};
      for (final part in parts) {
        final number = int.tryParse(part);
        if (!RegExp(r'^\d+$').hasMatch(part) || number == null || number <= 0 || number > 9007199254740991) {
          error = 'Invalid movie ID "$part". Use positive IDs separated by commas or newlines.';
          _notify();
          return;
        }
        ids.add(number.toString());
      }
      final known = movies.map((movie) => movie.id).toSet();
      for (final id in ids.difference(known)) {
        movies.add(BulkMovieEntry(id));
      }
      queue = movies.where((movie) => ids.contains(movie.id) && movie.data == null).toList();
    }
    if (queue.isEmpty) {
      error = null;
      message = 'These movies are already fetched; existing edits and results were kept.';
      _notify();
      return;
    }
    final token = _begin(queue.length, 'Fetching up to $parallelMovies movies concurrently...');
    var next = 0;
    Future<void> worker() async {
      while (next < queue.length && !token.requested && _globalFailure == null) {
        final movie = queue[next++];
        movie.status = BulkMovieStatus.fetching;
        movie.message = 'Fetching TMDB details and credits...';
        _notify();
        try {
          final data = await _source.movie(movie.id, token);
          _check(token);
          McuImportMapper([]).movie(data, movie.id, options: const McuImportOptions(castLimit: 0, crewLimit: 0));
          movie.data = data;
          movie.status = BulkMovieStatus.ready;
          movie.message = 'Fetched. Review or edit before uploading.';
        } on Exception catch (failure) {
          _failure(movie, failure);
        } finally {
          completed++;
          _notify();
        }
      }
    }

    try {
      await Future.wait(List.generate(math.min(parallelMovies, queue.length), (_) => worker()));
      for (final movie in queue.where((movie) => movie.status == BulkMovieStatus.queued)) {
        _failure(movie, _globalFailure ?? const McuImportCancelled());
      }
      final ready = queue.where((movie) => movie.data != null).length;
      message = 'Fetched $ready of ${queue.length} movies. Retry failed fetches without losing edits.';
    } finally {
      _finish();
    }
  }

  Future<_BulkProfileResult> _profile(String id, McuImportCancellation token) {
    return _profiles.putIfAbsent(id, () async {
      _check(token);
      if (await _store.personExists(id, token)) return const _BulkProfileResult(true, []);
      _check(token);
      final data = await _source.person(id, token);
      final warnings = <String>[];
      final row = McuImportMapper(warnings).person(data, id);
      _check(token);
      final created = await _store.createPersonIfMissing(row, token);
      return _BulkProfileResult(!created, warnings);
    });
  }

  Future<void> _genre(McuImportRow row, McuImportCancellation token) {
    // Include the name so edited genre names are not hidden by batch reuse.
    final key = '${row.id}:${row.data['name']}';
    return _genres.putIfAbsent(key, () => _store.upsert(row, token));
  }

  void _prepare(BulkMovieEntry movie, BulkMovieSettings settings) {
    if (movie.bundle != null) return;
    settings.options.validate();
    final data = movie.data;
    if (data == null) throw const McuImportException('Fetch this movie before uploading.');
    final bundle = McuImportMapper(movie.warnings).movie(data, movie.id, options: settings.mappingOptions);
    bundle.movie.data.addAll(settings.movieAttributes);
    final credits = McuImportMapper.object(data['credits'], 'Movie credits');
    for (final kind in ['cast', 'crew']) {
      for (final value in McuImportMapper.array(credits[kind], '$kind credits')) {
        final credit = McuImportMapper.object(value, '$kind credit');
        final id = McuImportMapper.entityId(credit['id'], '$kind person');
        final name = credit['name'];
        movie.peopleNames[id] = name is String ? name : 'Person $id';
      }
    }
    for (final id in bundle.personIds) {
      movie.peopleResults[id] = const PersonUploadResult(PersonUploadStatus.pending, 'Queued');
    }
    movie.bundle = bundle;
    movie.uploadSettings = settings;
  }

  Future<void> _uploadMovie(BulkMovieEntry movie, McuImportCancellation token) async {
    final bundle = movie.bundle!;
    final byPerson = <String, List<McuImportRow>>{};
    for (final row in [...bundle.cast, ...bundle.crew]) {
      final id = row.data['person'] as String;
      byPerson.putIfAbsent(id, () => []).add(row);
    }
    _check(token);
    if (bundle.cast.isNotEmpty) {
      AppwriteMcuImportService.checkExistingCredits(
          await _store.credits('movie_cast', movie.id, token), bundle.cast, movie.warnings);
    }
    _check(token);
    if (bundle.crew.isNotEmpty) {
      AppwriteMcuImportService.checkExistingCredits(
          await _store.credits('movie_crew', movie.id, token), bundle.crew, movie.warnings);
    }
    for (final genre in bundle.genres) {
      _check(token);
      if (movie.verifiedGenres.contains(genre.id)) continue;
      await _genre(genre, token);
      movie.verifiedGenres.add(genre.id);
    }
    _check(token);
    if (!movie.movieVerified) {
      await _store.upsert(bundle.movie, token);
      movie.movieVerified = true;
    }
    movie.message = 'Movie and genres verified. Uploading selected people and credits...';
    _notify();
    await Future.wait(byPerson.entries.map((entry) async {
      final current = movie.peopleResults[entry.key]?.status;
      if (current == PersonUploadStatus.success || current == PersonUploadStatus.alreadyExists) return;
      try {
        await _peoplePool.run(() async {
          _check(token);
          movie.peopleResults[entry.key] =
              const PersonUploadResult(PersonUploadStatus.uploading, 'Checking profile and uploading credits...');
          _notify();
          final profile = await _profile(entry.key, token);
          movie.warnings.addAll(profile.warnings);
          for (final row in entry.value) {
            _check(token);
            final key = '${row.table}/${row.id}';
            if (movie.verifiedCredits.contains(key)) continue;
            await _store.upsert(row, token);
            movie.verifiedCredits.add(key);
          }
          movie.peopleResults[entry.key] = PersonUploadResult(
              profile.existed ? PersonUploadStatus.alreadyExists : PersonUploadStatus.success,
              '${profile.existed ? "Existing profile reused" : "Profile created/reused in this batch"}; '
              '${entry.value.length} credits verified.');
        });
      } on Exception catch (failure) {
        if (failure is McuImportException && failure.global) {
          _globalFailure ??= failure;
          error = 'Batch paused: $failure. Retry after resolving the issue.';
        }
        movie.peopleResults[entry.key] = PersonUploadResult(PersonUploadStatus.failed,
            failure is McuImportCancelled ? 'Cancelled; retry unfinished credits.' : '$failure');
      } finally {
        _notify();
      }
    }));
    final failed = movie.peopleResults.values.where((result) => result.status == PersonUploadStatus.failed).length;
    movie.status = failed == 0 ? BulkMovieStatus.success : BulkMovieStatus.partial;
    movie.message = failed == 0
        ? 'Verified movie, ${bundle.genres.length} genres, ${byPerson.length} people and '
            '${bundle.cast.length + bundle.crew.length} credits.'
        : 'Movie verified; $failed people have unfinished uploads. Retry only unfinished work.';
  }

  Future<void> upload(BulkMovieSettings settings, {bool retry = false}) async {
    if (busy || _disposed) return;
    final queue = movies
        .where((movie) =>
            movie.selected &&
            movie.data != null &&
            (retry
                ? movie.status == BulkMovieStatus.failed || movie.status == BulkMovieStatus.partial
                : movie.status != BulkMovieStatus.success))
        .toList();
    if (queue.isEmpty) {
      error = 'Select fetched movies with unfinished uploads.';
      _notify();
      return;
    }
    try {
      settings.options.validate();
    } on McuImportException catch (failure) {
      error = failure.message;
      _notify();
      return;
    }
    _profiles.clear();
    _genres.clear();
    final token = _begin(queue.length, 'Checking anonymous Appwrite access...');
    for (final movie in queue) {
      movie.status = BulkMovieStatus.queued;
      movie.message = 'Queued. Retries retain the original upload data and settings.';
    }
    final runnable = <BulkMovieEntry>[];
    var next = 0;
    Future<void> worker() async {
      while (next < runnable.length && !token.requested && _globalFailure == null) {
        final movie = runnable[next++];
        movie.status = BulkMovieStatus.uploading;
        _notify();
        try {
          await _uploadMovie(movie, token);
        } on Exception catch (failure) {
          _failure(movie, failure);
        } finally {
          completed++;
          _notify();
        }
      }
    }

    try {
      final genreNames = <String, String>{};
      for (final movie in queue) {
        try {
          final effective = movie.overrideSettings ?? settings;
          _prepare(
              movie,
              BulkMovieSettings(
                options: effective.options,
                includePeople: effective.includePeople,
                movieAttributes: settings.movieAttributes,
              ));
          runnable.add(movie);
        } on McuImportException catch (failure) {
          _failure(movie, failure);
          completed++;
        }
      }
      for (final movie in runnable) {
        for (final genre in movie.bundle!.genres) {
          final name = genre.data['name'] as String;
          final previous = genreNames[genre.id];
          if (previous != null && previous != name) {
            throw McuImportException('Genre ${genre.id} has conflicting names "$previous" and "$name" in this batch. '
                'Edit the movies to use one name, then retry. No batch writes were started.');
          }
          genreNames[genre.id] = name;
        }
      }
      if (runnable.isEmpty) return;
      await _store.preflight(token);
      message = 'Uploading up to $parallelMovies movies with one shared $parallelPeople-person pool...';
      _notify();
      await Future.wait(List.generate(math.min(parallelMovies, runnable.length), (_) => worker()));
    } on Exception catch (failure) {
      if (failure is McuImportException && failure.global) _globalFailure = failure;
      error = 'Could not complete batch: $failure';
    } finally {
      for (final movie in queue.where((movie) => movie.status == BulkMovieStatus.queued)) {
        _failure(movie, _globalFailure ?? McuImportException(error ?? 'Cancelled before upload.'));
      }
      final success = queue.where((movie) => movie.status == BulkMovieStatus.success).length;
      message = '$success of ${queue.length} movies verified. Completed work is retained for retries '
          'while this screen stays open.';
      _finish();
    }
  }

  void cancel() {
    _cancellation?.requested = true;
    message = 'Cancelling; in-flight requests finish and completed rows are kept.';
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

class _BulkProfileResult {
  const _BulkProfileResult(this.existed, this.warnings);
  final bool existed;
  final List<String> warnings;
}

class _BulkUploadPool {
  _BulkUploadPool(this.limit);
  final int limit;
  int _active = 0;
  final Queue<Completer<void>> _waiting = Queue<Completer<void>>();

  Future<void> run(Future<void> Function() operation) async {
    if (_active < limit) {
      _active++;
    } else {
      final ready = Completer<void>();
      _waiting.add(ready);
      await ready.future;
    }
    try {
      await operation();
    } finally {
      // Hand the occupied slot directly to a waiter; do not increment again.
      if (_waiting.isEmpty) {
        _active--;
      } else {
        _waiting.removeFirst().complete();
      }
    }
  }
}
