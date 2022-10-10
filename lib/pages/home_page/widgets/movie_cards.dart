import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/home_page/widgets/popular_movie_cards.dart';
import 'package:moviewebapp/utils/commom_functions.dart';

class MovieCards extends StatelessWidget {
  const MovieCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth / 2;
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(color: BLACK, width: 1),
      // ),
      child: Stack(
        children: [
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(color: Colors.green, width: 1),
            // ),
            padding:
                const EdgeInsets.only(top: 30, bottom: 30, left: 30, right: 30),
            child: PopularMovieCard(
                cardWidth: getCardWidth(cardSize: screenWidth) - 100,
                cardHeight: getCardHeight(cardSize: screenWidth) - 150,
                actorName: "Fall",
                castImage: "/rgZ3hdzgMgYgzvBfwNEVW01bpK1.jpg",
                movieId: "455"),
          ),
          Positioned(
            top: 30,
            right: -20,
            left: -20,
            child: Container(
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.green, width: 1),
              // ),
              padding: const EdgeInsets.only(
                  top: 30, bottom: 30, left: 30, right: 30),
              child: PopularMovieCard(
                  cardWidth: getCardWidth(cardSize: screenWidth),
                  cardHeight: getCardHeight(cardSize: screenWidth) - 150,
                  actorName: "Titan",
                  castImage: "/nnUQqlVZeEGuCRx8SaoCU4XVHJN.jpg",
                  movieId: "455"),
            ),
          ),
        ],
      ),
    );
  }
}
