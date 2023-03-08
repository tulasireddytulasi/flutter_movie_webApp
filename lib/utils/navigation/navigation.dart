import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/bottom_sheet/bottom_sheet_widget.dart';
import 'package:moviewebapp/pages/movie_info_screen/movie_info.dart';
import 'package:moviewebapp/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class Navigation {
  navigateToMoviesInfoPage(
      {required BuildContext context,
      required String movieId,
      required double screenWidth}) {
    if (screenWidth >= 600) {
      final NavigationProvider navigationProvider =
          Provider.of<NavigationProvider>(context, listen: false);
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
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(50))),
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
}