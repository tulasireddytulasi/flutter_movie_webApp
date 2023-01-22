import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/home_page/widgets/logo_widget.dart';
import 'package:moviewebapp/pages/home_page/widgets/main_text.dart';
import 'package:moviewebapp/pages/home_page/widgets/movie_cards.dart';
import 'package:moviewebapp/pages/home_page/widgets/popular_movie_cards.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color borderColor = Colors.white;

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   final actorsInfoProvider =
    //       Provider.of<ActorsInfoProvider>(context, listen: false);
    //   actorsInfoProvider.getPopularActorsInfoAPI(
    //       languageCode: "en-US", pageNo: 1);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double margin = screenWidth / 2;
    final double cardWidth = screenWidth / 2;
    print("cardWidth: $cardWidth");
    return Scaffold(
      backgroundColor: WHITE,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                screenWidth > 650
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: listWidgets(),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: listWidgets(),
                      ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 30),
                  alignment: Alignment.topCenter,
                  child: LogosWidget(screenWidth: screenWidth),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 40),
                  child: const Text(
                    "10 Most Popular Movies this Week",
                    textAlign: TextAlign.center,
                    softWrap: true,
                    textScaleFactor: 1.5,
                    style: TextStyle(
                        fontSize: 26,
                        color: BLACK,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: margin / 2, right: margin / 2, top: 10),
                  child: const Text(
                    "Discover the top, most popular movies available now! Across theaters, streaming, and on-demand",
                    textAlign: TextAlign.center,
                    softWrap: true,
                    textScaleFactor: 1.5,
                    style: TextStyle(
                        fontSize: 12,
                        color: BLACK1,
                        fontWeight: FontWeight.w100),
                  ),
                ),
                Container(
                  height: 330,
                  padding: const EdgeInsets.only(top: 30, bottom: 0),
                  margin: const EdgeInsets.only(top: 20),
                  color: LIGHTWHITE2,
                  child: PopularMovies(),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 40),
                  child: const Text(
                    "Most Popular People",
                    textAlign: TextAlign.center,
                    softWrap: true,
                    textScaleFactor: 1.5,
                    style: TextStyle(
                        fontSize: 26,
                        color: BLACK,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: margin / 2, right: margin / 2, top: 10),
                  child: const Text(
                    "Discover the top, most popular movies available now! Across theaters, streaming, and on-demand",
                    textAlign: TextAlign.center,
                    softWrap: true,
                    textScaleFactor: 1.5,
                    style: TextStyle(
                        fontSize: 12,
                        color: BLACK1,
                        fontWeight: FontWeight.w100),
                  ),
                ),
                Container(
                  height: getActorSectionHeight(screenSize: screenWidth),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: DARK_JUNGLE_GREEN_1, width: 1),
                  ),
                  // child: const CircularWidget(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> listWidgets() {
    return [
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.all(20),
        child: const MainTextWidget(),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: const MovieCards(),
      ),
    ];
  }
}
