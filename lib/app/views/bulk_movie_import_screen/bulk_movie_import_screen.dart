import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/appwrite_mcu_import_service.dart';
import 'package:moviewebapp/app/models/bulk_movie_import_models.dart';
import 'package:moviewebapp/app/models/mcu_import_models.dart';
import 'package:moviewebapp/app/models/movie_editor_models.dart';
import 'package:moviewebapp/app/providers/bulk_movie_import_controller.dart';

class BulkMovieImportScreen extends StatelessWidget {
  const BulkMovieImportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Bulk movie upload')),
        body: const SafeArea(child: BulkMovieImportWorkspace()),
      );
}

class BulkMovieImportWorkspace extends StatefulWidget {
  const BulkMovieImportWorkspace({
    Key? key,
    this.controller,
    this.franchiseController,
    this.embedded = false,
    this.disabled = false,
    this.onConfirmationChanged,
  }) : super(key: key);

  final BulkMovieImportController? controller;
  final TextEditingController? franchiseController;
  final bool embedded;
  final bool disabled;
  final ValueChanged<bool>? onConfirmationChanged;

  @override
  State<BulkMovieImportWorkspace> createState() => _BulkMovieImportWorkspaceState();
}

class _BulkMovieImportWorkspaceState extends State<BulkMovieImportWorkspace> {
  late final BulkMovieImportController _controller;
  final _ids = TextEditingController();
  final _castCount = TextEditingController(text: '15');
  final _crewCount = TextEditingController(text: '15');
  late final TextEditingController _franchise;
  bool _includePeople = true;
  bool _allowPop = false;
  bool _confirming = false;
  String? _settingsError;

