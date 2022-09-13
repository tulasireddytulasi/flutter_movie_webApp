import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: WHITE, width: 5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imgURL,
                width: 170, //(screenWidth / 7) - 0,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: 190,
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(top: 10, left: 10),
            child: const Text(
              "Iron Man",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: WHITE, fontSize: 18, fontFamily: MONTSERRAT_MEDIUM),
            ),
          ),
          Container(
            width: 190,
            // decoration: BoxDecoration(border: Border.all(color: RED, width: 1)),
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 10),
            child: const Text(
              "2008",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: GRAY, fontSize: 14, fontFamily: MONTSERRAT_MEDIUM),
            ),
          ),
        ],
      ),
    );
  }
}
