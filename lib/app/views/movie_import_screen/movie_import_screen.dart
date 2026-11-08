import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/appwrite_movie_service.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/views/bulk_movie_import_screen/bulk_movie_import_screen.dart';
import 'package:moviewebapp/app/views/mcu_import_screen/mcu_import_screen.dart';
import 'package:moviewebapp/app/views/movie_editor_screen/movie_editor_screen.dart';

enum _MovieImportSource { list, search }

class MovieImportScreen extends StatefulWidget {
  const MovieImportScreen({Key? key}) : super(key: key);

  @override
  State<MovieImportScreen> createState() => _MovieImportScreenState();
}

class _MovieImportScreenState extends State<MovieImportScreen> {
  static const Map<String, String> _movieTypes = <String, String>{
    'popular': 'Popular',
    'top_rated': 'Top rated',
    'now_playing': 'Now playing',
    'upcoming': 'Upcoming',
  };

  final TextEditingController _pageController = TextEditingController(text: '1');
  final TextEditingController _languageController = TextEditingController(text: 'en');
  final TextEditingController _searchLanguageController = TextEditingController(text: 'en-US');
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();
  final AppwriteMovieService _appwriteMovieService = AppwriteMovieService();
  final ValueNotifier<_MovieImportSource> _sourceNotifier = ValueNotifier<_MovieImportSource>(_MovieImportSource.list);
  final ValueNotifier<Set<int>> _selectedMovieIds = ValueNotifier<Set<int>>(<int>{});

  String _movieType = 'popular';
  List<Movies> _movies = <Movies>[];
  bool _isFetching = false;
  bool _isUploading = false;
  int _uploadedCount = 0;
  int _failedCount = 0;
  int _uploadTotal = 0;
  String? _errorMessage;
  String? _statusMessage;
  final List<String> _uploadErrors = <String>[];

  bool get _isBusy => _isFetching || _isUploading;

  @override
  void dispose() {
    _pageController.dispose();
    _languageController.dispose();
    _searchLanguageController.dispose();
    _searchController.dispose();
    _genresController.dispose();
    _sourceNotifier.dispose();
    _selectedMovieIds.dispose();
    super.dispose();
  }

  void _clearResults() {
    setState(() {
      _movies = <Movies>[];
      _errorMessage = null;
      _statusMessage = null;
      _uploadedCount = 0;
      _failedCount = 0;
      _uploadErrors.clear();
    });
    _selectedMovieIds.value = <int>{};
  }

  void _changeSource(_MovieImportSource source) {
    if (_isBusy || source == _sourceNotifier.value) return;
    _clearResults();
    _sourceNotifier.value = source;
  }

  void _setMovieSelected(Movies movie, bool selected) {
    final int? movieId = movie.id;
    if (movieId == null || _isBusy) return;
    final Set<int> updatedIds = Set<int>.of(_selectedMovieIds.value);
    if (selected) {
      updatedIds.add(movieId);
    } else {
      updatedIds.remove(movieId);
    }
    _selectedMovieIds.value = updatedIds;
  }

