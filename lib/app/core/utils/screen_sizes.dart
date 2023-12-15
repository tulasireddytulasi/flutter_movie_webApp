Map<String, dynamic> getActorCircularWidgetWidth(
    {required double screenWidth}) {
  int columns = 6;
  double ratio = 60;
  Map<String, dynamic> layoutData = {};
  if (screenWidth <= 1400 && screenWidth >= 1300) {
    columns = 6;
    ratio = 60;
  } else if (screenWidth <= 1300 && screenWidth >= 1200) {
    columns = 6;
    ratio = 60;
  } else if (screenWidth <= 1200 && screenWidth >= 1100) {
    columns = 6;
    ratio = 60;
  } else if (screenWidth <= 1100 && screenWidth >= 1000) {
    columns = 6;
    ratio = 60;
  } else if (screenWidth <= 1000 && screenWidth >= 800) {
    columns = 5;
    ratio = 60;
  } else if (screenWidth <= 800 && screenWidth >= 700) {
    columns = 5;
    ratio = 50;
  } else if (screenWidth <= 700 && screenWidth >= 600) {
    columns = 4;
    ratio = 50;
  } else if (screenWidth <= 600 && screenWidth >= 500) {
    columns = 4;
    ratio = 45;
  } else if (screenWidth <= 500 && screenWidth >= 450) {
    columns = 4;
    ratio = 38;
  } else if (screenWidth <= 450 && screenWidth >= 400) {
    columns = 3;
    ratio = 40;
  } else if (screenWidth <= 400 && screenWidth >= 350) {
    columns = 3;
    ratio = 40;
  } else if (screenWidth <= 350 && screenWidth >= 300) {
    columns = 3;
    ratio = 30;
  } else if (screenWidth <= 300 && screenWidth >= 250) {
    columns = 2;
    ratio = 40;
  } else if (screenWidth <= 250 && screenWidth >= 200) {
    columns = 2;
    ratio = 30;
  } else if (screenWidth <= 200 && screenWidth >= 100) {
    ratio = 50;
    columns = 1;
  }
  layoutData["columns"] = columns;
  layoutData["ratio"] = ratio;
  return layoutData;
}
