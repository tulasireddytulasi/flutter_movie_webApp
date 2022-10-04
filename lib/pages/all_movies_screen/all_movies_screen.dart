import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/all_movies_screen/widgets/movie_card.dart';
import 'package:moviewebapp/pages/movie_info_screen/movie_info.dart';
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
  double leftPadding = 0;
  double rightPadding = 0;
  double crossAxisSpacing = 5;
  double maxBottomSheetWidth = 0;
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
    layoutData = getCardWidth(screenWidth: screenWidth);
    cardHeight = layoutData["cardHeight"];
    columns = layoutData["columns"].toInt();
    _childAspectRatio = layoutData["childAspectRatio"];
    isMovieTitleVisible = layoutData["isMovieTitleVisible"];
    leftPadding = layoutData["leftPadding"];
    rightPadding = layoutData["rightPadding"];
    crossAxisSpacing = layoutData["crossAxisSpacing"];
    maxBottomSheetWidth = layoutData["maxBottomSheetWidth"];

    return Consumer<MoviesProvider>(builder: (context, movieProvider, child) {
      final double screenWidth = MediaQuery.of(context).size.width;
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
          // decoration: BoxDecoration(border: Border.all(color: RED, width: 1)),
          padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
          child: GridView.builder(
              scrollDirection: Axis.vertical,
              physics: const ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: _childAspectRatio,
                crossAxisCount: columns,
                // mainAxisSpacing: 20,
                crossAxisSpacing: crossAxisSpacing,
              ),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    if (screenWidth >= 600) {
                      showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          isDismissible: true,
                          enableDrag: false,
                          elevation: 0,
                          barrierColor: Colors.black.withAlpha(1),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(50))),
                          builder: (context) {
                            return Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 600,
                                  minHeight: 300,
                                ),
                                child: MovieInfoScreen(
                                    movieId: movieProvider.movieId[index]));
                          });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MovieInfoScreen(
                                movieId: movieProvider.movieId[index])),
                      );
                    }
                  },
                  child: MovieCard(
                    movieName: movieProvider.title[index],
                    imageURL: movieProvider.img[index],
                    movieReleaseDate: movieProvider.date[index],
                    isMovieTitleVisible: isMovieTitleVisible,
                  ),
                );
              },
              itemCount: movieProvider.title.length),
        ),
      );
    });
  }
}
