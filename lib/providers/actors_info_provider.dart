import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviewebapp/models/actor_images_model.dart';
import 'package:moviewebapp/models/actors_info_model.dart';
import 'package:moviewebapp/responses/movie_apis.dart';

class ActorsInfoProvider extends ChangeNotifier {
  ActorImagesModel _actorImagesModel = ActorImagesModel();

  ActorImagesModel get actorImagesModel => _actorImagesModel;

  ActorInfoModel _actorInfoModel = ActorInfoModel();

  ActorInfoModel get actorInfoModel => _actorInfoModel;

  final List<String> _actorsImages = [];

  List<String> get actorsImages => _actorsImages;

  String _biography = "";

  String get biography => _biography;

  String _profilePic = "";

  String get profilePic => _profilePic;

  String _actorName = "";

  String get actorName => _actorName;

  String _actorId = "";

  String get actorId => _actorId;

  String _dob = "";

  String get dob => _dob;

  String _role = "";

  String get role => _role;

  String _birthPlace = "";

  String get birthPlace => _birthPlace;

  String _gender = "";

  String get gender => _gender;

  String _homePage = "";

  String get homePage => _homePage;

  getActorsImagesAPI({required String actorId}) async {
    _actorsImages.clear();
    try {
      _actorImagesModel = await getPopularActorsImages(actorId: actorId);

      _actorImagesModel.profiles?.forEach((element) {
        if (element.filePath != null && element.filePath!.isNotEmpty) {
          _actorsImages.add(element.filePath!);
        }
      });
      log("_actorsImages: ${_actorsImages.toString()}");
    } catch (error) {
      log("_actorsImages error: ${error}");
    }
    notifyListeners();
  }

  getActorsInfoAPI({required String actorId}) async {
    try {
      _actorInfoModel = await getActorsInfo(actorId: actorId);
      _actorName = _actorInfoModel.name!;
      _actorId = _actorInfoModel.id.toString();
      _profilePic = _actorInfoModel.profilePath!;
      _biography = _actorInfoModel.biography!;
      if (_actorInfoModel.gender == 1) {
        _gender = "Female";
      } else if (_actorInfoModel.gender == 2) {
        _gender = "Male";
      }
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateTime movieReleaseDate =
          dateFormat.parse(_actorInfoModel.birthday!.toString());
      _dob = DateFormat('yyyy-MM-dd').format(movieReleaseDate);
      _birthPlace = _actorInfoModel.placeOfBirth!;
      _role = _actorInfoModel.knownForDepartment!;
      _homePage = _actorInfoModel.homepage;

      log("_actorsImages: ${_actorInfoModel.name}");
    } catch (error) {
      log("_actorsInfo error: $error");
    }
    notifyListeners();
  }
}
