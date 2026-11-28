import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/appwrite_mcu_import_service.dart';
import 'package:moviewebapp/app/models/movie_editor_models.dart';
import 'package:moviewebapp/app/providers/movie_editor_controller.dart';

class MovieEditorScreen extends StatefulWidget {
  const MovieEditorScreen({Key? key, this.controller}) : super(key: key);

  final MovieEditorController? controller;

  @override
  State<MovieEditorScreen> createState() => _MovieEditorScreenState();
}

class _MovieEditorScreenState extends State<MovieEditorScreen> {
  late final MovieEditorController _controller;
  final _movieId = TextEditingController();
  final _castCount = TextEditingController(text: '15');
  final _crewCount = TextEditingController(text: '15');
  final _search = TextEditingController();
  final _fields = {
    for (final field in movieEditorFields) field.key: TextEditingController(),
  };
  bool _allowPop = false;
  bool _confirmingLeave = false;
  int _fetchRevision = 0;
  Map<String, String> _extraFields = {};

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MovieEditorController();
  }

  @override
  void dispose() {
    _movieId.dispose();
    _castCount.dispose();
    _crewCount.dispose();
    _search.dispose();
    for (final field in _fields.values) {
      field.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    } else if (_controller.busy) {
      _controller.cancel();
    }
    super.dispose();
  }

  Future<void> _fetch() async {
    FocusScope.of(context).unfocus();
    if (!await _controller.fetchMovie(_movieId.text) || !mounted) return;
    final movie = _controller.movieData;
    for (final field in movieEditorFields) {
      _fields[field.key]!.text = field.display(movie[field.key]);
    }
    final knownFields = movieEditorFields.map((field) => field.key).toSet();
    _extraFields = {
      for (final entry in movie.entries)
        if (!knownFields.contains(entry.key))
          entry.key:
              entry.value is String ? entry.value as String : const JsonEncoder.withIndent('  ').convert(entry.value),
    };
    _fetchRevision++;
    _search.clear();
    if (_controller.selectFirst('cast', _castCount.text)) {
      _controller.selectFirst('crew', _crewCount.text);
    }
    setState(() {});
  }

  Future<void> _leave() async {
    if (_confirmingLeave) return;
    _confirmingLeave = true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel uploads and leave?'),
        content: const Text(
          'In-flight operations will finish. Completed rows are kept; '
          'unfinished profile and credit uploads can be retried.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel and leave')),
        ],
      ),
    );
    _confirmingLeave = false;
    if (leave != true || !mounted) return;
    _controller.cancel();
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Widget _movieField(MovieEditorField field) {
    final numeric = field.type == MovieEditorFieldType.integer || field.type == MovieEditorFieldType.decimal;
    return TextField(
      key: PageStorageKey<String>('movie-editor-input-$_fetchRevision-${field.key}'),
      controller: _fields[field.key],
      enabled: !_controller.busy,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : field.multiline
              ? TextInputType.multiline
              : TextInputType.text,
      minLines: field.multiline ? 3 : 1,
      maxLines: field.multiline ? 8 : 1,
      decoration: InputDecoration(
        labelText: '${field.label}${field.required ? ' *' : ''}',
        helperText: field.key == 'franchise'
            ? 'Blank uploads null and clears any existing franchise.'
            : field.key == 'genres'
                ? 'Example: [{"id":28,"name":"Action"}]. Use [] for no genres.'
                : field.type == MovieEditorFieldType.date
                    ? 'YYYY-MM-DD, or blank for null'
                    : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _warnings(List<String> warnings, String storageKey) => warnings.isEmpty
      ? const SizedBox.shrink()
      : ExpansionTile(
          key: PageStorageKey<String>(storageKey),
          title: Text('Warnings (${warnings.length})'),
          children: [
            for (var index = 0; index < warnings.length; index++)
              ListTile(
                title: SelectableText(
                  warnings[index],
                  key: PageStorageKey<String>('$storageKey-text-$index'),
                ),
              ),
          ],
        );

  Widget _movieTab() {
    return ListView(
      key: const PageStorageKey('movie-editor-fields'),
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 240,
              child: TextField(
                key: const PageStorageKey<String>('movie-editor-id-input'),
                controller: _movieId,
                enabled: !_controller.busy,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _fetch(),
                decoration: const InputDecoration(labelText: 'TMDB movie ID', border: OutlineInputBorder()),
              ),
            ),
            FilledButton.icon(
              onPressed: _controller.busy ? null : _fetch,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Fetch movie'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Fetching replaces this editor with the requested movie. '
            'Fields marked * are required. Movie uploads never upload people.'),
        if (_controller.hasMovie) ...[
          const SizedBox(height: 16),
          Text('Editing TMDB movie ${_controller.movieId}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth >= 700 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final field in movieEditorFields)
                  SizedBox(width: field.multiline ? constraints.maxWidth : width, child: _movieField(field)),
              ],
            );
          }),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _controller.busy
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      _controller.uploadMovie({
                        for (final entry in _fields.entries) entry.key: entry.value.text,
                      });
                    },
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Upload edited movie and genres'),
            ),
          ),
          if (_controller.movieMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SelectableText(
                _controller.movieMessage!,
                key: const PageStorageKey<String>('movie-editor-result-text'),
              ),
            ),
          _warnings(_controller.movieWarnings, 'movie-editor-movie-warnings'),
          ExpansionTile(
            key: const PageStorageKey<String>('movie-editor-tmdb-extras'),
            title: const Text('Additional TMDB information (read-only)'),
            subtitle: const Text('All remaining response fields are shown here. '
                'They have no columns in the current database and are not uploaded.'),
            children: [
              for (final entry in _extraFields.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: TextFormField(
                    key: PageStorageKey<String>('movie-editor-extra-$_fetchRevision-${entry.key}'),
                    initialValue: entry.value,
                    readOnly: true,
                    minLines: 1,
                    maxLines: 6,
                    decoration: InputDecoration(labelText: entry.key, border: const OutlineInputBorder()),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  List<MovieCreditPerson> _filter(List<MovieCreditPerson> people) {
    final query = _search.text.trim().toLowerCase();
    return people
        .where((person) =>
            query.isEmpty ||
            person.name.toLowerCase().contains(query) ||
            person.id.contains(query) ||
            person.details.toLowerCase().contains(query))
        .toList();
  }

  Widget _peopleHeader(String kind, List<MovieCreditPerson> people) {
    final selection = kind == 'cast' ? _controller.selectedCast : _controller.selectedCrew;
    final count = kind == 'cast' ? _castCount : _crewCount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('${kind == 'cast' ? 'Cast' : 'Crew'}: ${selection.length}/${people.length} selected',
              style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            width: 145,
            child: TextField(
              key: PageStorageKey<String>('movie-editor-$kind-count-input'),
              controller: count,
              enabled: !_controller.busy,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of people'),
              onSubmitted: (_) => _controller.selectFirst(kind, count.text),
            ),
          ),
          OutlinedButton(
            onPressed: _controller.busy ? null : () => _controller.selectFirst(kind, count.text),
            child: const Text('Select first N'),
          ),
          TextButton(
            onPressed: _controller.busy ? null : () => _controller.selectFirst(kind, '0'),
            child: const Text('Clear selection'),
          ),
        ],
      ),
    );
  }

  Widget _personTile(MovieCreditPerson person, String kind) {
    final selection = kind == 'cast' ? _controller.selectedCast : _controller.selectedCrew;
    final result = _controller.peopleResults[person.id];
    final status = result?.status ?? PersonUploadStatus.pending;
    final scheme = Theme.of(context).colorScheme;
    final color = status == PersonUploadStatus.failed
        ? scheme.error
        : status == PersonUploadStatus.success || status == PersonUploadStatus.alreadyExists
            ? scheme.primary
            : scheme.onSurfaceVariant;
    return CheckboxListTile(
      key: ValueKey('$kind-${person.id}'),
      title: Text('${person.name} • TMDB ${person.id}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(person.details),
          Text(status.label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          if (result != null) Text(result.message),
        ],
      ),
      value: selection.contains(person.id),
      onChanged: _controller.busy ? null : (selected) => _controller.selectPerson(kind, person.id, selected == true),
      secondary: status == PersonUploadStatus.uploading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : null,
    );
  }

  Widget _peopleTab() {
    if (!_controller.hasMovie) {
      return const Center(child: Text('Fetch a movie in Movie Info first.'));
    }
    final cast = _filter(_controller.cast);
    final crew = _filter(_controller.crew);
    return CustomScrollView(
      key: const PageStorageKey('movie-editor-people'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('People for TMDB movie ${_controller.movieId}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Upload the movie first. Choose unique cast/crew people manually '
                    'or select the first N. Cast follows TMDB order; crew follows response order. '
                    'All roles/jobs in selected sections are uploaded. A person in both '
                    'sections is processed once. Existing profiles are not overwritten. '
                    'Changing selection does not delete stored credits.'),
                const SizedBox(height: 12),
                TextField(
                  key: const PageStorageKey<String>('movie-editor-search-input'),
                  controller: _search,
                  decoration: const InputDecoration(
                      labelText: 'Filter people by name, ID or role', prefixIcon: Icon(Icons.search)),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _controller.busy || _controller.selectedPeople.isEmpty
                          ? null
                          : () => _controller.uploadPeople(),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: Text('Upload selected people (${_controller.selectedPeople.length})'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          _controller.busy || _controller.selectedPeople.intersection(_controller.failedPeople).isEmpty
                              ? null
                              : () => _controller.uploadPeople(retryFailed: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry selected failed people'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_controller.peopleMessage),
                Text('Processed ${_controller.completedPeople}/${_controller.totalPeople}; '
                    'up to ${MovieEditorController.parallelUploads} concurrent people.'),
                _warnings(_controller.peopleWarnings, 'movie-editor-people-warnings'),
                _peopleHeader('cast', _controller.cast),
              ],
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
          (context, index) => _personTile(cast[index], 'cast'),
          childCount: cast.length,
        )),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(child: _peopleHeader('crew', _controller.crew)),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
          (context, index) => _personTile(crew[index], 'crew'),
          childCount: crew.length,
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => PopScope(
        canPop: !_controller.busy || _allowPop,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _leave();
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Movie ID editor'),
              bottom: const TabBar(tabs: [
                Tab(text: 'Movie Info'),
                Tab(text: 'People Info'),
              ]),
              actions: [
                if (_controller.busy) TextButton(onPressed: _controller.cancel, child: const Text('Cancel')),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  if (_controller.busy) const LinearProgressIndicator(),
                  const ExpansionTile(
                    key: PageStorageKey<String>('movie-editor-upload-setup'),
                    title: Text('Anonymous upload setup / public access warning'),
                    childrenPadding: EdgeInsets.all(12),
                    children: [Text(AppwriteMcuImportService.setupNotice)],
                  ),
                  if (_controller.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SelectableText(_controller.error!,
                          key: const PageStorageKey<String>('movie-editor-error-text'),
                          style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  Expanded(child: TabBarView(children: [_movieTab(), _peopleTab()])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