  Future<void> _fetchMovies(_MovieImportSource source) async {
    final int? page = int.tryParse(_pageController.text.trim());
    if (page == null || page < 1) {
      setState(() {
        _errorMessage = 'Enter a page number greater than zero.';
        _statusMessage = null;
      });
      return;
    }

    final bool isSearch = source == _MovieImportSource.search;
    final String language = (isSearch ? _searchLanguageController : _languageController).text.trim();
    if (language.isEmpty) {
      setState(() {
        _errorMessage =
            isSearch ? 'Enter a search language, such as en-US.' : 'Enter an original language code, such as en.';
        _statusMessage = null;
      });
      return;
    }

    final String searchQuery = _searchController.text.trim();
    if (isSearch && searchQuery.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a movie title to search.';
        _statusMessage = null;
      });
      return;
    }

    setState(() {
      _isFetching = true;
      _errorMessage = null;
      _statusMessage = null;
      _movies = <Movies>[];
      _uploadedCount = 0;
      _failedCount = 0;
      _uploadErrors.clear();
    });
    _selectedMovieIds.value = <int>{};

    try {
      final List<Movies> movies = isSearch
          ? await searchMovies(
              pageNo: page,
              movieQuery: searchQuery,
              language: language,
            )
          : await fetchMovies(
              pageKey: page,
              movieType: _movieType,
              withOriginalLanguage: language,
              withGenres: _genresController.text.trim(),
            );
      if (!mounted) return;
      setState(() {
        _movies = movies;
        _statusMessage = isSearch
            ? 'Found ${movies.length} results for "$searchQuery" on page $page. Select titles to upload.'
            : 'Fetched ${movies.length} movies from page $page.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not fetch movies: $error');
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _uploadMovies(_MovieImportSource source) async {
    final Set<int> selectedIds = _selectedMovieIds.value;
    final List<Movies> moviesToUpload = source == _MovieImportSource.search
        ? _movies.where((movie) => movie.id != null && selectedIds.contains(movie.id)).toList()
        : List<Movies>.of(_movies);
    if (moviesToUpload.isEmpty || _isBusy) return;

    setState(() {
      _isUploading = true;
      _uploadedCount = 0;
      _failedCount = 0;
      _uploadTotal = moviesToUpload.length;
      _uploadErrors.clear();
      _errorMessage = null;
      _statusMessage = null;
    });

    for (final Movies movie in moviesToUpload) {
      try {
        await _appwriteMovieService.upsertMovie(movie);
        _uploadedCount++;
      } catch (error) {
        _failedCount++;
        if (_uploadErrors.length < 3) {
          _uploadErrors.add('${movie.title ?? movie.id}: $error');
        }
      }
      if (mounted) setState(() {});
    }

    if (!mounted) return;
    setState(() {
      _isUploading = false;
      _statusMessage = 'Uploaded $_uploadedCount of ${moviesToUpload.length} rows.';
      if (_failedCount > 0) {
        _errorMessage = '$_failedCount rows failed. Check Appwrite table permissions and column types.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_MovieImportSource>(
      valueListenable: _sourceNotifier,
      builder: (context, source, child) => ValueListenableBuilder<Set<int>>(
        valueListenable: _selectedMovieIds,
        builder: (context, selectedIds, child) => _buildImportScreen(
          context,
          source: source,
          selectedIds: selectedIds,
        ),
      ),
    );
  }

  Widget _buildImportScreen(
    BuildContext context, {
    required _MovieImportSource source,
    required Set<int> selectedIds,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isSearch = source == _MovieImportSource.search;
    final int uploadCount =
        isSearch ? _movies.where((movie) => movie.id != null && selectedIds.contains(movie.id)).length : _movies.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
          children: <Widget>[
            Text('Movie data import', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Fetch a TMDB list or search for specific titles, then upload them to Appwrite.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _isBusy
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const McuImportScreen(),
                          ),
                        ),
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('MCU import'),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _isBusy
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MovieEditorScreen(),
                          ),
                        ),
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Movie ID editor'),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _isBusy
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const BulkMovieImportScreen(),
                          ),
                        ),
                icon: const Icon(Icons.playlist_add_outlined),
                label: const Text('Bulk movie upload'),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<_MovieImportSource>(
                    initialValue: source,
                    decoration: const InputDecoration(labelText: 'TMDB API'),
                    items: const <DropdownMenuItem<_MovieImportSource>>[
                      DropdownMenuItem(
                        value: _MovieImportSource.list,
                        child: Text('Movie list API'),
                      ),
                      DropdownMenuItem(
                        value: _MovieImportSource.search,
                        child: Text('Search API'),
                      ),
                    ],
                    onChanged: _isBusy
                        ? null
                        : (value) {
                            if (value != null) _changeSource(value);
                          },
                  ),
                ),
                if (isSearch)
                  SizedBox(
                    width: 240,
                    child: TextField(
                      controller: _searchController,
                      enabled: !_isBusy,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _fetchMovies(source),
                      decoration: const InputDecoration(labelText: 'Movie title'),
                    ),
                  ),
                if (!isSearch)
                  SizedBox(
                    width: 190,
                    child: DropdownButtonFormField<String>(
                      initialValue: _movieType,
                      decoration: const InputDecoration(labelText: 'Movie list'),
                      items: _movieTypes.entries
                          .map((entry) => DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              ))
                          .toList(),
                      onChanged: _isBusy
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _movieType = value);
                              }
                            },
                    ),
                  ),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _pageController,
                    enabled: !_isBusy,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Page'),
                  ),
                ),
                SizedBox(
                  width: 155,
                  child: TextField(
                    controller: isSearch ? _searchLanguageController : _languageController,
                    enabled: !_isBusy,
                    decoration: InputDecoration(labelText: isSearch ? 'Search language' : 'Original language'),
                  ),
                ),
                if (!isSearch)
                  SizedBox(
                    width: 170,
                    child: TextField(
                      controller: _genresController,
                      enabled: !_isBusy,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Genre IDs (optional)'),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: _isBusy ? null : () => _fetchMovies(source),
                  icon: Icon(isSearch ? Icons.search : Icons.download_outlined),
                  label: Text(isSearch ? 'Search movies' : 'Fetch movies'),
                ),
                FilledButton.icon(
                  onPressed: _isBusy || uploadCount == 0 ? null : () => _uploadMovies(source),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(_isUploading
                      ? 'Uploading...'
                      : isSearch
                          ? 'Upload selected ($uploadCount)'
                          : 'Upload all ($uploadCount)'),
                ),
              ],
            ),
            if (_isUploading) ...<Widget>[
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: _uploadTotal == 0 ? null : (_uploadedCount + _failedCount) / _uploadTotal,
              ),
            ],
            if (_statusMessage != null || _errorMessage != null) ...<Widget>[
              const SizedBox(height: 14),
              if (_statusMessage != null) Text(_statusMessage!, style: theme.textTheme.bodyMedium),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                ),
                for (final String uploadError in _uploadErrors)
                  Text(uploadError, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
              ],
            ],
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Text(isSearch ? 'Search results' : 'Fetched movies', style: theme.textTheme.titleMedium),
                const SizedBox(width: 8),
                Text('${_movies.length}', style: theme.textTheme.bodyMedium),
                const Spacer(),
                if (_movies.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear results',
                    onPressed: _isBusy ? null : _clearResults,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_movies.isEmpty)
              SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    isSearch
                        ? 'Search for a movie title to choose movies for upload.'
                        : 'Choose a movie list and fetch a page to begin.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            for (int index = 0; index < _movies.length; index++) ...<Widget>[
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: isSearch
                    ? Checkbox(
                        value: _movies[index].id != null && selectedIds.contains(_movies[index].id),
                        onChanged: _movies[index].id == null || _isBusy
                            ? null
                            : (selected) => _setMovieSelected(_movies[index], selected ?? false),
                      )
                    : CircleAvatar(
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        child: Text('${index + 1}'),
                      ),
                title: Text(_movies[index].title ?? 'Untitled movie'),
                subtitle: Text(
                  'ID ${_movies[index].id ?? 'n/a'}  ·  '
                  '${_movies[index].releaseDate?.toIso8601String().split('T').first ?? 'No release date'}  ·  '
                  'Popularity ${_movies[index].popularity?.toStringAsFixed(1) ?? 'n/a'}',
                ),
                trailing: isSearch
                    ? null
                    : _isUploading
                        ? const Icon(Icons.more_horiz)
                        : const Icon(Icons.movie_outlined),
              ),
              if (index < _movies.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}
