import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:moviewebapp/app/providers/navigation_provider.dart';
import 'package:moviewebapp/app/views/bottom_sheet/bottom_sheet_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/movie_info.dart';
import 'package:moviewebapp/app/views/youtube_player_screen/widgets/mobile_youtube_player.dart';
import 'package:provider/provider.dart';

class Navigation {
  /// Navigated from DashboardScreen or All Movies Screen to Movies Info Screen
  navigateToMoviesInfoPage({required BuildContext context, required String movieId, required double screenWidth}) {
    if (screenWidth >= 600) {
      final NavigationProvider navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
      navigationProvider.setMovieInfoScreen(movieId: movieId);
      navigationProvider.setCurrentScreenIndex(currentScreenIndex: 0);
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          isDismissible: true,
          enableDrag: false,
          elevation: 0,
          //  barrierColor: Colors.black.withAlpha(1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(50))),
          builder: (context) {
            return Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
                minHeight: 300,
              ),
              child: const BottomSheetWidget(),
            );
          });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieInfoScreen(movieId: movieId),
        ),
      );
    }
  }

  /// Navigated from Actors Info Screen to Movies Info Screen
  navigateFromActorInfoScreenToMoviesInfoPage({
    required BuildContext context,
    required String movieId,
    required double screenWidth,
  }) {
    if (screenWidth >= 600) {
      final movieInfoProvider = Provider.of<MovieInfoProvider>(context, listen: false);
      final movieProvider = Provider.of<MoviesProvider>(context, listen: false);
      final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

      if (navigationProvider.currentScreenIndex == 1) {
        navigationProvider.setMovieInfoScreen(movieId: movieId);
        navigationProvider.setCurrentScreenIndex(currentScreenIndex: 0);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        movieInfoProvider.addPreviousMoviesIds(movieId: movieInfoProvider.currentMovieId);
        movieInfoProvider.getMoviesInfoAPI(movieId: movieId, appendToResponse: "credits");
        movieProvider.getSimilarMoviesAPI(movieId: movieId);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MovieInfoScreen(movieId: movieId)),
      );
    }
  }

  updateMovieInfoScreen({
    required BuildContext context,
    required String movieId,
    required bool canNavigateToNewPage,
    required ScrollController? scrollController,
  }) {
    if (canNavigateToNewPage) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MovieInfoScreen(movieId: movieId)),
      );
    } else {
      final movieInfoProvider = Provider.of<MovieInfoProvider>(context, listen: false);
      final movieProvider = Provider.of<MoviesProvider>(context, listen: false);
      final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

      if (navigationProvider.currentScreenIndex == 1) {
        navigationProvider.setMovieInfoScreen(movieId: movieId);
        navigationProvider.setCurrentScreenIndex(currentScreenIndex: 0);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        movieInfoProvider.addPreviousMoviesIds(movieId: movieInfoProvider.currentMovieId);
        await movieInfoProvider.getMoviesInfoAPI(movieId: movieId, appendToResponse: "credits");
        await movieProvider.getSimilarMoviesAPI(movieId: movieId);
        await movieInfoProvider.getMovieVideos(movieId: movieId);
        movieInfoProvider.getMovieReviewsInfoAPI(movieId: movieId, pageNo: "1");
      });
      if (scrollController != null) {
        scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
      }
    }
  }

  void youTubeScreen({required BuildContext context, required String youTubeVideoKey}) {
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
