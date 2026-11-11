import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';

class MoviesCard extends StatefulWidget {
  const MoviesCard({
    Key? key,
    required this.poster,
    required this.movieName,
    required this.movieId,
    required this.voidCallback,
  }) : super(key: key);

  final String poster;
  final String movieName;
  final String movieId;
  final VoidCallback voidCallback;

  static double widthFor(double screenWidth) =>
      ((screenWidth - 32) / (screenWidth < 600 ? 3.25 : 7.25)).clamp(88.0, 164.0).toDouble();

  @override
  State<MoviesCard> createState() => _MoviesCardState();
}

class _MoviesCardState extends State<MoviesCard> with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;
  bool _hovered = false;
  bool _focused = false;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _scale = Tween<double>(begin: 1, end: .94).animate(CurvedAnimation(
      parent: _press,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutBack,
    ));
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  void _down() {
    if (!_opening && !_reduceMotion) _press.forward();
  }

  void _cancel() {
    if (!_opening) _press.reverse();
  }

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    if (!_reduceMotion) {
      await _press.forward();
      if (!mounted) return;
      await _press.reverse();
      if (!mounted) return;
    }
    widget.voidCallback();
    if (mounted) _opening = false;
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_movies_outlined, size: 28),
              const SizedBox(height: 8),
              Text(widget.movieName,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
    return SizedBox(
      width: MoviesCard.widthFor(MediaQuery.of(context).size.width),
      child: Center(
        child: Tooltip(
          message: widget.movieName,
          child: Semantics(
            label: widget.movieName,
            button: true,
            child: ScaleTransition(
              scale: _scale,
              child: AnimatedScale(
                scale: (_hovered || _focused) && !_reduceMotion ? 1.025 : 1,
                duration: _reduceMotion ? Duration.zero : const Duration(milliseconds: 160),
                child: AnimatedContainer(
                  duration: _reduceMotion ? Duration.zero : const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _hovered || _focused ? theme.colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: InkWell(
                        onTap: _open,
                        onTapDown: (_) => _down(),
                        onTapCancel: _cancel,
                        onHover: (value) => setState(() => _hovered = value),
                        onFocusChange: (value) => setState(() => _focused = value),
                        child: ExcludeSemantics(
                          child: AspectRatio(
                            aspectRatio: 2 / 3,
                            child: widget.poster.startsWith('/') && !widget.poster.startsWith('//')
                                ? Image.network(
                                    ApiConstants.movieImageBaseUrlw500 + widget.poster,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) => progress == null ? child : placeholder,
                                    errorBuilder: (_, __, ___) => placeholder,
                                  )
                                : placeholder,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
