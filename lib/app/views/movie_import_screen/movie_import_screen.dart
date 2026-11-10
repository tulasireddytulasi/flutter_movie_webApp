import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';
import 'package:moviewebapp/app/providers/bulk_movie_import_controller.dart';
import 'package:moviewebapp/app/views/bulk_movie_import_screen/bulk_movie_import_screen.dart';
import 'package:moviewebapp/app/views/mcu_import_screen/mcu_import_screen.dart';
import 'package:moviewebapp/app/views/movie_editor_screen/movie_editor_screen.dart';

enum _MovieImportSource { list, search }

class MovieImportScreen extends StatefulWidget {
  const MovieImportScreen({Key? key}) : super(key: key);

  @override
  State<MovieImportScreen> createState() => MovieImportScreenState();
}

class MovieImportScreenState extends State<MovieImportScreen> {
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
  final TextEditingController _franchiseController = TextEditingController();
  final Map<String, TextEditingController> _metadataControllers = {
    'country': TextEditingController(),
    'language': TextEditingController(),
    'theme': TextEditingController(),
  };
  final TextEditingController _genresController = TextEditingController();
  final BulkMovieImportController _bulkController = BulkMovieImportController();
  final GlobalKey _workspaceKey = GlobalKey();
  final ValueNotifier<_MovieImportSource> _sourceNotifier = ValueNotifier<_MovieImportSource>(_MovieImportSource.list);
  final ValueNotifier<Set<int>> _selectedMovieIds = ValueNotifier<Set<int>>(<int>{});

  String _movieType = 'popular';
  List<Movies> _movies = <Movies>[];
  bool _isFetching = false;
  bool _workspaceConfirming = false;
  bool _leaving = false;
  bool _allowPop = false;
  String? _errorMessage;
  String? _statusMessage;

  bool get _isBusy => _isFetching || _bulkController.busy || _workspaceConfirming || _leaving;

  @override
  void initState() {
    super.initState();
    _bulkController.addListener(_bulkChanged);
  }

  void _bulkChanged() {
    if (mounted) setState(() {});
  }

