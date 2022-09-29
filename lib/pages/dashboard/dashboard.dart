import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/dashboard/widgets/movie_card.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:provider/provider.dart';

class MovieHomePage extends StatefulWidget {
  const MovieHomePage({Key? key}) : super(key: key);

  @override
  _MovieHomePageState createState() => _MovieHomePageState();
}

class _MovieHomePageState extends State<MovieHomePage> {
  double cardHeight = 0;
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
      movieProvider.getPopularMoviesAPI(pageNo: "3");
      movieProvider.getPopularMoviesAPI(pageNo: "4");
      movieProvider.getPopularMoviesAPI(pageNo: "5");
      movieProvider.getPopularMoviesAPI(pageNo: "6");
      movieProvider.getPopularMoviesAPI(pageNo: "7");
      movieProvider.getPopularMoviesAPI(pageNo: "8");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    log("width: $screenWidth");
    log("cardHeight: ${getCardWidth(screenWidth: screenWidth)}");
    layoutData = getCardWidth(screenWidth: screenWidth);
    cardHeight = layoutData["cardHeight"];
    columns = layoutData["columns"].toInt();
    _childAspectRatio = layoutData["childAspectRatio"];
    isMovieTitleVisible = layoutData["isMovieTitleVisible"];
    log("cardHeight 2: ${cardHeight}");
    log("cardHeight 2: ${2 / cardHeight}");

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
          child: GridView.builder(
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: _childAspectRatio,
                crossAxisCount: columns,
              ),
              itemBuilder: (BuildContext context, int index) {
                return MovieCard(
                  movieName: movieProvider.title[index],
                  imageURL: movieProvider.img[index],
                  movieReleaseDate: movieProvider.date[index],
                  isMovieTitleVisible: isMovieTitleVisible,
                );
              },
              itemCount: movieProvider.title.length),
        ),
      );
    });
  }
}
