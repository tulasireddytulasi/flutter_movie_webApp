import 'package:flutter/material.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';
import 'package:provider/provider.dart';

class MovieCard extends StatelessWidget {
  final String imageURL;
  final String movieName;
  final String movieReleaseDate;

  const MovieCard(
      {Key? key,
      required this.imageURL,
      required this.movieName,
      required this.movieReleaseDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Consumer<MoviesProvider>(builder: (context, movieProvider, child) {
      return SizedBox(
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
                  ApiConstants.movieImageBaseUrl + imageURL,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: 190,
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 10, left: 10),
              child: Text(
                movieName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: WHITE, fontSize: 18, fontFamily: MONTSERRAT_MEDIUM),
              ),
            ),
            Container(
              width: 190,
              // decoration: BoxDecoration(border: Border.all(color: RED, width: 1)),
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(left: 10),
              child: Text(
                movieReleaseDate,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: GRAY, fontSize: 14, fontFamily: MONTSERRAT_MEDIUM),
              ),
            ),
          ],
        ),
      );
    });
  }
}
