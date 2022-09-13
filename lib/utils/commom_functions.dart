List<double> getCardWidth({required double screenWidth}) {
  double cardHeight = 0;
  double columns = 5;
  List<double> screenValues = [];
  if (screenWidth >= 1300) {
    cardHeight = 2.8;
  } else if (screenWidth <= 1300 && screenWidth >= 1200) {
    cardHeight = 3.1;
  } else if (screenWidth <= 1200 && screenWidth >= 1100) {
    cardHeight = 3.4;
  } else if (screenWidth <= 1100 && screenWidth >= 1000) {
    cardHeight = 3.8;
    columns = 5;
  } else if (screenWidth <= 1000 && screenWidth >= 900) {
    cardHeight = 3.5;
    columns = 4;
  } else if (screenWidth <= 900 && screenWidth >= 800) {
    cardHeight = 3.0;
    columns = 3;
  } else if (screenWidth <= 800 && screenWidth >= 700) {
    cardHeight = 3.5;
    columns = 3;
  } else if (screenWidth <= 700 && screenWidth >= 600) {
    cardHeight = 4.3;
    columns = 3;
  } else if (screenWidth <= 600 && screenWidth >= 500) {
    cardHeight = 3.6;
    columns = 2;
  } else if (screenWidth <= 500 && screenWidth >= 450) {
    cardHeight = 4.7;
    columns = 2;
  } else if (screenWidth <= 450 && screenWidth >= 400) {
    cardHeight = 5.1;
    columns = 2;
  } else if (screenWidth <= 400 && screenWidth >= 380) {
    cardHeight = 2.6;
    columns = 1;
  } else if (screenWidth <= 380 && screenWidth >= 300) {
    cardHeight = 3.4;
    columns = 1;
  }

  screenValues.insert(0, cardHeight);
  screenValues.insert(1, columns);

  return screenValues;
}
