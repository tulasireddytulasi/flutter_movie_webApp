import 'dart:async';

class McuImportException implements Exception {
  const McuImportException(this.message, {this.global = false});

  final String message;
  final bool global;

  @override
  String toString() => message;
}

class McuImportCancelled implements Exception {
  const McuImportCancelled();
}

class McuImportCancellation {
  bool requested = false;

  void check() {
    if (requested) throw const McuImportCancelled();
  }

  Future<void> wait(Duration duration) async {
    final end = DateTime.now().add(duration);
    while (DateTime.now().isBefore(end)) {
      check();
      final remaining = end.difference(DateTime.now());
      await Future<void>.delayed(
        remaining > const Duration(milliseconds: 100) ? const Duration(milliseconds: 100) : remaining,
      );
    }
    check();
  }
}

class McuSeedMovie {
  const McuSeedMovie({required this.id, required this.title, this.posterPath});

  final String id;
  final String title;
  final String? posterPath;
}

class McuImportRow {
  const McuImportRow(this.table, this.id, this.data);

  final String table;
  final String id;
  final Map<String, dynamic> data;
}

class McuImportOptions {
  const McuImportOptions({
    this.castLimit = 15,
    this.crewLimit = 15,
    this.franchise,
  });

  final int castLimit;
  final int crewLimit;
  final String? franchise;

  String? get normalizedFranchise {
    final value = franchise?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  void validate() {
    if (castLimit < 0 || crewLimit < 0) {
      throw const McuImportException('Cast and crew limits must be non-negative integers.');
    }
  }
}

class McuMovieBundle {
  const McuMovieBundle({
    required this.movie,
    required this.genres,
    required this.cast,
    required this.crew,
  });

  final McuImportRow movie;
  final List<McuImportRow> genres;
  final List<McuImportRow> cast;
  final List<McuImportRow> crew;

  Set<String> get personIds => [...cast, ...crew].map((row) => row.data['person'] as String).toSet();
}

/// Maps only writable schema fields, preserving absent versus explicit null.
class McuImportMapper {
  McuImportMapper(this.warnings);

  final List<String> warnings;

  static String entityId(dynamic value, String context) {
    if (value is! int || value <= 0) {
      throw McuImportException('$context: expected a positive TMDB integer ID.');
    }
    return value.toString();
  }

  static String creditId(dynamic value, String context) {
    if (value is! String || !RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]{0,35}$').hasMatch(value)) {
      throw McuImportException('$context: missing or invalid TMDB credit_id.');
    }
    return value;
  }

  static Map<String, dynamic> object(dynamic value, String context) {
    if (value is! Map<String, dynamic>) {
      throw McuImportException('$context: expected a JSON object.');
    }
    return value;
  }

  static List<dynamic> array(dynamic value, String context) {
    if (value is! List<dynamic>) {
      throw McuImportException('$context: expected a JSON array.');
    }
    return value;
  }

  static List<McuSeedMovie> seeds(Map<String, dynamic> source) {
    final result = <McuSeedMovie>[];
    final seen = <String>{};
    for (final item in array(source['results'], 'Marvel seed results')) {
      final data = object(item, 'Marvel seed');
      final id = entityId(data['id'], 'Marvel seed');
      final title = data['title'];
      if (title is! String || title.trim().isEmpty) {
        throw McuImportException('Marvel seed $id: missing title.');
      }
      if (seen.add(id)) {
        final poster = data['poster_path'];
        result.add(McuSeedMovie(
          id: id,
          title: title,
          posterPath: poster is String && poster.startsWith('/') ? poster : null,
        ));
      }
    }
    return result;
  }

  void _text(Map<String, dynamic> source, Map<String, dynamic> target, String key, int size, String context,
      {bool required = false, bool truncate = true}) {
    if (!source.containsKey(key)) {
      if (required) throw McuImportException('$context.$key: missing value.');
      return;
    }
    final value = source[key];
    if (value == null && !required) {
      target[key] = null;
      return;
    }
    if (value is! String || (required && value.trim().isEmpty)) {
      throw McuImportException('$context.$key: invalid string.');
    }
    if (value.runes.length > size) {
      if (required || !truncate) {
        throw McuImportException('$context.$key exceeds $size characters.');
      }
      warnings.add('$context.$key truncated to $size characters.');
      target[key] = String.fromCharCodes(value.runes.take(size));
    } else {
      target[key] = value;
    }
  }

