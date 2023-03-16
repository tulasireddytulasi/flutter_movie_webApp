import 'package:flutter/material.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:moviewebapp/utils/navigation/navigation.dart';

class SimilarMovieCard extends StatelessWidget {
  const SimilarMovieCard({
    Key? key,
    required this.castImage,
    required this.actorName,
    required this.movieId,
    this.scrollController,
    required this.canNavigateToNewPage,
  }) : super(key: key);

  final String castImage;
  final String actorName;
  final String movieId;
  final bool canNavigateToNewPage;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigation().updateMovieInfoScreen(
              context: context,
              movieId: movieId,
              canNavigateToNewPage: canNavigateToNewPage,
              scrollController: scrollController,
            );
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.network(
                ApiConstants.movieImageBaseUrlw185 + castImage,
                width: getSimilarMoviesImageWidth(screenSize: _screenWidth),
                height: getSimilarMoviesImageHeight(screenSize: _screenWidth),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 15, top: 10),
          width: 100,
          child: Text(
            actorName,
            style: const TextStyle(fontSize: 12, color: GREY),
            maxLines: 2,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
