// Celebrity Gallery — editorial staggered masonry feed + immersive detail view.
//
// pubspec.yaml dependencies:
//   flutter_staggered_grid_view: ^0.7.0
//   cached_network_image: ^3.4.1
//   palette_generator: ^0.3.3+4
//   google_fonts: ^6.2.1
//
// Requires Flutter 3.27+ (uses Color.withValues). Replace _buildItems() with
// your real API when celebrity data is available.

import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';

void main() => runApp(const GalleryApp());

// ───────────────────────── Design tokens ─────────────────────────
class Tokens {
  static const obsidian = Color(0xFF09090B);
  static const charcoal = Color(0xFF18181B);
  static const gold = Color(0xFFD4AF37);
  static const text = Color(0xFFF1F5F9);
  static const textMuted = Color(0xFFE2E8F0);
  static const border = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const radius = 24.0;
  static const parallax = 0.15;
  static const transition = Duration(milliseconds: 375);
  static const curve = Cubic(0.16, 1, 0.3, 1);
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Tokens.obsidian,
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        ),
        home: const GalleryScreen(),
      );
}

// ───────────────────────── Model ─────────────────────────
class CelebItem {
  final int id;
  final String name;
  final String category;
  final String caption;
  final double ratio; // width / height
  final String url;
  const CelebItem(this.id, this.name, this.category, this.caption, this.ratio, this.url);
}

const _celebPhotos = <String, List<String>>{
  'Amala Paul': [
    'https://cdn.thefridaymovies.com/celebs/AmalaPaul%201.jpg',
    'https://cdn.thefridaymovies.com/celebs/AmalaPaul%202.jpg',
    'https://cdn.thefridaymovies.com/celebs/AmalaPaul%203.jpg',
    'https://cdn.thefridaymovies.com/celebs/AmalaPaul%204.jpg',
  ],
  'Dharsha Gupta': [
    'https://cdn.thefridaymovies.com/celebs/DharshaGupta%201.jpg',
    'https://cdn.thefridaymovies.com/celebs/DharshaGupta%202.jpg',
    'https://cdn.thefridaymovies.com/celebs/DharshaGupta%203.jpg',
    'https://cdn.thefridaymovies.com/celebs/DharshaGupta%204.jpg',
  ],
  'Ramya Ranganathan': [
    'https://cdn.thefridaymovies.com/celebs/RamyaRanganathan%201.jpg',
    'https://cdn.thefridaymovies.com/celebs/RamyaRanganathan%202.jpg',
    'https://cdn.thefridaymovies.com/celebs/RamyaRanganathan%203.jpg',
    'https://cdn.thefridaymovies.com/celebs/RamyaRanganathan%204.jpg',
  ],
  'Rashmika': [
    'https://cdn.thefridaymovies.com/celebs/Rashmikha%201.jpg',
    'https://cdn.thefridaymovies.com/celebs/Rashmikha%202.jpg',
    'https://cdn.thefridaymovies.com/celebs/Rashmikha%203.jpg',
    'https://cdn.thefridaymovies.com/celebs/Rashmikha%204.jpg',
  ],
  'Sam': [
    'https://cdn.thefridaymovies.com/celebs/Sam%201.jpg',
    'https://cdn.thefridaymovies.com/celebs/Sam%202.jpg',
    'https://cdn.thefridaymovies.com/celebs/Sam%203.jpg',
    'https://cdn.thefridaymovies.com/celebs/Sam%204.jpg',
  ],
  'Thamizhvani': [
    'https://cdn.thefridaymovies.com/celebs/Thamizhvani%201.jpg',
    'https://cdn.thefridaymovies.com/celebs/Thamizhvani%202.jpg',
    'https://cdn.thefridaymovies.com/celebs/Thamizhvani%203.jpg',
    'https://cdn.thefridaymovies.com/celebs/Thamizhvani%204.jpg',
  ],
};
const _tags = ['Red Carpet', 'Editorial', 'Candid', 'Portrait', 'Runway'];
// 1:1, 3:4, 2:3, 9:16
const _ratios = [1.0, 3 / 4, 2 / 3, 9 / 16];

List<CelebItem> _buildItems() {
  final items = <CelebItem>[];
  for (final celeb in _celebPhotos.entries) {
    for (final url in celeb.value) {
      final id = items.length;
      items.add(CelebItem(
        id,
        celeb.key,
        _tags[(id * 3) % _tags.length],
        'Captured at the season’s most talked-about evening.',
        _ratios[(id * 7 + id ~/ 3) % _ratios.length],
        url,
      ));
    }
  }
  return items;
}

