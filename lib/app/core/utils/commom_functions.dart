Map<String, dynamic> getMovieCardWidth({required double screenWidth}) {
  double cardHeight = 0;
  int columns = 5;
  double childAspectRatio = 9 / 16;
  bool isMovieTitleVisible = false;
  double leftPadding = 5;
  double rightPadding = 5;
  double crossAxisSpacing = 5;
  double maxBottomSheetWidth = 600;
  Map<String, dynamic> layoutData = {};
  if (screenWidth >= 1700) {
    cardHeight = 2.8;
    columns = 8;
    isMovieTitleVisible = true;
    childAspectRatio = 9 / 16.0;
    leftPadding = 70;
    rightPadding = 70;
    crossAxisSpacing = 40;
    isMovieTitleVisible = true;
    maxBottomSheetWidth = 800;
  } else if (screenWidth <= 1700 && screenWidth >= 1400) {
    cardHeight = 2.8;
    columns = 6;
    isMovieTitleVisible = true;
    childAspectRatio = 9 / 16.0;
    leftPadding = 70;
    rightPadding = 70;
    crossAxisSpacing = 40;
    isMovieTitleVisible = true;
    maxBottomSheetWidth = 800;
  } else if (screenWidth <= 1400 && screenWidth >= 1300) {
    cardHeight = 2.8;
    columns = 6;
    isMovieTitleVisible = true;
    childAspectRatio = 9 / 16.0;
    leftPadding = 70;
    rightPadding = 70;
    crossAxisSpacing = 40;
    isMovieTitleVisible = true;
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
  layoutData["leftPadding"] = leftPadding;
  layoutData["rightPadding"] = rightPadding;
  layoutData["crossAxisSpacing"] = crossAxisSpacing;
  layoutData["maxBottomSheetWidth"] = maxBottomSheetWidth;

  return layoutData;
}

double getBottomSheetWidth({required double screenWidth}) {
  double cardWidth = 800;
  if (screenWidth >= 1700) {
    cardWidth = screenWidth / 2;
  } else if (screenWidth >= 1700 && screenWidth <= 1600) {
    cardWidth = 800;
  } else if (screenWidth >= 1400 && screenWidth <= 1600) {
    cardWidth = 800;
  } else if (screenWidth >= 700 && screenWidth <= 1400) {
    cardWidth = 800;
  } else if (screenWidth <= 700) {
    cardWidth = screenWidth;
  }
  return cardWidth;
}

double getFontSize({required double fontSize}) {
  if (fontSize >= 1300) {
    return 56;
  } else {
    return (fontSize * 0.04) + 4;
  }
}

double getCardWidth({required double cardSize}) {
  if (cardSize <= 350) {
    return 300;
  } else if (cardSize <= 450) {
    return cardSize / 1.1;
  } else if (cardSize <= 650) {
    return cardSize / 1.3;
  } else if (cardSize >= 1100) {
    return 550;
  } else {
    return cardSize / 2;
  }
}

double getCardHeight({required double cardSize}) {
  if (cardSize <= 350) {
    return 350;
  } else if (cardSize <= 450) {
    return cardSize / 1.2;
  } else if (cardSize <= 650) {
    return cardSize / 1.5;
  } else if (cardSize >= 1100) {
    return 550;
  } else {
    return cardSize / 2;
  }
}

double getMainTextSize({required double cardSize}) {
  double cardSize1 = cardSize;
  if (cardSize1 >= 650) {
    return cardSize1 / 3;
  } else {
    return cardSize1 / 1.5;
  }
}

double getActorImageSize({required double screenSize}) {
  if (screenSize >= 1360) {
    return 160;
  } else if (screenSize >= 900) {
    return 160;
  } else {
    return 100;
  }
}

double getActorImageRadius({required double screenSize}) {
  if (screenSize >= 900) {
    return 100;
  }
  return 50;
}

double getActorSectionHeight({required double screenSize}) {
  if (screenSize >= 1360) {
    return 200;
  } else if (screenSize >= 900) {
    return 200;
  } else {
    return 150;
  }
}

double getSimilarMoviesSectionHeight({required double screenSize}) {
  if (screenSize >= 900) {
    return 250;
  }
  return 180;
}

double getSimilarMoviesImageWidth({required double screenSize}) {
  if (screenSize >= 900) {
    return 150;
  }
  return 100;
}

double getSimilarMoviesImageHeight({required double screenSize}) {
  if (screenSize >= 900) {
    return 200;
  }
  return 130;
}

double getProfileImageSize({required double screenSize}) {
  if (screenSize >= 900) {
    return 160;
  }
  return 120;
}
