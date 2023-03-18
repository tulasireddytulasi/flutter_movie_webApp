import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moviewebapp/animations/ripple_animation.dart';
import 'package:moviewebapp/models/get_movies_model.dart';
import 'package:moviewebapp/pages/all_movies_screen/widgets/movie_card.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/responses/movie_apis.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:moviewebapp/utils/constants.dart';
import 'package:moviewebapp/utils/navigation/navigation.dart';
import 'package:provider/provider.dart';

class MovieHomePage extends StatefulWidget {
  const MovieHomePage({
    Key? key,
    required this.withOriginalLanguage,
    required this.movieType,
    this.withGenres,
    required this.screenTitle,
  }) : super(key: key);
  final String withOriginalLanguage;
  final String movieType;
  final String? withGenres;
  final String screenTitle;

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

  MoviesModel _moviesModel = MoviesModel();
  late Future<MoviesModel> _moviesData;

  final List<String> _title = [];
  final List<String> _movieId = [];
  final List<String> _img = [];
  final List<String> _date = [];

  clearData() {
    _title.clear();
    _movieId.clear();
    _img.clear();
    _date.clear();
  }

  processData({required MoviesModel moviesModel}) {
    _moviesModel = moviesModel;
    _moviesModel.results?.forEach((element) {
      _title.add(element.title ?? "");
      _img.add(element.posterPath ?? "");
      _movieId.add(element.id.toString());
      final String movieReleaseDate =
          element.releaseDate?.toIso8601String() ?? Constants.time00;
      if (movieReleaseDate.isNotEmpty && movieReleaseDate != Constants.time00) {
        String movieReleaseDateValue =
            DateFormat("yyyy-MM-dd").format(element.releaseDate!).toString();
        _date.add(movieReleaseDateValue);
      } else {
        _date.add(Constants.time00);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _moviesData = getPopularMoviesList(
      movieType: widget.movieType,
      pageNo: "1",
      withOriginalLanguage: widget.withOriginalLanguage,
      withGenres: widget.withGenres,
    );
  }

  Widget messageText({required String text}) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: BLACK,
        ),
      ),
    );
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
        appBar: AppBar(
          backgroundColor: tealishBlue,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: WHITE,
            ),
          ),
          title: Text(
            widget.screenTitle,
            style: TextStyle(fontSize: 18, color: WHITE),
          ),
        ),
        body: FutureBuilder(
            future: _moviesData,
            builder:
                (BuildContext context, AsyncSnapshot<MoviesModel> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const RipplesAnimation();
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return messageText(text: "Error");
                } else if (snapshot.hasData) {
                  clearData();
                  processData(moviesModel: snapshot.data!);
                  return Container(
                    // decoration: BoxDecoration(border: Border.all(color: RED, width: 1)),
                    padding:
                        EdgeInsets.only(left: leftPadding, right: rightPadding),
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
                              Navigation().navigateToMoviesInfoPage(
                                context: context,
                                movieId: _movieId[index],
                                screenWidth: screenWidth,
                              );
                            },
                            child: MovieCard(
                              movieName: _title[index],
                              imageURL: _img[index],
                              movieReleaseDate: _date[index],
                              isMovieTitleVisible: isMovieTitleVisible,
                            ),
                          );
                        },
                        itemCount: _title.length),
                  );
                } else {
                  return messageText(text: "No Movies");
                }
              } else {
                return messageText(text: 'State: ${snapshot.connectionState}');
              }
            }),
      );
    });
  }
}
