import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:moviewebapp/utils/constants.dart';
import 'package:provider/provider.dart';

import 'widgets/movie_card.dart';

class MovieHomePage extends StatefulWidget {
  const MovieHomePage({Key? key}) : super(key: key);

  @override
  _MovieHomePageState createState() => _MovieHomePageState();
}

class _MovieHomePageState extends State<MovieHomePage> {
  double cardHeight = 0;
  double cardHeight2 = 0;
  double _childAspectRatio = 9 / 16;
  int columns = 5;
  List<double> screenValues = [];
  Map<String, dynamic> layoutData = {};
  bool isMovieTitleVisible = true;

  @override
  void initState() {
    super.initState();
    final movieProvider = Provider.of<MoviesProvider>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      movieProvider.getPopularMoviesAPI(pageNo: "1");
      movieProvider.getPopularMoviesAPI(pageNo: "2");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    var _screenWidth = MediaQuery.of(context).size.width;
    var _itemCount = (_screenWidth / 200).ceil();
    log("width: $screenWidth");

    cardHeight2 = screenWidth / 330;
    log("cardHeight: ${getCardWidth(screenWidth: screenWidth)}");
    layoutData = getCardWidth(screenWidth: screenWidth);
    cardHeight = layoutData["cardHeight"];
    columns = layoutData["columns"].toInt();
    _childAspectRatio = layoutData["childAspectRatio"];
    isMovieTitleVisible = layoutData["isMovieTitleVisible"];
    log("cardHeight 2: ${cardHeight}");
    log("cardHeight 2: ${2 / cardHeight}");
    bool ismyGrid = false;

    return Consumer<MoviesProvider>(builder: (context, movieProvider, child) {
      return Scaffold(
        backgroundColor: DARK_JUNGLE_GREEN_1,
        appBar: AppBar(
          backgroundColor: DARK_JUNGLE_GREEN_1,
          centerTitle: true,
          title: Text(
              "Marvel Movies $screenWidth, $cardHeight, Aspect: ${2 / cardHeight}",
              style:
                  const TextStyle(fontSize: 18, fontFamily: "d", color: WHITE)),
          leading: IconButton(
            icon: Image.asset("assets/images/movie_icon.png"),
            iconSize: 22,
            onPressed: () {},
          ),
        ),
        body: Container(
          decoration: BoxDecoration(border: Border.all(color: RED, width: 1)),
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: ismyGrid
              ? GridViewWidget(
                  columns: columns,
                  cardHeight: cardHeight,
                  title: movieProvider.title,
                  image: movieProvider.img,
                  date: movieProvider.date,
                )
              : GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //  maxCrossAxisExtent: 150,
                    childAspectRatio: _childAspectRatio,
                    crossAxisCount: columns,
                    // (_screenWidth / _itemCount) / 150, // 0.75,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return listItem(
                      title: movieProvider.title[index],
                      movieImage: movieProvider.img[index],
                      context: context,
                      isMovieTitleVisible: isMovieTitleVisible,
                    );
                  },
                  itemCount: movieProvider.title.length),
        ),
      );
    });
  }
}

Widget listItem(
    {required String title,
    required String movieImage,
    required BuildContext context,
    required bool isMovieTitleVisible}) {
  final screenWidth = double.infinity; //MediaQuery.of(context).size.width;
  final screenHeight = double.infinity; //MediaQuery.of(context).size.height;
  print("screenWidth: $screenWidth, screenHeight: $screenHeight");
  return Card(
    color: DARK_JUNGLE_GREEN_1,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            ApiConstants.movieImageBaseUrl + movieImage,
            // width: double.infinity,
            //height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Visibility(
          visible: isMovieTitleVisible,
          child: Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(top: 10, left: 0),
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: WHITE, fontSize: 14, fontFamily: MONTSERRAT_MEDIUM),
            ),
          ),
        ),
        Visibility(
          visible: isMovieTitleVisible,
          child: Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(top: 0, left: 0),
            child: const Text(
              "2022-12-22",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: WHITE, fontSize: 12, fontFamily: MONTSERRAT_MEDIUM),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget GridViewWidget({
  required int columns,
  required double cardHeight,
  required List<String> title,
  required List<String> image,
  required List<String> date,
}) {
  return GridView.count(
    crossAxisCount: columns,
    crossAxisSpacing: 5,
    mainAxisSpacing: 5,
    childAspectRatio: 9 / 18, // 4 / cardHeight,
    children: List.generate(title.length, (index) {
      return InkWell(
        onTap: () {},
        child: MovieCard(
          movieName: title[index],
          imageURL: image[index],
          movieReleaseDate: date[index],
        ),
      );
    }),
  );
}
