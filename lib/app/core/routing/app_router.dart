import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviewebapp/app/core/routing/detail_navigation.dart';
import 'package:moviewebapp/app/views/actors_page/actors_page.dart';
import 'package:moviewebapp/app/views/all_actors_page/all_actors_page.dart';
import 'package:moviewebapp/app/views/all_movies_screen/movies_list_screen.dart';
import 'package:moviewebapp/app/views/blogs_screen/blogs_screen.dart';
import 'package:moviewebapp/app/views/dashboard/dashboard.dart';
import 'package:moviewebapp/app/views/movie_info_screen/movie_info.dart';
import 'package:moviewebapp/app/views/navigation_menu/navigation_menu.dart';

String buildSeoSlug(String id, String text) {
  final slug = text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return '$id-${slug.isEmpty ? 'details' : slug}';
}

String extractRowId(String slugParam) => slugParam.split('-').first;

const String detailPresentationExtra = 'detailPresentation';
const String detailPresentationModal = 'modal';

class DialogPage<T> extends Page<T> {
  const DialogPage({
    required this.child,
    this.barrierColor = const Color(0x80000000),
  });

  final Widget child;
  final Color? barrierColor;

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      barrierColor: barrierColor,
      barrierDismissible: true,
      builder: (_) => child,
    );
  }
}

CustomTransitionPage<void> bottomSheetPage({
  required LocalKey key,
  required Widget child,
  required BuildContext context,
}) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  final modalWidth = screenWidth >= 900 ? 900.0 : screenWidth * 0.9;

  return CustomTransitionPage<void>(
    key: key,
    opaque: false,
    barrierDismissible: true,
    barrierColor: const Color(0x80000000),
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: modalWidth,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: child,
        ),
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Search')));
  }
}

class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({super.key, required this.blogId});

  final String blogId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => handleDetailClose(context, fallbackRoute: '/blogs'),
        ),
        title: const Text('Blog'),
        actions: [
          if (context.canPop())
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () =>
                  handleDetailClose(context, fallbackRoute: '/blogs'),
            ),
        ],
      ),
      body: Center(child: Text('Blog $blogId')),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/movie/:slug',
      pageBuilder: (context, state) {
        final movieId = extractRowId(state.pathParameters['slug']!);
        final screenWidth = MediaQuery.sizeOf(context).width;
        final extra = state.extra;
        final presentation = extra is Map
            ? extra[detailPresentationExtra]?.toString()
            : null;
        final pushedDesktopModal =
            kIsWeb &&
            screenWidth >= 600 &&
            presentation == detailPresentationModal;
        final child = MovieInfoScreen(
          movieId: movieId,
          fullPage: !pushedDesktopModal,
        );
        if (pushedDesktopModal) {
          return bottomSheetPage(
            key: state.pageKey,
            child: child,
            context: context,
          );
        }
        return MaterialPage(child: child);
      },
    ),
    GoRoute(
      path: '/people/:slug',
      pageBuilder: (context, state) {
        final personId = extractRowId(state.pathParameters['slug']!);
        final screenWidth = MediaQuery.sizeOf(context).width;
        final extra = state.extra;
        final presentation = extra is Map
            ? extra[detailPresentationExtra]?.toString()
            : null;
        final pushedDesktopModal =
            kIsWeb &&
            screenWidth >= 600 &&
            presentation == detailPresentationModal;
        final child = ActorsPage(
          actorId: personId,
          fullPage: !pushedDesktopModal,
        );
        if (pushedDesktopModal) {
          return bottomSheetPage(
            key: state.pageKey,
            child: child,
            context: context,
          );
        }
        return MaterialPage(child: child);
      },
    ),
    GoRoute(
      path: '/blog/:slug',
      pageBuilder: (context, state) {
        final blogId = extractRowId(state.pathParameters['slug']!);
        final child = BlogDetailScreen(blogId: blogId);
        final extra = state.extra;
        final presentation = extra is Map
            ? extra[detailPresentationExtra]?.toString()
            : null;
        final pushedDesktopModal =
            kIsWeb &&
            MediaQuery.sizeOf(context).width >= 600 &&
            presentation == detailPresentationModal;
        if (pushedDesktopModal) {
          return bottomSheetPage(
            key: state.pageKey,
            child: child,
            context: context,
          );
        }
        return MaterialPage(child: child);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationMenu(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const Dashboard()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/movies',
              builder: (context, state) => const MovieListScreen(
                withOriginalLanguage: 'en',
                movieType: 'popular',
                withGenres: '',
                screenTitle: 'Popular Movies',
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/people',
              builder: (context, state) => const AllActorsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/blogs',
              builder: (context, state) => const BlogsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
