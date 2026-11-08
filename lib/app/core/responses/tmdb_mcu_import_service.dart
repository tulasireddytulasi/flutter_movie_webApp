import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/models/mcu_import_models.dart';

abstract class McuTmdbSource {
  Future<Map<String, dynamic>> movie(
      String id, McuImportCancellation cancellation);
  Future<Map<String, dynamic>> person(
      String id, McuImportCancellation cancellation);
  void close();
}

class TmdbMcuImportService implements McuTmdbSource {
  TmdbMcuImportService({
    http.Client? client,
    String? apiKey,
    this.timeout = const Duration(seconds: 30),
    Future<void> Function(Duration)? delay,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? ApiConstants.apiKey,
        _delay = delay;

  final http.Client _client;
  final String _apiKey;
  final Duration timeout;
  final Future<void> Function(Duration)? _delay;
  final Map<String, Map<String, dynamic>> _people = {};

  @override
  Future<Map<String, dynamic>> movie(
          String id, McuImportCancellation cancellation) =>
      _get('movie/$id', cancellation, {'append_to_response': 'credits'});

  @override
  Future<Map<String, dynamic>> person(
      String id, McuImportCancellation cancellation) async {
    cancellation.check();
    final cached = _people[id];
    if (cached != null) return cached;
    final result = await _get('person/$id', cancellation, {});
    if (McuImportMapper.entityId(result['id'], 'Person response') != id) {
      throw const McuImportException('TMDB returned the wrong person ID.');
    }
    _people[id] = result;
    return result;
  }

  Future<Map<String, dynamic>> _get(String path,
      McuImportCancellation cancellation, Map<String, String> query) async {
    if (_apiKey.trim().isEmpty) {
      throw const McuImportException('Configure the TMDB API key.',
          global: true);
    }
    final uri = Uri.parse(ApiConstants.baseUrl).resolve(path).replace(
      queryParameters: {'api_key': _apiKey, 'language': 'en-US', ...query},
    );
    for (var attempt = 0; attempt < 3; attempt++) {
      cancellation.check();
      http.Response response;
      try {
        response = await _client.get(uri, headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
        }).timeout(timeout);
      } on TimeoutException {
        if (attempt == 2) {
          throw McuImportException(
              'TMDB $path: request timed out after three attempts.');
        }
        await _wait(Duration(seconds: 1 << attempt), cancellation);
        continue;
      } on http.ClientException {
        if (attempt == 2) {
          throw McuImportException(
              'TMDB $path: network request failed after three attempts.');
        }
        await _wait(Duration(seconds: 1 << attempt), cancellation);
        continue;
      }
      cancellation.check();
      if (response.statusCode == 200) {
        try {
          return McuImportMapper.object(
              jsonDecode(response.body), 'TMDB $path');
        } on FormatException {
          throw McuImportException('TMDB $path: invalid JSON response.');
        }
      }
      final retryable =
          response.statusCode == 429 || response.statusCode >= 500;
      if (retryable && attempt < 2) {
        final retryAfter = response.headers['retry-after'];
        var wait = Duration(seconds: 1 << attempt);
        if (retryAfter != null) {
          final seconds = int.tryParse(retryAfter);
          if (seconds != null && seconds >= 0) {
            wait = Duration(seconds: seconds);
          } else {
            try {
              final remaining =
                  DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US')
                      .parseUtc(retryAfter)
                      .difference(DateTime.now().toUtc());
              if (!remaining.isNegative) wait = remaining;
            } on FormatException {
              throw McuImportException(
                  'TMDB $path: invalid Retry-After header.');
            }
          }
        }
        if (wait > const Duration(minutes: 2)) {
          throw McuImportException(
              'TMDB $path: rate limited; retry after $retryAfter.',
              global: true);
        }
        await _wait(wait, cancellation);
        continue;
      }
      throw McuImportException(
        'TMDB $path: HTTP ${response.statusCode}. '
        '${response.statusCode == 404 ? 'Resource not found.' : 'Check API access or retry later.'}',
        global: response.statusCode == 401 ||
            response.statusCode == 403 ||
            response.statusCode == 429,
      );
    }
    throw McuImportException('TMDB $path: retries exhausted.');
  }

  Future<void> _wait(
      Duration duration, McuImportCancellation cancellation) async {
    final delay = _delay;
    if (delay != null) {
      await delay(duration);
      cancellation.check();
    } else {
      await cancellation.wait(duration);
    }
  }

  @override
  void close() => _client.close();
}
