import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/all_movies_screen/movies_list.dart';
import 'package:moviewebapp/pages/dashboard/widgets/main_banner.dart';
import 'package:moviewebapp/pages/dashboard/widgets/movie_label.dart';
import 'package:moviewebapp/pages/dashboard/widgets/movies_list.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:moviewebapp/utils/constants.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> moviesDataMap = {
    "0": {
      "movieLabel": Constants.popularMovies,
      "movieType": Constants.popular,
      "withOriginalLanguage": Constants.english,
      "withGenres": ""
    },
    "1": {
      "movieLabel": Constants.topRatedMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": ""
    },
    "2": {
      "movieLabel": Constants.nowPlayingMovies,
      "movieType": Constants.nowPlaying,
      "withOriginalLanguage": Constants.english,
      "withGenres": ""
    },
    "3": {
      "movieLabel": Constants.horrorMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": "27"
    },
    "4": {
      "movieLabel": Constants.thrillerMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": "53"
    },
    "5": {
      "movieLabel": Constants.romanceMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": "10749"
    },
    "6": {
      "movieLabel": Constants.scificMovies,
      "movieType": Constants.topRated,
      "withOriginalLanguage": Constants.english,
      "withGenres": "878"
    },
  };

  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: tealishBlue,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            const MainBanner(),
            Column(
              children: List.generate(
                moviesDataMap.length,
                (index) => Column(
                  children: [
                    MovieLabel(
                      movieLabel: moviesDataMap["$index"]["movieLabel"],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieListScreen(
                              screenTitle: moviesDataMap["$index"]
                                  ["movieLabel"],
                              movieType: moviesDataMap["$index"]["movieType"],
                              withOriginalLanguage: moviesDataMap["$index"]
                                  ["withOriginalLanguage"],
                              withGenres: moviesDataMap["$index"]["withGenres"],
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: getSimilarMoviesSectionHeight(
                        screenSize: _screenWidth,
                      ),
                      margin: const EdgeInsets.only(top: 16),
                      child: MoviesList(
                        movieType: moviesDataMap["$index"]["movieType"],
                        withOriginalLanguage: moviesDataMap["$index"]
                            ["withOriginalLanguage"],
                        withGenres: moviesDataMap["$index"]["withGenres"],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