  bool get _disabled => widget.disabled || _controller.busy || _confirming;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? BulkMovieImportController();
    _franchise = widget.franchiseController ?? TextEditingController();
  }

  void _setConfirming(bool value) {
    setState(() => _confirming = value);
    widget.onConfirmationChanged?.call(value);
  }

  @override
  void dispose() {
    _ids.dispose();
    _castCount.dispose();
    _crewCount.dispose();
    if (widget.franchiseController == null) _franchise.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  BulkMovieSettings _settings() {
    final cast = int.tryParse(_castCount.text.trim());
    final crew = int.tryParse(_crewCount.text.trim());
    if (cast == null || crew == null || cast < 0 || crew < 0) {
      throw const McuImportException('Cast and crew limits must be non-negative whole numbers.');
    }
    return BulkMovieSettings(
      includePeople: _includePeople,
      options: McuImportOptions(castLimit: cast, crewLimit: crew, franchise: _franchise.text),
    );
  }

  Future<void> _upload({bool retry = false}) async {
    if (_disabled) return;
    BulkMovieSettings settings;
    try {
      settings = _settings();
      setState(() => _settingsError = null);
    } on McuImportException catch (failure) {
      setState(() => _settingsError = failure.message);
      return;
    }
    _setConfirming(true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(retry ? 'Retry selected unfinished movies?' : 'Upload selected movies?'),
        content: Text(
          'Up to ${BulkMovieImportController.parallelMovies} movies run concurrently, sharing '
          'at most ${BulkMovieImportController.parallelPeople} people workers in total.\n\n'
          'Defaults: ${settings.includePeople ? "${settings.options.castLimit} cast and "
              "${settings.options.crewLimit} crew unique people per movie, keeping all their roles/jobs" : "movies and genres only"}.\n'
          'Franchise: ${settings.options.normalizedFranchise ?? "null (blank clears existing values)"}.\n\n'
          'Per-movie overrides take priority. Previously attempted movies retain their original '
          'data/settings for retries; successful rows are skipped. Edit a movie to start a new '
          'upload plan. Existing profiles are reused and no rows are deleted.\n\n'
          'Keep this screen open until the batch finishes. Public Appwrite write permissions '
          'must already be configured; revoke them after importing.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Upload')),
        ],
      ),
    );
    if (!mounted) return;
    _setConfirming(false);
    if (confirmed == true) await _controller.upload(settings, retry: retry);
  }

  Future<void> _edit(BulkMovieEntry movie) async {
    if (_disabled) return;
    BulkMovieSettings settings;
    try {
      settings = _settings();
      setState(() => _settingsError = null);
    } on McuImportException catch (failure) {
      setState(() => _settingsError = failure.message);
      return;
    }
    _setConfirming(true);
    final result = await showDialog<_BulkMovieEditResult>(
      context: context,
      builder: (_) => _BulkMovieEditDialog(movie: movie, defaults: settings),
    );
    if (!mounted) return;
    _setConfirming(false);
    if (result != null) {
      _controller.edit(movie, result.data, result.settings);
    }
  }

  Future<void> _leave() async {
    if (_confirming) return;
    _setConfirming(true);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave the bulk workspace?'),
        content: const Text(
          'In-flight requests will finish and stored rows are kept. This screen holds the '
          'retry progress and unsaved edits in memory; leaving discards that local progress.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel and leave')),
        ],
      ),
    );
    if (!mounted) return;
    _setConfirming(false);
    if (leave != true) return;
    _controller.cancel();
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _remove({BulkMovieEntry? movie}) async {
    if (_disabled) return;
    _setConfirming(true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(movie == null ? 'Clear review queue?' : 'Remove ${movie.title}?'),
        content: const Text('Local edits and retry progress for these movies will be discarded. '
            'No stored Appwrite rows will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (!mounted) return;
    _setConfirming(false);
    if (confirmed == true) {
      if (movie == null) {
        _controller.clear();
      } else {
        _controller.remove(movie);
      }
    }
  }

  Widget _error(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      );

  Widget _controls() {
    final disabled = _disabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.embedded) ...[
          const Text('Paste IDs separated by commas, spaces, or newlines. Duplicate IDs are removed.'),
          const SizedBox(height: 8),
          TextField(
            key: const PageStorageKey<String>('bulk-movie-ids-input'),
            controller: _ids,
            enabled: !disabled,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'TMDB movie IDs',
              hintText: '1726, 10138, 68721',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: disabled ? null : () => _controller.fetch(_ids.text),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Fetch movies'),
              ),
            ],
          ),
        ],
        if (_controller.hasFetchFailures)
          OutlinedButton(
            onPressed: disabled ? null : () => _controller.fetch('', retry: true),
            child: const Text('Retry failed detail fetches'),
          ),
        const SizedBox(height: 20),
        Text('Shared upload settings', style: Theme.of(context).textTheme.titleMedium),
        const Text('Apply to new upload plans. Existing retry plans keep their original settings.'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Include people and cast/crew credits'),
          subtitle: const Text('Turn off to upload only movies and genres.'),
          value: _includePeople,
          onChanged: disabled ? null : (value) => setState(() => _includePeople = value),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 170,
              child: TextField(
                key: const PageStorageKey<String>('bulk-cast-limit-input'),
                controller: _castCount,
                enabled: !disabled && _includePeople,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cast people per movie', helperText: '0 skips cast'),
              ),
            ),
            SizedBox(
              width: 170,
              child: TextField(
                key: const PageStorageKey<String>('bulk-crew-limit-input'),
                controller: _crewCount,
                enabled: !disabled && _includePeople,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Crew people per movie', helperText: '0 skips crew'),
              ),
            ),
            if (widget.franchiseController == null)
              SizedBox(
                width: 260,
                child: TextField(
                  key: const PageStorageKey<String>('bulk-franchise-input'),
                  controller: _franchise,
                  enabled: !disabled,
                  decoration: const InputDecoration(
                    labelText: 'Franchise (optional)',
                    helperText: 'Blank uploads null',
                  ),
                ),
              ),
          ],
        ),
        if (_settingsError != null) _error(_settingsError!),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: disabled || _controller.uploadCount == 0 ? null : () => _upload(),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text('Upload selected (${_controller.uploadCount})'),
            ),
            OutlinedButton(
              onPressed: disabled || !_controller.hasUploadFailures ? null : () => _upload(retry: true),
              child: const Text('Retry selected unfinished'),
            ),
            if (_controller.busy) OutlinedButton(onPressed: _controller.cancel, child: const Text('Cancel')),
          ],
        ),
        const SizedBox(height: 12),
        Text(_controller.message),
        if (_controller.busy) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _controller.total == 0 ? null : _controller.completed / _controller.total,
          ),
          Text('${_controller.completed} / ${_controller.total} movies processed'),
        ],
        if (_controller.error != null) _error(_controller.error!),
        const SizedBox(height: 12),
        ExpansionTile(
          key: const PageStorageKey<String>('bulk-setup-expansion'),
          title: const Text('Appwrite setup and permissions'),
          children: [
            Padding(padding: const EdgeInsets.all(12), child: Text(AppwriteMcuImportService.setupNotice)),
          ],
        ),
        if (_controller.movies.isNotEmpty)
          Wrap(
            spacing: 12,
            children: [
              TextButton(
                  onPressed: disabled ? null : () => _controller.selectAll(true), child: const Text('Select all')),
              TextButton(
                  onPressed: disabled ? null : () => _controller.selectAll(false), child: const Text('Deselect all')),
              TextButton(onPressed: disabled ? null : () => _remove(), child: const Text('Clear review queue')),
            ],
          ),
      ],
    );
  }

  Widget _movieCard(BulkMovieEntry movie) {
    final disabled = _disabled;
    final poster = movie.posterPath;
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                    value: movie.selected,
                    onChanged: disabled ? null : (value) => _controller.select(movie, value == true)),
                if (poster != null) ...[
                  Image.network(
                    'https://image.tmdb.org/t/p/w92$poster',
                    width: 46,
                    height: 69,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 46, height: 69, child: Icon(Icons.broken_image_outlined)),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, style: Theme.of(context).textTheme.titleMedium),
                      Text('ID ${movie.id} | ${movie.data?['release_date'] ?? "No release date"}'),
                      Text(movie.status.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: movie.status == BulkMovieStatus.failed || movie.status == BulkMovieStatus.partial
                                ? Theme.of(context).colorScheme.error
                                : null,
                          )),
                      Text(movie.message),
                      if (movie.overrideSettings != null) const Text('Per-movie settings override'),
                      if (movie.uploadSettings != null)
                        Text('Upload plan: franchise=${movie.uploadSettings!.options.normalizedFranchise ?? "null"}, '
                            '${movie.bundle?.cast.length ?? 0} cast / '
                            '${movie.bundle?.crew.length ?? 0} crew credits'),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: disabled || movie.data == null ? null : () => _edit(movie),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit / override settings'),
                          ),
                          TextButton(
                            onPressed: disabled ? null : () => _remove(movie: movie),
                            child: const Text('Remove from queue'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (movie.peopleResults.isNotEmpty)
            ExpansionTile(
              key: PageStorageKey<String>('bulk-${movie.id}-people-expansion'),
              title: Text('People statuses (${movie.peopleResults.length})'),
              children: [
                for (final entry in movie.peopleResults.entries)
                  ListTile(
                    dense: true,
                    title: Text('${movie.peopleNames[entry.key] ?? entry.key}: ${entry.value.status.label}'),
                    subtitle: Text(entry.value.message),
                  ),
              ],
            ),
          if (movie.warnings.isNotEmpty)
            ExpansionTile(
              key: PageStorageKey<String>('bulk-${movie.id}-warnings-expansion'),
              title: Text('Warnings (${movie.warnings.toSet().length})'),
              children: [
                for (final warning in movie.warnings.toSet())
                  Padding(padding: const EdgeInsets.all(8), child: Text(warning)),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => widget.embedded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _controls(),
                  for (final movie in _controller.movies)
                    KeyedSubtree(key: ValueKey<String>(movie.id), child: _movieCard(movie)),
                ],
              )
            : PopScope(
                canPop: (!_controller.busy && !_confirming && _controller.movies.isEmpty) || _allowPop,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) _leave();
                },
                child: ListView.builder(
                  key: const PageStorageKey<String>('bulk-movies-scroll'),
                  padding: const EdgeInsets.all(24),
                  itemCount: _controller.movies.length + 1,
                  itemBuilder: (_, index) => index == 0
                      ? _controls()
                      : KeyedSubtree(
                          key: ValueKey<String>(_controller.movies[index - 1].id),
                          child: _movieCard(_controller.movies[index - 1]),
                        ),
                ),
              ),
      );
}

