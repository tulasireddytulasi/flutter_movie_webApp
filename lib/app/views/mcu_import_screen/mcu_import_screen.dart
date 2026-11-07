import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/appwrite_mcu_import_service.dart';
import 'package:moviewebapp/app/providers/mcu_import_controller.dart';

class McuImportScreen extends StatefulWidget {
  const McuImportScreen({Key? key, this.controller}) : super(key: key);

  final McuImportController? controller;

  @override
  State<McuImportScreen> createState() => _McuImportScreenState();
}

class _McuImportScreenState extends State<McuImportScreen> {
  late final McuImportController _controller;
  bool _allowPop = false;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? McuImportController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else if (_controller.busy) {
      _controller.cancel();
    }
    super.dispose();
  }

  Future<void> _leave() async {
    if (_confirming) return;
    _confirming = true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel import and leave?'),
        content: const Text(
          'An in-flight operation will finish. Stored rows are kept, and '
          'the next import can repair partial uploads without duplicate credits.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel and leave')),
        ],
      ),
    );
    _confirming = false;
    if (leave != true || !mounted) return;
    _controller.cancel();
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _start({bool retry = false}) async {
    if (_controller.busy || _confirming) return;
    final ids =
        Set<String>.of(retry ? _controller.retryIds : _controller.selectedIds);
    if (ids.isEmpty) return;
    _confirming = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Import ${ids.length} MCU movie${ids.length == 1 ? '' : 's'}?'),
        content: const Text(
          'Fetch current TMDB details, complete cast and crew, and full profiles '
          'for every credited person. Upload genres and people first, movies '
          'with franchise=mcu second, then cast and crew.\n\n'
          'Existing rows are refreshed. No rows are deleted. Start with one '
          'movie to verify your setup. Anonymous create/read/update permissions '
          'must already be configured in Appwrite.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Fetch and upload')),
        ],
      ),
    );
    _confirming = false;
    if (confirmed == true && mounted) await _controller.run(ids: ids);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final busy = _controller.busy;
        final selected = _controller.selectedIds.length;
        return PopScope(
          canPop: !busy || _allowPop,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _leave();
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('MCU import')),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Marvel movie data upload',
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('${_controller.movies.length} local seed movies. '
                      'All cast/crew and full people profiles are included.'),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('franchise = mcu')),
                      Chip(label: Text('No authentication')),
                    ],
                  ),
                  Text('Database: ${AppwriteMcuImportService.databaseId}\n'
                      'Movies table: ${AppwriteMcuImportService.tableIds['movies']}'),
                  const SizedBox(height: 12),
                  Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Temporary public access: anyone can insert or change your data. '
                        'Revoke Any create/update permissions after importing.',
                        style: TextStyle(
                            color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ),
                  const ExpansionTile(
                    title: Text('Appwrite setup and schema checks'),
                    childrenPadding: EdgeInsets.all(16),
                    children: [Text(AppwriteMcuImportService.setupNotice)],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed:
                            busy || selected == 0 ? null : () => _start(),
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: Text('Import selected ($selected)'),
                      ),
                      OutlinedButton.icon(
                        onPressed: busy || _controller.retryIds.isEmpty
                            ? null
                            : () => _start(retry: true),
                        icon: const Icon(Icons.refresh),
                        label: Text(
                            'Retry unfinished (${_controller.retryIds.length})'),
                      ),
                      if (busy)
                        TextButton(
                          onPressed: _controller.cancel,
                          child: const Text('Cancel import'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (busy) ...[
                    LinearProgressIndicator(
                      value: _controller.total == 0
                          ? null
                          : _controller.processed / _controller.total,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(_controller.stage, key: const ValueKey('mcu-stage')),
                  Text(
                      'Movies processed: ${_controller.processed}/${_controller.total} • '
                      'People fetched: ${_controller.peopleFetched}/${_controller.peopleKnown}'),
                  if (_controller.writes.isNotEmpty)
                    Text(
                        'Verified writes this run: ${_controller.writes.entries.map((e) => '${e.key}: ${e.value}').join(', ')}'),
                  if (_controller.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SelectableText(
                        _controller.error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  if (_controller.warnings.isNotEmpty)
                    ExpansionTile(
                      title: Text('Warnings (${_controller.warnings.length})'),
                      children: [
                        for (final warning in _controller.warnings)
                          ListTile(title: SelectableText(warning)),
                      ],
                    ),
                  const Divider(),
                  CheckboxListTile(
                    title: const Text('Select all seed movies'),
                    value: selected == _controller.movies.length,
                    tristate: false,
                    onChanged: busy
                        ? null
                        : (value) => _controller.selectAll(value == true),
                  ),
                  for (final movie in _controller.movies)
                    CheckboxListTile(
                      key: ValueKey('mcu-${movie.id}'),
                      isThreeLine: _controller.results.containsKey(movie.id),
                      title: Text(movie.title),
                      subtitle: Text(
                        'TMDB ${movie.id}'
                        '${_controller.results[movie.id] == null ? '' : '\n${_controller.results[movie.id]!.status.name}: ${_controller.results[movie.id]!.message}'}',
                      ),
                      secondary: movie.posterPath == null
                          ? const Icon(Icons.movie_outlined)
                          : Image.network(
                              'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                              width: 40,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stack) => const Tooltip(
                                message: 'Poster preview unavailable',
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                      value: _controller.selectedIds.contains(movie.id),
                      onChanged: busy
                          ? null
                          : (value) =>
                              _controller.select(movie.id, value == true),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
