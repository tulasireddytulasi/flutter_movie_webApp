import 'package:flutter/foundation.dart';
import 'package:moviewebapp/app/core/responses/appwrite_people_service.dart';

class PeopleProvider extends ChangeNotifier {
  PeopleProvider({AppwritePeopleService? peopleService})
      : _peopleService = peopleService ?? AppwritePeopleService();

  final AppwritePeopleService _peopleService;

  Future<AppwritePeoplePage> fetchPopularPeoplePage({String? cursorAfter}) =>
      _peopleService.fetchPopularPage(cursorAfter: cursorAfter);
}