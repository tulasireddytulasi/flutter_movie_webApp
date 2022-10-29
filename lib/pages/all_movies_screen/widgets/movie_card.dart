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
  final bool isMovieTitleVisible;

  const MovieCard(
      {Key? key,
      required this.imageURL,
      required this.movieName,
      required this.movieReleaseDate,
      required this.isMovieTitleVisible})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MoviesProvider>(builder: (context, movieProvider, child) {
      return Card(
        color: DARK_JUNGLE_GREEN_1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                ApiConstants.movieImageBaseUrlw500 + imageURL,
                fit: BoxFit.cover,
              ),
            ),
            Visibility(
              visible: isMovieTitleVisible,
              child: Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(top: 10, left: 0),
                child: Text(
                  movieName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: WHITE,
                      fontSize: 14,
                      fontFamily: MONTSERRAT_MEDIUM),
                ),
              ),
            ),
            Visibility(
              visible: isMovieTitleVisible,
              child: Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(top: 0, left: 0),
                child: const Text(
                  "2022-12-22",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: WHITE,
                      fontSize: 12,
                      fontFamily: MONTSERRAT_MEDIUM),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
