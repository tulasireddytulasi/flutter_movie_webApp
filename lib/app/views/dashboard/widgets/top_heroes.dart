import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/routing/app_router.dart';
import 'package:moviewebapp/app/models/popular_actors_model.dart';
import 'package:moviewebapp/app/providers/people_provider.dart';
import 'package:provider/provider.dart';

class TopHeroes extends StatefulWidget {
  const TopHeroes({super.key});

  @override
  State<TopHeroes> createState() => _TopHeroesState();
}

class _TopHeroesState extends State<TopHeroes> {
  static const _pageSize = 4;
  final _pageController = PageController();
  final List<Actors> _actors = [];
  String? _nextCursor;
  bool _loading = false;
  bool _hasMore = true;
  bool _hasError = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final result = await context
          .read<PeopleProvider>()
          .fetchPopularPeoplePage(cursorAfter: _nextCursor, actingOnly: true);
      if (!mounted) return;
      setState(() {
        _actors.addAll(result.actors);
        _nextCursor = result.nextCursor;
        _hasMore = result.nextCursor != null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE32636);
    final pageCount = (_actors.length / _pageSize).ceil();
    return Container(
      color: const Color(0xFF10090A),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 4,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Text(
                  'Top HollyWood Actors',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_actors.isEmpty && _loading)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator(color: accent)),
            )
          else if (_actors.isEmpty && _hasError)
            _errorMessage()
          else if (_actors.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'No actors found.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 600 ? 2 : 4;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;
                final cardHeight = math.min(cardWidth * 1.35, 360.0);
                final rows = columns == 2 ? 2 : 1;
                return SizedBox(
                  height: rows * cardHeight + (rows - 1) * 10,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pageCount,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                      if (page >= pageCount - 1 && !_hasError) _loadMore();
                    },
                    itemBuilder: (context, page) {
                      final start = page * _pageSize;
                      final end = math.min(start + _pageSize, _actors.length);
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: cardHeight,
                        ),
                        itemCount: end - start,
                        itemBuilder: (context, index) =>
                            _ActorTile(actor: _actors[start + index]),
                      );
                    },
                  ),
                );
              },
            ),
          if (pageCount > 1)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  for (int page = 0; page < math.min(pageCount, 5); page++)
                    Container(
                      width: 24,
                      height: 4,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: page == _currentPage % 5
                            ? accent
                            : const Color(0xFF574044),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Previous actors',
                    onPressed: _currentPage > 0
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          )
                        : null,
                    color: Colors.white,
                    disabledColor: Colors.white24,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    tooltip: 'Next actors',
                    onPressed: _currentPage < pageCount - 1
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          )
                        : null,
                    color: Colors.white,
                    disabledColor: Colors.white24,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          if (_actors.isNotEmpty && _loading)
            const Center(child: CircularProgressIndicator(color: accent))
          else if (_actors.isNotEmpty && _hasError)
            _errorMessage(),
        ],
      ),
    );
  }

  Widget _errorMessage() => Center(
    child: Column(
      children: [
        const Text(
          'Unable to load actors.',
          style: TextStyle(color: Colors.white),
        ),
        TextButton(onPressed: _loadMore, child: const Text('Retry')),
      ],
    ),
  );
}

class _ActorTile extends StatelessWidget {
  const _ActorTile({required this.actor});

  final Actors actor;

  @override
  Widget build(BuildContext context) {
    final name = actor.name ?? 'Unknown actor';
    final path = actor.profilePath;
    return Material(
      color: const Color(0xFF211013),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: actor.id == null
            ? null
            : () => context.push(
                '/people/${buildSeoSlug(actor.id.toString(), name)}',
                extra: const {detailPresentationExtra: detailPresentationModal},
              ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (path != null && path.isNotEmpty)
              Image.network(
                '${ApiConstants.movieImageBaseUrlw500}$path',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
              )
            else
              const _ImagePlaceholder(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x18C90017),
                    Color(0x26000000),
                    Color(0xF2000000),
                  ],
                  stops: [0, 0.48, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) => const Center(
    child: Icon(Icons.person, color: Color(0xFF86565B), size: 48),
  );
}
