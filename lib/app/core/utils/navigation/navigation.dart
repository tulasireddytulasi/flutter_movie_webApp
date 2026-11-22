import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviewebapp/app/core/routing/app_router.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/providers/navigation_provider.dart';
import 'package:moviewebapp/app/views/youtube_player_screen/widgets/mobile_youtube_player.dart';
import 'package:provider/provider.dart';

class Navigation {
  /// Navigated from DashboardScreen or All Movies Screen to Movies Info Screen
  navigateToMoviesInfoPage({
    required BuildContext context,
    required String movieId,
    required double screenWidth,
    String title = 'movie',
  }) {
    context.push('/movie/${buildSeoSlug(movieId, title)}');
  }

  /// Navigated from Actors Info Screen to Movies Info Screen
  navigateFromActorInfoScreenToMoviesInfoPage({
    required BuildContext context,
    required String movieId,
    required double screenWidth,
    String title = 'movie',
  }) {
    context.push('/movie/${buildSeoSlug(movieId, title)}');
  }

  updateMovieInfoScreen({
    required BuildContext context,
    required String movieId,
    required bool canNavigateToNewPage,
    required ScrollController? scrollController,
  }) {
    if (canNavigateToNewPage) {
      context.push('/movie/${buildSeoSlug(movieId, 'movie')}');
    } else {
      final movieInfoProvider = Provider.of<MovieInfoProvider>(
        context,
        listen: false,
      );
      final navigationProvider = Provider.of<NavigationProvider>(
        context,
        listen: false,
      );

      if (navigationProvider.currentScreenIndex == 1) {
        navigationProvider.setMovieInfoScreen(movieId: movieId);
        navigationProvider.setCurrentScreenIndex(currentScreenIndex: 0);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        movieInfoProvider.addPreviousMoviesIds(
          movieId: movieInfoProvider.currentMovieId,
        );
        await movieInfoProvider.getMoviesInfoAPI(
          movieId: movieId,
          appendToResponse: "credits",
        );
        await movieInfoProvider.getMovieVideos(movieId: movieId);
        movieInfoProvider.getMovieReviewsInfoAPI(movieId: movieId, pageNo: "1");
      });
      if (scrollController != null) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    }
  }

  void youTubeScreen({
    required BuildContext context,
    required String youTubeVideoKey,
  }) {
    if (kIsWeb) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileYouTubePlayer(videoId: youTubeVideoKey),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileYouTubePlayer(videoId: youTubeVideoKey),
        ),
      );
    }
  }
}
