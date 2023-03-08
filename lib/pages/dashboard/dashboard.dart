import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/dashboard/widgets/icon_with_text_widget.dart';
import 'package:moviewebapp/pages/dashboard/widgets/movie_label.dart';
import 'package:moviewebapp/pages/dashboard/widgets/movies_list.dart';
import 'package:moviewebapp/pages/dashboard/widgets/play_button_widget.dart';
import 'package:moviewebapp/responses/api_constants.dart';
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

  List<String> genere = [
    "Ominous",
    "Gritty",
    "Thriller",
    "Twists & Turns",
    "Serial Killer",
  ];

  @override
  void initState() {
    super.initState();
    genere.join(" . ");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: tealishBlue,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Container(
              // decoration: BoxDecoration(
              //   border: Border.all(color: BLACK, width: 1),
              // ),
              child: Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          tealishBlue,
                          tealishBlue,
                          Colors.transparent,
                        ],
                      ).createShader(
                        Rect.fromLTRB(0, 1, rect.width, rect.height),
                      );
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.network(
                      ApiConstants.movieImageBaseUrlw500 +
                          "/9Gtg2DzBhmYamXBS1hKAhiwbBKS.jpg",
                      fit: BoxFit.cover,
                      height: 560,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              text: TextSpan(
                                children: List.generate(
                                  genere.length,
                                  (index) => TextSpan(
                                    text: genere.length - 1 != index
                                        ? genere[index] + " . "
                                        : genere[index],
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: WHITE,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            IconWithText(
                              icon: Icons.done,
                              label: "My List",
                            ),
                            SizedBox(width: 30),
                            PlayButtonWidget(),
                            SizedBox(width: 30),
                            IconWithText(
                              icon: Icons.info_outline_rounded,
                              label: "Info",
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const MovieLabel(movieLabel: Constants.popularMovies),
            Container(
              height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
              margin: const EdgeInsets.only(top: 16),
              child: const MoviesList(
                movieType: Constants.popular,
                withOriginalLanguage: Constants.english,
              ),
            ),
            const MovieLabel(movieLabel: Constants.topRatedMovies),
            Container(
              height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
              margin: const EdgeInsets.only(top: 16),
              child: const MoviesList(
                movieType: Constants.topRated,
                withOriginalLanguage: Constants.english,
              ),
            ),
            const MovieLabel(movieLabel: Constants.nowPlayingMovies),
            Container(
              height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
              margin: const EdgeInsets.only(top: 16),
              child: const MoviesList(
                movieType: Constants.nowPlaying,
                withOriginalLanguage: Constants.english,
              ),
            ),
            const MovieLabel(movieLabel: Constants.upcomingMovies),
            Container(
              height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
              margin: const EdgeInsets.only(top: 16),
              child: const MoviesList(
                movieType: Constants.upcoming,
                withOriginalLanguage: Constants.english,
              ),
            ),
            const MovieLabel(movieLabel: Constants.horrorMovies),
            Container(
              height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
              margin: const EdgeInsets.only(top: 16),
              child: const MoviesList(
                movieType: Constants.topRated,
                withOriginalLanguage: Constants.english,
                withGenres: "27",
              ),
            ),
            const MovieLabel(movieLabel: Constants.thrillerMovies),
            Container(
              height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
              margin: const EdgeInsets.only(top: 16),
              child: const MoviesList(
                movieType: Constants.topRated,
                withOriginalLanguage: Constants.english,
                withGenres: "53",
              ),
            ),
            const MovieLabel(movieLabel: Constants.romanceMovies),
            Container(
              height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
              margin: const EdgeInsets.only(top: 16),
              child: const MoviesList(
                movieType: Constants.topRated,
                withOriginalLanguage: Constants.english,
                withGenres: "10749",
              ),
            ),
            const MovieLabel(movieLabel: Constants.scificMovies),
            Container(
              height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
              margin: const EdgeInsets.only(top: 16),
              child: const MoviesList(
                movieType: Constants.topRated,
                withOriginalLanguage: Constants.english,
                withGenres: "878",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
