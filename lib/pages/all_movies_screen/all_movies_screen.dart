import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/all_movies_screen/widgets/movie_card.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/providers/navigation_provider.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:moviewebapp/utils/navigation/navigation.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (movieProvider.getPopularMoviesModel.results == null) {
        movieProvider.getPopularMoviesAPI(pageNo: "1");
        movieProvider.getPopularMoviesAPI(pageNo: "2");
        movieProvider.getPopularMoviesAPI(pageNo: "3");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    layoutData = getMovieCardWidth(screenWidth: screenWidth);
    cardHeight = layoutData["cardHeight"];
    columns = layoutData["columns"].toInt();
    _childAspectRatio = layoutData["childAspectRatio"];
    isMovieTitleVisible = layoutData["isMovieTitleVisible"];
    leftPadding = layoutData["leftPadding"];
    rightPadding = layoutData["rightPadding"];
    crossAxisSpacing = layoutData["crossAxisSpacing"];
    maxBottomSheetWidth = layoutData["maxBottomSheetWidth"];

    return Consumer<MoviesProvider>(builder: (context, movieProvider, child) {
      return Scaffold(
        backgroundColor: tealishBlue,
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
                return Consumer<NavigationProvider>(
                    builder: (context, navigationProvider, child) {
                  return InkWell(
                    onTap: () {
                      Navigation().navigateToMoviesInfoPage(
                        context: context,
                        movieId: movieProvider.movieId[index],
                        screenWidth: screenWidth,
                      );
                    },
                    child: MovieCard(
                      movieName: movieProvider.title[index],
                      imageURL: movieProvider.img[index],
                      movieReleaseDate: movieProvider.date[index],
                      isMovieTitleVisible: isMovieTitleVisible,
                    ),
                  );
                });
              },
              itemCount: movieProvider.title.length),
        ),
      );
    });
  }
}
