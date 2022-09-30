Map<String, dynamic> getCardWidth({required double screenWidth}) {
  double cardHeight = 0;
  double columns = 7;
  double childAspectRatio = 9 / 16;
  bool isMovieTitleVisible = false;
  Map<String, dynamic> layoutData = {};
  if (screenWidth >= 1300) {
    cardHeight = 2.8;
    columns = 7;
    isMovieTitleVisible = true;
    childAspectRatio = 9 / 15.6;
  } else if (screenWidth <= 1300 && screenWidth >= 1200) {
    cardHeight = 3.1;
    isMovieTitleVisible = true;
  } else if (screenWidth <= 1200 && screenWidth >= 1100) {
    cardHeight = 3.4;
    isMovieTitleVisible = true;
  } else if (screenWidth <= 1100 && screenWidth >= 1000) {
    cardHeight = 3.8;
    columns = 5;
    isMovieTitleVisible = true;
    childAspectRatio = 9 / 15.6;
  } else if (screenWidth <= 1000 && screenWidth >= 900) {
    cardHeight = 3.5;
    columns = 5;
    isMovieTitleVisible = true;
    childAspectRatio = 9 / 15.6;
  } else if (screenWidth <= 900 && screenWidth >= 800) {
    cardHeight = 3.0;
    columns = 5;
    childAspectRatio = 9 / 13.4;
  } else if (screenWidth <= 800 && screenWidth >= 700) {
    cardHeight = 3.5;
    columns = 4;
    childAspectRatio = 9 / 13.4;
  } else if (screenWidth <= 700 && screenWidth >= 600) {
    cardHeight = 4.3;
    columns = 4;
    childAspectRatio = 9 / 13.3;
  } else if (screenWidth <= 600 && screenWidth >= 500) {
    cardHeight = 3.6;
    columns = 4;
    isMovieTitleVisible = false;
    childAspectRatio = 9 / 13.3;
  } else if (screenWidth <= 500 && screenWidth >= 450) {
    cardHeight = 4.7;
    columns = 3;
    childAspectRatio = 9 / 13.3;
  } else if (screenWidth <= 450 && screenWidth >= 400) {
    cardHeight = 5.1;
    columns = 3;
    isMovieTitleVisible = false;
    childAspectRatio = 9 / 13.3;
  } else if (screenWidth <= 400 && screenWidth >= 380) {
    cardHeight = 2.6;
    columns = 3;
    childAspectRatio = 9 / 13.3;
    isMovieTitleVisible = false;
  } else if (screenWidth <= 380 && screenWidth >= 300) {
    cardHeight = 7.0;
    columns = 3;
    childAspectRatio = 9 / 13.3;
    isMovieTitleVisible = false;
  } else if (screenWidth <= 300 && screenWidth >= 200) {
    cardHeight = 7.0;
    columns = 2;
    childAspectRatio = 9 / 13.3;
    isMovieTitleVisible = false;
  } else if (screenWidth <= 200 && screenWidth >= 100) {
    cardHeight = 7.0;
    columns = 1;
    childAspectRatio = 9 / 13.4;
    isMovieTitleVisible = false;
  }

  layoutData["cardHeight"] = cardHeight;
  layoutData["columns"] = columns;
  layoutData["childAspectRatio"] = childAspectRatio;
  layoutData["isMovieTitleVisible"] = isMovieTitleVisible;

  return layoutData;
}

double getCardWidth2({required double screenWidth}) {
  double cardWidth = 0;
  if (screenWidth >= 1600) {
    cardWidth = 700;
  } else if (screenWidth >= 1400 && screenWidth <= 1600) {
    cardWidth = 500;
  } else if (screenWidth >= 700 && screenWidth <= 1400) {
    cardWidth = 800;
  } else if (screenWidth <= 700) {
    cardWidth = screenWidth;
  }
  return cardWidth;
}
