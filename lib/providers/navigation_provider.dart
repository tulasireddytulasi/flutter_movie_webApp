import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/actors_page/actors_page.dart';
import 'package:moviewebapp/pages/movie_info_screen/movie_info.dart';
import 'package:moviewebapp/utils/colors.dart';

class NavigationProvider extends ChangeNotifier {
  String _currentMovieId = "";
  String get currentMovieId => _currentMovieId;

  String _currentActorId = "";
  String get currentActorId => _currentActorId;

  int _currentScreenIndex = 0;
  int get currentScreenIndex => _currentScreenIndex;

  BlendMode? _blendMode;
  BlendMode? get blendMode => _blendMode;
  Color? _color;
  Color? get color => _color;
  Color _borderColor = WHITE;
  Color get borderColor => _borderColor;
  String _actorID = "";
  String get actorID => _actorID;

  setOnHover({required String actorID}) {
    // _blendMode = BlendMode.saturation;
    // _color = Colors.grey;
    _actorID = actorID;
    _borderColor = WHITE;
    notifyListeners();
  }

  setOutHover() {
    _blendMode = null;
    _color = null;
    _borderColor = tealishBlue;
    notifyListeners();
  }

  setCurrentScreenIndex({required int currentScreenIndex}) {
    _currentScreenIndex = currentScreenIndex;
    notifyListeners();
  }

  void notify() {
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
