import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/appwrite_movie_service.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/models/get_movies_model.dart';

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
  final TextEditingController _genresController = TextEditingController();
  final AppwriteMovieService _appwriteMovieService = AppwriteMovieService();

  String _movieType = 'popular';
  List<Movies> _movies = <Movies>[];
  bool _isFetching = false;
  bool _isUploading = false;
  int _uploadedCount = 0;
  int _failedCount = 0;
  String? _errorMessage;
  String? _statusMessage;
  final List<String> _uploadErrors = <String>[];

  bool get _isBusy => _isFetching || _isUploading;

  @override
  void dispose() {
    _pageController.dispose();
    _languageController.dispose();
    _genresController.dispose();
    super.dispose();
  }

  Future<void> _fetchMovies() async {
    final int? page = int.tryParse(_pageController.text.trim());
    final String language = _languageController.text.trim();
    if (page == null || page < 1) {
      setState(() {
        _errorMessage = 'Enter a page number greater than zero.';
        _statusMessage = null;
      });
      return;
    }
    if (language.isEmpty) {
      setState(() {
        _errorMessage = 'Enter an original language code, such as en.';
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

    try {
      final List<Movies> movies = await fetchMovies(
        pageKey: page,
        movieType: _movieType,
        withOriginalLanguage: language,
        withGenres: _genresController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _movies = movies;
        _statusMessage = 'Fetched ${movies.length} movies from page $page.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not fetch movies: $error');
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _uploadMovies() async {
    if (_movies.isEmpty || _isBusy) return;

    setState(() {
      _isUploading = true;
      _uploadedCount = 0;
      _failedCount = 0;
      _uploadErrors.clear();
      _errorMessage = null;
      _statusMessage = null;
    });

    for (final Movies movie in _movies) {
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
      _statusMessage = 'Uploaded $_uploadedCount of ${_movies.length} rows.';
      if (_failedCount > 0) {
        _errorMessage = '$_failedCount rows failed. Check Appwrite table permissions and column types.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
          children: <Widget>[
              Text('Movie data import', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Fetch a TMDB page and upsert its movies into TheFridayMoviesDB.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
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
                              if (value != null) setState(() => _movieType = value);
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
                    width: 145,
                    child: TextField(
                      controller: _languageController,
                      enabled: !_isBusy,
                      decoration: const InputDecoration(labelText: 'Language'),
                    ),
                  ),
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
                    onPressed: _isBusy ? null : _fetchMovies,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Fetch movies'),
                  ),
                  FilledButton.icon(
                    onPressed: _isBusy || _movies.isEmpty ? null : _uploadMovies,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload ${_movies.length}'),
                  ),
                ],
              ),
              if (_isUploading) ...<Widget>[
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: _movies.isEmpty ? null : (_uploadedCount + _failedCount) / _movies.length,
                ),
              ],
              if (_statusMessage != null || _errorMessage != null) ...<Widget>[
                const SizedBox(height: 14),
                if (_statusMessage != null)
                  Text(_statusMessage!, style: theme.textTheme.bodyMedium),
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
                  Text('Fetched movies', style: theme.textTheme.titleMedium),
                  const SizedBox(width: 8),
                  Text('${_movies.length}', style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 8),
              if (_movies.isEmpty)
                SizedBox(
                  height: 180,
                  child: Center(
                    child: Text(
                      'Choose a movie list and fetch a page to begin.',
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
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(_movies[index].title ?? 'Untitled movie'),
                  subtitle: Text(
                    'ID ${_movies[index].id ?? 'n/a'}  ·  '
                    '${_movies[index].releaseDate?.toIso8601String().split('T').first ?? 'No release date'}  ·  '
                    'Popularity ${_movies[index].popularity?.toStringAsFixed(1) ?? 'n/a'}',
                  ),
                  trailing: _isUploading
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