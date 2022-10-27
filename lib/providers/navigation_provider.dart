import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/actors_page/actors_page.dart';
import 'package:moviewebapp/pages/movie_info_screen/movie_info.dart';

class NavigationProvider extends ChangeNotifier {
  String _currentMovieId = "";
  String get currentMovieId => _currentMovieId;

  String _currentActorId = "";
  String get currentActorId => _currentActorId;

  int _currentScreenIndex = 0;
  int get currentScreenIndex => _currentScreenIndex;

  setCurrentScreenIndex({required int currentScreenIndex}) {
    _currentScreenIndex = currentScreenIndex;
    notifyListeners();
  }

  final List _screensList = [
    const MovieInfoScreen(movieId: ""),
    const ActorsPage(
      actorId: '1654001',
    ),
  ];
  List get screensList => _screensList;

  /// Updating [_screensList] variable
  setMovieInfoScreen({required String movieId}) {
    _screensList[0] = MovieInfoScreen(
      movieId: movieId,
    );
  }

  /// Updating [_screensList] variable
  setActorsPage({required String actorId}) {
    _screensList[1] = ActorsPage(
      actorId: actorId,
    );
  }
}