  Future<bool> confirmLeave() async {
    if (_isBusy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish or cancel the current operation before leaving Import.')),
      );
      return false;
    }
    if (_bulkController.movies.isEmpty) return true;
    setState(() => _leaving = true);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Import?'),
        content: const Text('The review queue contains local edits or retry progress. Switching tabs '
            'keeps it in this app session; leaving or restarting the app discards it. '
            'Stored Appwrite rows are not deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave')),
        ],
      ),
    );
    if (!mounted) return false;
    setState(() => _leaving = false);
    return leave == true;
  }

  Future<void> _leaveRoute() async {
    if (await confirmLeave() && mounted) {
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await Navigator.of(context).maybePop();
        if (mounted) setState(() => _allowPop = false);
      });
    }
  }

  Future<void> _openImporter(Widget screen) async {
    if (_isBusy || !await confirmLeave() || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _languageController.dispose();
    _searchLanguageController.dispose();
    _searchController.dispose();
    _franchiseController.dispose();
    for (final controller in _metadataControllers.values) {
      controller.dispose();
    }
    _genresController.dispose();
    _bulkController.removeListener(_bulkChanged);
    _bulkController.dispose();
    _sourceNotifier.dispose();
    _selectedMovieIds.dispose();
    super.dispose();
  }

  void _clearResults() {
    if (_isBusy) return;
    setState(() {
      _movies = <Movies>[];
      _errorMessage = null;
      _statusMessage = null;
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
    if (_isBusy) return;
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
            ? 'Found ${movies.length} results for "$searchQuery" on page $page. '
                'Select titles, then fetch full details for review.'
            : 'Fetched ${movies.length} movies from page $page.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not fetch movies: $error');
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _fetchSelectedDetails() async {
    if (_isBusy || _sourceNotifier.value != _MovieImportSource.search) return;
    final ids = _movies
        .where((movie) => movie.id != null && movie.id! > 0 && _selectedMovieIds.value.contains(movie.id))
        .map((movie) => movie.id!)
        .toSet();
    if (ids.isEmpty) return;
    await _bulkController.fetch(ids.join(','));
  }

  Widget _searchPoster(Movies movie) {
    final path = movie.posterPath;
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.movie_outlined, size: 24)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 36,
        height: 54,
        child: path == null || !path.startsWith('/') || path.startsWith('//')
            ? Tooltip(message: 'No poster available', child: placeholder)
            : Image.network(
                'https://image.tmdb.org/t/p/w92$path',
                fit: BoxFit.cover,
                semanticLabel: '${movie.title ?? "Movie"} poster',
                loadingBuilder: (_, child, progress) => progress == null ? child : placeholder,
                errorBuilder: (_, __, ___) => Tooltip(message: 'Could not load poster', child: placeholder),
              ),
      ),
    );
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

    return PopScope(
      canPop: _allowPop || (!_isBusy && _bulkController.movies.isEmpty),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _leaveRoute();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: ListView(
            key: const PageStorageKey<String>('movie-import-scroll'),
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            children: <Widget>[
              Text('Movie data import', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Browse TMDB lists, or search titles and review full movie details before uploading.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _isBusy ? null : () => _openImporter(const McuImportScreen()),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('MCU import'),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _isBusy ? null : () => _openImporter(const MovieEditorScreen()),
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Movie ID editor'),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _isBusy ? null : () => _openImporter(const BulkMovieImportScreen()),
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
                        key: const PageStorageKey<String>('movie-import-search-input'),
                        controller: _searchController,
                        enabled: !_isBusy,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _fetchMovies(source),
                        decoration: const InputDecoration(labelText: 'Movie title'),
                      ),
                    ),
                  if (isSearch)
                    SizedBox(
                      width: 240,
                      child: TextField(
                        key: const PageStorageKey<String>('movie-import-franchise-input'),
                        controller: _franchiseController,
                        enabled: !_isBusy,
                        decoration: const InputDecoration(
                          labelText: 'Franchise (optional)',
                          helperText: 'Upload default; blank writes null',
                        ),
                      ),
                    ),
                  if (isSearch)
                    for (final entry in _metadataControllers.entries)
                      SizedBox(
                        width: 200,
                        child: TextField(
                          key: PageStorageKey<String>('movie-import-${entry.key}-input'),
                          controller: entry.value,
                          enabled: !_isBusy,
                          decoration: InputDecoration(
                            labelText: '${entry.key[0].toUpperCase()}${entry.key.substring(1)} (optional)',
                            helperText: 'Upload value; blank writes null',
                          ),
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
                      key: const PageStorageKey<String>('movie-import-page-input'),
                      controller: _pageController,
                      enabled: !_isBusy,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Page'),
                    ),
                  ),
                  SizedBox(
                    width: 155,
                    child: TextField(
                      key: PageStorageKey<String>(
                          isSearch ? 'movie-import-search-language-input' : 'movie-import-language-input'),
                      controller: isSearch ? _searchLanguageController : _languageController,
                      enabled: !_isBusy,
                      decoration: InputDecoration(labelText: isSearch ? 'Search language' : 'Original language'),
                    ),
                  ),
                  if (!isSearch)
                    SizedBox(
                      width: 170,
                      child: TextField(
                        key: const PageStorageKey<String>('movie-import-genres-input'),
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
                  if (isSearch)
                    FilledButton.icon(
                      onPressed: _isBusy || uploadCount == 0 ? null : _fetchSelectedDetails,
                      icon: const Icon(Icons.download_outlined),
                      label: Text('Fetch selected details ($uploadCount)'),
                    )
                  else
                    const OutlinedButton(
                      onPressed: null,
                      child: Text('List upload unavailable'),
                    ),
                ],
              ),
              if (!isSearch) ...[
                const SizedBox(height: 8),
                const Text('Movie list browsing is available, but its legacy upload table was removed. '
                    'Use Search API or Bulk movie upload for full movie, genre, people and credit uploads.'),
              ],
              if (_isFetching) ...<Widget>[
                const SizedBox(height: 14),
                LinearProgressIndicator(),
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
                      tooltip: 'Clear discovery results (keeps review queue)',
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
                          ? 'Search for a movie title, select results, then fetch full details below.'
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
                  minTileHeight: isSearch ? 76 : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: isSearch
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _movies[index].id != null && selectedIds.contains(_movies[index].id),
                              onChanged: _movies[index].id == null || _movies[index].id! <= 0 || _isBusy
                                  ? null
                                  : (selected) => _setMovieSelected(_movies[index], selected ?? false),
                            ),
                            const SizedBox(width: 8),
                            _searchPoster(_movies[index]),
                          ],
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
                  trailing: isSearch ? null : const Icon(Icons.movie_outlined),
                ),
                if (index < _movies.length - 1) const Divider(height: 1),
              ],
              Offstage(
                offstage: !isSearch,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text('Full-detail review and upload queue', style: theme.textTheme.titleLarge),
                    const Text('Result checkboxes choose IDs to fetch. Queue checkboxes below choose what to upload. '
                        'New searches keep this queue, edits and retry progress. Details and profiles use en-US.'),
                    const SizedBox(height: 12),
                    BulkMovieImportWorkspace(
                      key: _workspaceKey,
                      controller: _bulkController,
                      franchiseController: _franchiseController,
                      movieAttributeControllers: _metadataControllers,
                      embedded: true,
                      disabled: _isFetching || _leaving,
                      onConfirmationChanged: (value) {
                        if (mounted) setState(() => _workspaceConfirming = value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
