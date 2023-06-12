import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/all_movies_screen/movies_list.dart';
import 'package:moviewebapp/pages/dashboard/main_banner_widget/main_banner.dart';
import 'package:moviewebapp/pages/dashboard/widgets/movie_label.dart';
import 'package:moviewebapp/pages/dashboard/widgets/movies_list.dart';
import 'package:moviewebapp/providers/dashboard_provider.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:moviewebapp/utils/constants.dart';
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
    dashBoardProvider.getAllMoviesList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Update the state based on scroll position
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
              Consumer<DashBoardProvider>(
                builder: (context, dashBoardProvider, child) {
                  if (dashBoardProvider.moviesModelList.isNotEmpty) {
                    return Column(
                      children: List.generate(
                        dashBoardProvider.moviesModelList.length,
                        (index) => Column(
                          children: [
                            MovieLabel(
                              movieLabel: dashBoardProvider.moviesLabelList[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieListScreen(
                                      showAppBar: true,
                                      screenTitle: dashBoardProvider.moviesDataMapObject["$index"]["movieLabel"],
                                      movieType: dashBoardProvider.moviesDataMapObject["$index"]["movieType"],
                                      withOriginalLanguage: dashBoardProvider.moviesDataMapObject["$index"]
                                          ["withOriginalLanguage"],
                                      withGenres: dashBoardProvider.moviesDataMapObject["$index"]["withGenres"],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
                              margin: const EdgeInsets.only(top: 16),
                              child: MoviesList(moviesModel: dashBoardProvider.moviesModelList[index]),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
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