class _BulkMovieEditResult {
  const _BulkMovieEditResult(this.data, this.settings);
  final Map<String, dynamic> data;
  final BulkMovieSettings? settings;
}

class _BulkMovieEditDialog extends StatefulWidget {
  const _BulkMovieEditDialog({required this.movie, required this.defaults});
  final BulkMovieEntry movie;
  final BulkMovieSettings defaults;

  @override
  State<_BulkMovieEditDialog> createState() => _BulkMovieEditDialogState();
}

class _BulkMovieEditDialogState extends State<_BulkMovieEditDialog> {
  final Map<String, TextEditingController> _fields = {};
  late final TextEditingController _cast;
  late final TextEditingController _crew;
  late bool _customSettings;
  late bool _includePeople;
  String? _error;

  @override
  void initState() {
    super.initState();
    final settings = widget.movie.overrideSettings ?? widget.movie.uploadSettings ?? widget.defaults;
    _customSettings = widget.movie.overrideSettings != null || widget.movie.uploadSettings != null;
    _includePeople = settings.includePeople;
    _cast = TextEditingController(text: settings.options.castLimit.toString());
    _crew = TextEditingController(text: settings.options.crewLimit.toString());
    for (final field in movieEditorFields) {
      _fields[field.key] = TextEditingController(
          text: field.display(
        field.key == 'franchise' ? settings.options.normalizedFranchise : widget.movie.data![field.key],
      ));
    }
  }