// ───────────────────────── Palette cache ─────────────────────────
class PaletteCache {
  static final Map<String, Color> _colors = {};
  static final Map<String, Future<Color>> _pending = {};

  static Color? peek(String url) => _colors[url];

  static Future<Color> dominant(String url) {
    final hit = _colors[url];
    if (hit != null) return Future.value(hit);
    return _pending.putIfAbsent(url, () async {
      try {
        final palette = await PaletteGenerator.fromImageProvider(
          ResizeImage(CachedNetworkImageProvider(url), width: 96),
          maximumColorCount: 8,
        );
        final c = palette.vibrantColor?.color ?? palette.dominantColor?.color ?? Tokens.gold;
        return _colors[url] = c;
      } catch (_) {
        return _colors[url] = Tokens.charcoal;
      }
    });
  }
}

// ───────────────────────── Gallery screen ─────────────────────────
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _scroll = ScrollController();
  final List<CelebItem> _items = _buildItems();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _open(CelebItem item) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      transitionDuration: Tokens.transition,
      reverseTransitionDuration: Tokens.transition,
      pageBuilder: (_, anim, __) => DetailScreen(item: item, animation: anim),
      transitionsBuilder: (_, __, ___, child) => child, // detail drives its own motion
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('THE EDIT',
                            style: GoogleFonts.inter(
                                fontSize: 11, letterSpacing: 3, color: Tokens.gold, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Gallery',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 38, height: 1.05, color: Tokens.text, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const Icon(Icons.tune_rounded, color: Tokens.textMuted),
                ],
              ),
            ),
            Expanded(
              child: MasonryGridView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
                gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  return RepaintBoundary(
                    child: GalleryCard(
                      key: ValueKey(item.id),
                      item: item,
                      scroll: _scroll,
                      onTap: () => _open(item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Card ─────────────────────────
class GalleryCard extends StatefulWidget {
  final CelebItem item;
  final ScrollController scroll;
  final VoidCallback onTap;
  const GalleryCard({Key? key, required this.item, required this.scroll, required this.onTap}) : super(key: key);
  @override
  State<GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<GalleryCard> {
  Color? _color;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _color = PaletteCache.peek(widget.item.url);
    if (_color == null) {
      PaletteCache.dominant(widget.item.url).then((c) {
        if (mounted) setState(() => _color = c);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final glow = _color ?? Tokens.charcoal;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) => setState(() => _pressed = true),
      onLongPressEnd: (_) => setState(() => _pressed = false),
      onLongPressCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Backlit radial glow (long-press)
            Positioned.fill(
              left: -28,
              right: -28,
              top: -28,
              bottom: -28,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _pressed ? 1 : 0,
                  duration: const Duration(milliseconds: 260),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          glow.withValues(alpha: 0.55),
                          glow.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Card with ambient color-matched shadow
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                color: Tokens.charcoal,
                borderRadius: BorderRadius.circular(Tokens.radius),
                boxShadow: [
                  BoxShadow(
                    color: glow.withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: -4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Hero(
                tag: 'celeb-${item.id}',
                flightShuttleBuilder: heroShuttle(item),
                child: _CardFace(item: item, scroll: widget.scroll),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Morphs border-radius 24 → 0 (and back) during the Hero flight.
HeroFlightShuttleBuilder heroShuttle(CelebItem item) => (flightContext, animation, direction, fromCtx, toCtx) {
      return AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          final t = Curves.fastOutSlowIn.transform(animation.value.clamp(0, 1));
          return ClipRRect(
            borderRadius: BorderRadius.circular(Tokens.radius * (1 - t)),
            child: CachedNetworkImage(
              imageUrl: item.url,
              fit: BoxFit.cover,
              memCacheWidth: 600,
            ),
          );
        },
      );
    };

class _CardFace extends StatelessWidget {
  final CelebItem item;
  final ScrollController scroll;
  const _CardFace({required this.item, required this.scroll});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: item.ratio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Tokens.radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ParallaxImage(url: item.url, scroll: scroll),
                // Bottom gradient mask + name / tag
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xE6000000), Color(0x00000000)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.category.toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 9.5, letterSpacing: 1.8, color: Tokens.gold, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 18, height: 1.15, color: Tokens.text, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 1px hairline border
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Tokens.radius),
                border: Border.all(color: Tokens.border, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Parallax image ─────────────────────────
class _ParallaxImage extends StatelessWidget {
  final String url;
  final ScrollController scroll;
  const _ParallaxImage({required this.url, required this.scroll});

  @override
  Widget build(BuildContext context) {
    final viewportH = MediaQuery.sizeOf(context).height;
    const overscale = 1.3; // gives 0.15h of travel room per side

    return AnimatedBuilder(
      animation: scroll,
      builder: (ctx, child) {
        double dy = 0;
        final box = ctx.findRenderObject();
        if (box is RenderBox && box.attached && box.hasSize) {
          final centerY = box.localToGlobal(Offset(0, box.size.height / 2)).dy;
          // Image drifts at 0.15x of the card's distance from viewport centre,
          // i.e. 0.15x relative to scroll speed.
          dy = (centerY - viewportH / 2) * Tokens.parallax;
          final limit = box.size.height * (overscale - 1) / 2;
          dy = dy.clamp(-limit, limit);
        }
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Transform.scale(
        scale: overscale,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          memCacheWidth: 400,
          fadeInDuration: const Duration(milliseconds: 300),
          placeholder: (_, __) => const ColoredBox(color: Tokens.charcoal),
          errorWidget: (_, __, ___) => const ColoredBox(color: Tokens.charcoal),
        ),
      ),
    );
  }
}

// ───────────────────────── Detail screen ─────────────────────────
class DetailScreen extends StatefulWidget {
  final CelebItem item;
  final Animation<double> animation;
  const DetailScreen({Key? key, required this.item, required this.animation}) : super(key: key);
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  double _dy = 0;
  double _from = 0;
  late final AnimationController _snap;

  @override
  void initState() {
    super.initState();
    _snap = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))
      ..addListener(() => setState(() => _dy = _from * (1 - Curves.easeOutCubic.transform(_snap.value))));
  }

  @override
  void dispose() {
    _snap.dispose();
    super.dispose();
  }

  void _onEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (_dy.abs() > 140 || v.abs() > 900) {
      Navigator.of(context).pop(); // Hero flies back into its masonry slot
    } else {
      _from = _dy;
      _snap.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final h = MediaQuery.sizeOf(context).height;
    final drag = (_dy.abs() / (h * 0.5)).clamp(0.0, 1.0);
    final curved = CurvedAnimation(parent: widget.animation, curve: Tokens.curve);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) => _snap.stop(),
        onVerticalDragUpdate: (d) => setState(() => _dy += d.delta.dy),
        onVerticalDragEnd: _onEnd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Blurred, dimmed backdrop (σ = 15) over the gallery
            FadeTransition(
              opacity: curved,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: ColoredBox(
                  color: Tokens.obsidian.withValues(alpha: 0.85 * (1 - drag)),
                ),
              ),
            ),
            // Image tracks the finger and scales down
            Transform.translate(
              offset: Offset(0, _dy),
              child: Transform.scale(
                scale: 1 - drag * 0.3,
                child: Hero(
                  tag: 'celeb-${item.id}',
                  flightShuttleBuilder: heroShuttle(item),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Tokens.radius * drag),
                    child: CachedNetworkImage(
                      imageUrl: item.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      memCacheWidth: 1080,
                    ),
                  ),
                ),
              ),
            ),
            // Metadata fades in from the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 1 - drag,
                child: FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(curved),
                    child: _MetaPanel(item: item),
                  ),
                ),
              ),
            ),
            // Close
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FadeTransition(
                    opacity: curved,
                    child: IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.4),
                        foregroundColor: Tokens.text,
                      ),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPanel extends StatelessWidget {
  final CelebItem item;
  const _MetaPanel({required this.item});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xF2000000), Color(0x00000000)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.category.toUpperCase(),
                  style: GoogleFonts.inter(
                      fontSize: 11, letterSpacing: 2.4, color: Tokens.gold, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(item.name,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 34, height: 1.08, color: Tokens.text, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Text(item.caption, style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: Tokens.textMuted)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _GoldButton(icon: Icons.favorite_border_rounded, label: 'Save'),
                  const SizedBox(width: 12),
                  _GoldButton(icon: Icons.ios_share_rounded, label: 'Share'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GoldButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Tokens.gold,
          side: const BorderSide(color: Tokens.gold, width: 1),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      );
}
