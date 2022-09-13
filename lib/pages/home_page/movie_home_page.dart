import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';

import 'widgets/movie_card.dart';

class MovieHomePage extends StatefulWidget {
  const MovieHomePage({Key? key}) : super(key: key);

  @override
  _MovieHomePageState createState() => _MovieHomePageState();
}

class _MovieHomePageState extends State<MovieHomePage> {
  double cardHeight = 0;
  double cardHeight2 = 0;
  int columns = 5;
  List<double> screenValues = [];
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    log("width: $screenWidth");

    cardHeight2 = screenWidth / 330;
    //log("cardHeight: $cardHeight2");
    log("cardHeight: ${getCardWidth(screenWidth: screenWidth)}");
    screenValues = getCardWidth(screenWidth: screenWidth);
    cardHeight = screenValues[0];
    columns = screenValues[1] as int;
    log("cardHeight 2: ${cardHeight}");

    return Scaffold(
      backgroundColor: DARK_JUNGLE_GREEN_1,
      appBar: AppBar(
        backgroundColor: DARK_JUNGLE_GREEN_1,
        centerTitle: true,
        title: Text(
            "Marvel Movies $screenWidth, ${cardHeight}, Aspect: ${2 / cardHeight}",
            style: TextStyle(fontSize: 18, fontFamily: "d", color: WHITE)),
        leading: IconButton(
          icon: Image.asset("assets/images/movie_icon.png"),
          iconSize: 22,
          onPressed: () {},
        ),
      ),
      body: Container(
        decoration: BoxDecoration(border: Border.all(color: RED, width: 1)),
        padding: const EdgeInsets.only(left: 70, right: 70),
        child: GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2 / cardHeight,
          children: List.generate(20, (index) {
            return Container(
                // decoration:
                //     BoxDecoration(border: Border.all(color: RED, width: 1)),
                child: const MovieCard());
          }),
        ),
      ),
    );
  }
}