  @override
  void dispose() {
    _cast.dispose();
    _crew.dispose();
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  void _save() {
    try {
      final cast = int.tryParse(_cast.text.trim());
      final crew = int.tryParse(_crew.text.trim());
      if (cast == null || crew == null || cast < 0 || crew < 0) {
        throw const McuImportException('Cast and crew limits must be non-negative whole numbers.');
      }
      final settings = _customSettings
          ? BulkMovieSettings(
              includePeople: _includePeople,
              options: McuImportOptions(castLimit: cast, crewLimit: crew, franchise: _fields['franchise']!.text),
            )
          : null;
      final data = Map<String, dynamic>.from(widget.movie.data!);
      for (final field in movieEditorFields) {
        data[field.key] = field.parse(_fields[field.key]!.text);
      }
      McuImportMapper([]).movie(data, widget.movie.id, options: (settings ?? widget.defaults).mappingOptions);
      Navigator.pop(context, _BulkMovieEditResult(data, settings));
    } on McuImportException catch (failure) {
      setState(() => _error = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 720, maxHeight: MediaQuery.sizeOf(context).height * .85),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit ${widget.movie.title}', style: Theme.of(context).textTheme.titleLarge),
                const Text('Saving starts a new upload plan. Stored rows are not deleted.'),
                Expanded(
                  child: ListView(
                    key: PageStorageKey<String>('bulk-edit-${widget.movie.id}-scroll'),
                    children: [
                      SwitchListTile(
                        title: const Text('Override shared settings for this movie'),
                        value: _customSettings,
                        onChanged: (value) => setState(() => _customSettings = value),
                      ),
                      if (!_customSettings)
                        Text('Shared franchise: ${widget.defaults.options.normalizedFranchise ?? "null"}. '
                            'Shared counts and upload mode will apply.'),
                      if (_customSettings) ...[
                        SwitchListTile(
                          title: const Text('Include people and credits'),
                          value: _includePeople,
                          onChanged: (value) => setState(() => _includePeople = value),
                        ),
                        TextField(
                          key: PageStorageKey<String>('bulk-edit-${widget.movie.id}-cast-input'),
                          controller: _cast,
                          enabled: _includePeople,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cast unique people'),
                        ),
                        TextField(
                          key: PageStorageKey<String>('bulk-edit-${widget.movie.id}-crew-input'),
                          controller: _crew,
                          enabled: _includePeople,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Crew unique people'),
                        ),
                      ],
                      for (final field in movieEditorFields)
                        if (field.key != 'franchise' || _customSettings)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextField(
                              key: PageStorageKey<String>('bulk-edit-${widget.movie.id}-${field.key}-input'),
                              controller: _fields[field.key],
                              enabled: field.key != 'franchise' || _customSettings,
                              minLines: field.multiline ? 3 : 1,
                              maxLines: field.multiline ? 8 : 1,
                              decoration: InputDecoration(
                                labelText: '${field.label}${field.required ? " *" : ""}',
                                helperText: field.key == 'genres'
                                    ? 'JSON array: [{"id":28,"name":"Action"}]'
                                    : field.key == 'franchise'
                                        ? 'Blank uploads null'
                                        : null,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    FilledButton(onPressed: _save, child: const Text('Save edits')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