  void _number(Map<String, dynamic> source, Map<String, dynamic> target, String key, String context,
      {bool required = false, bool integer = false, num? min, num? max}) {
    if (!source.containsKey(key)) {
      if (required) throw McuImportException('$context.$key: missing value.');
      return;
    }
    final value = source[key];
    if (value == null && !required) {
      target[key] = null;
      return;
    }
    if (value is! num ||
        !value.isFinite ||
        (integer && (value is! int || value.abs() > 9007199254740991)) ||
        (min != null && value < min) ||
        (max != null && value > max)) {
      throw McuImportException('$context.$key: invalid numeric value.');
    }
    target[key] = integer ? value : value.toDouble();
  }

  void _boolean(Map<String, dynamic> source, Map<String, dynamic> target, String key, String context) {
    final value = source[key];
    if (value is! bool) {
      throw McuImportException('$context.$key: expected a boolean.');
    }
    target[key] = value;
  }

  void _date(Map<String, dynamic> source, Map<String, dynamic> target, String key, String context) {
    if (!source.containsKey(key)) return;
    final value = source[key];
    if (value == null || value == '') {
      target[key] = null;
      return;
    }
    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw McuImportException('$context.$key: expected YYYY-MM-DD.');
    }
    final date = DateTime.tryParse('${value}T00:00:00Z');
    if (date == null || date.toIso8601String().substring(0, 10) != value) {
      throw McuImportException('$context.$key: invalid calendar date.');
    }
    target[key] = date.toIso8601String();
  }

  void _path(Map<String, dynamic> source, Map<String, dynamic> target, String key, String context) {
    _text(source, target, key, 255, context, truncate: false);
    final path = target[key];
    if (path is String && (!path.startsWith('/') || path.startsWith('//') || path.contains('://'))) {
      throw McuImportException('$context.$key: expected a relative image path.');
    }
  }

  McuMovieBundle movie(Map<String, dynamic> source, String expectedId,
      {McuImportOptions options = const McuImportOptions()}) {
    options.validate();
    final id = entityId(source['id'], 'Movie');
    if (id != expectedId) {
      throw McuImportException('TMDB returned the wrong movie ID.');
    }
    final context = 'Movie $id';
    final data = <String, dynamic>{'franchise': options.normalizedFranchise};
    _text(source, data, 'title', 500, context, required: true);
    for (final key in ['original_title', 'tagline']) {
      _text(source, data, key, 500, context);
    }
    _text(source, data, 'overview', 5000, context);
    _text(source, data, 'status', 50, context);
    _date(source, data, 'release_date', context);
    for (final key in ['runtime', 'budget', 'revenue']) {
      _number(source, data, key, context, integer: true, min: 0);
    }
    _boolean(source, data, 'adult', context);
    for (final key in ['popularity', 'vote_average']) {
      _number(source, data, key, context, required: true);
    }
    _number(source, data, 'vote_count', context, required: true, integer: true, min: 0);
    for (final key in ['poster_path', 'backdrop_path']) {
      _path(source, data, key, context);
    }
    final genres = <String, McuImportRow>{};
    for (final item in array(source['genres'], '$context.genres')) {
      final genre = object(item, '$context.genre');
      final genreId = entityId(genre['id'], '$context.genre');
      final fields = <String, dynamic>{};
      _text(genre, fields, 'name', 100, 'Genre $genreId', required: true);
      genres[genreId] = McuImportRow('genres', genreId, fields);
    }
    data['genres'] = genres.keys.toList();
    final credits = object(source['credits'], '$context.credits');
    return McuMovieBundle(
      movie: McuImportRow('movies', id, data),
      genres: genres.values.toList(),
      cast: creditRows(credits['cast'], id, 'cast', limit: options.castLimit),
      crew: creditRows(credits['crew'], id, 'crew', limit: options.crewLimit),
    );
  }

  List<McuImportRow> creditRows(dynamic source, String id, String kind, {required int limit}) {
    if (!['cast', 'crew'].contains(kind) || limit < 0) {
      throw const McuImportException('Invalid credit group or limit.');
    }
    final context = 'Movie $id';
    final rows = <String, McuImportRow>{};
    if (limit == 0) return [];
    final entries = array(source, '$context.credits.$kind').map((item) => object(item, '$context.$kind')).toList();
    if (kind == 'cast') {
      for (final credit in entries) {
        _number(credit, <String, dynamic>{}, 'order', '$context.cast', required: true, integer: true, min: 0);
      }
      // Preserve response order for ties while ranking cast by TMDB order.
      final positions = {for (var i = 0; i < entries.length; i++) entries[i]: i};
      entries.sort((a, b) {
        final order = (a['order'] as int).compareTo(b['order'] as int);
        return order != 0 ? order : positions[a]!.compareTo(positions[b]!);
      });
    }
    final selectedPeople = <String>{};
    for (final credit in entries) {
      final personId = entityId(credit['id'], '$context.$kind');
      if (selectedPeople.length < limit) selectedPeople.add(personId);
    }
    for (final credit in entries) {
      final personId = entityId(credit['id'], '$context.$kind');
      if (!selectedPeople.contains(personId)) continue;
      final creditKey = creditId(credit['credit_id'], '$context.$kind');
      final fields = <String, dynamic>{
        'movie': id,
        'person': personId,
      };
      if (kind == 'cast') {
        _text(credit, fields, 'character', 255, '$context.$creditKey');
        _number(credit, fields, 'order', '$context.$creditKey', required: true, integer: true, min: 0);
      } else {
        for (final key in ['department', 'job']) {
          _text(credit, fields, key, 100, '$context.$creditKey', required: true);
        }
      }
      if (rows.containsKey(creditKey)) {
        throw McuImportException('$context.$kind: duplicate credit_id $creditKey.');
      }
      rows[creditKey] = McuImportRow('movie_$kind', creditKey, fields);
    }
    return rows.values.toList();
  }

  McuImportRow person(Map<String, dynamic> source, String expectedId) {
    final id = entityId(source['id'], 'Person');
    if (id != expectedId) {
      throw McuImportException('TMDB returned the wrong person ID.');
    }
    final context = 'Person $id';
    final data = <String, dynamic>{};
    _text(source, data, 'name', 255, context, required: true);
    _boolean(source, data, 'adult', context);
    _number(source, data, 'popularity', context, required: true);
    _number(source, data, 'gender', context, integer: true, min: 0, max: 3);
    _text(source, data, 'biography', 10000, context);
    _text(source, data, 'known_for_department', 100, context);
    _text(source, data, 'place_of_birth', 255, context);
    _text(source, data, 'imdb_id', 20, context, truncate: false);
    _text(source, data, 'homepage', 500, context, truncate: false);
    final homepage = data['homepage'];
    if (homepage is String && homepage.isNotEmpty) {
      final uri = Uri.tryParse(homepage);
      if (uri == null || !['http', 'https'].contains(uri.scheme) || uri.host.isEmpty) {
        throw McuImportException('$context.homepage: invalid HTTP URL.');
      }
    }
    for (final key in ['birthday', 'deathday']) {
      _date(source, data, key, context);
    }
    _path(source, data, 'profile_path', context);
    if (source.containsKey('also_known_as')) {
      if (source['also_known_as'] == null) {
        data['also_known_as'] = null;
      } else {
        final aliases = <String>[];
        for (final item in array(source['also_known_as'], '$context.also_known_as')) {
          final field = <String, dynamic>{};
          _text({'alias': item}, field, 'alias', 255, '$context.also_known_as');
          if (field['alias'] is! String) {
            throw McuImportException('$context.also_known_as: invalid alias.');
          }
          aliases.add(field['alias'] as String);
        }
        data['also_known_as'] = aliases;
      }
    }
    return McuImportRow('people', id, data);
  }
}
