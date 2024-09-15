import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';
import 'package:moviewebapp/app/views/all_movies_screen/movies_list.dart';
import 'package:moviewebapp/app/views/dashboard/main_banner_widget/main_banner.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/movie_label.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/movies_list.dart';
import 'package:moviewebapp/app/providers/dashboard_provider.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late DashBoardProvider dashBoardProvider;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    /// Update the state based on scroll position
    _isScrolled = _scrollController.position.pixels >= 100;
    if (_isScrolled) {
      dashBoardProvider.setAppBarColorAndElevation(color: tealishBlue, elevation: 1.0);
    } else {
      dashBoardProvider.setAppBarColorAndElevation(color: Colors.transparent, elevation: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: tealishBlue,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          return true;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const MainBanner(),
              ListView.builder(
                itemCount: dashBoardProvider.moviesDataMapObject.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> movieData = dashBoardProvider.moviesDataMapObject["$index"];
                  return Column(
                    children: [
                      MovieLabel(
                        movieLabel: movieData["movieLabel"],
                        onTap: () {
                          String movieType = movieData["movieType"];
                          // Todo: In future will remove this comparison
                          if(movieType == Constants.marvelMovies){
                            movieType = Constants.popular;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieListScreen(
                                showAppBar: true,
                                screenTitle: movieData["movieLabel"],
                                movieType: movieType,
                                withOriginalLanguage: movieData["withOriginalLanguage"],
                                withGenres: movieData["withGenres"],
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
                        margin: const EdgeInsets.only(top: 16),
                        child: MoviesList(
                          movieType: dashBoardProvider.moviesDataMapObject["$index"]["movieType"],
                          withOriginalLanguage: dashBoardProvider.moviesDataMapObject["$index"]["withOriginalLanguage"],
                          withGenres: dashBoardProvider.moviesDataMapObject["$index"]["withGenres"],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
