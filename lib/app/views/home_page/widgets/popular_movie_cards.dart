import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/home_page/widgets/data.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:provider/provider.dart';

class PopularMovies extends StatefulWidget {
  PopularMovies({Key? key, this.scrollController}) : super(key: key);
  ScrollController? scrollController;

  @override
  _PopularMoviesState createState() => _PopularMoviesState();
}

class _PopularMoviesState extends State<PopularMovies> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoviesProvider>(builder: (context, movieProvider, child) {
      return movieData.isNotEmpty
          ? ListView.builder(
              itemCount: movieData["results"].length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return PopularMovieCard(
                  actorName: movieData["results"][index]["title"].toString(),
                  castImage:
                      movieData["results"][index]["backdrop_path"].toString(),
                  movieId: movieData["results"][index]["id"].toString(),
                  // scrollController: widget.scrollController,
                );
              })
          : Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                "No Popular Movies",
                style: TextStyle(fontSize: 18, color: GREY),
              ),
            );
    });
  }
}

class PopularMovieCard extends StatefulWidget {
  PopularMovieCard({
    Key? key,
    required this.castImage,
    required this.actorName,
    required this.movieId,
    this.scrollController,
    this.cardWidth = 300,
    this.cardHeight = 200,
  }) : super(key: key);

  final String castImage;
  final String actorName;
  final String movieId;
  final double cardWidth;
  final double cardHeight;
  ScrollController? scrollController;

  @override
  State<PopularMovieCard> createState() => _PopularMovieCardState();
}

class _PopularMovieCardState extends State<PopularMovieCard> {
  double blurBox = 0.8;
  double movieCardElevation = 10;
  double movieCardMargin = 10;
  var borderColor = LIGHTWHITE2;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        InkWell(
          onTap: () {},
          hoverColor: Colors.transparent,
          onHover: (val) {
            if (val) {
              setState(() {
                movieCardElevation = 30;
                // borderColor = Colors.green;
              });
            } else {
              setState(() {
                movieCardElevation = 10;
                // borderColor = LIGHTWHITE2;
              });
            }
          },
          child: Card(
            elevation: movieCardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: borderColor,
            child: Stack(
              children: [
                Container(
                  margin:
                      EdgeInsets.all(screenWidth > 650 ? movieCardMargin : 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      ApiConstants.movieImageBaseUrlw780 + widget.castImage,
                      width: widget.cardWidth,
                      height: widget.cardHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: screenWidth > 650 ? movieCardMargin : 5,
                  bottom: screenWidth > 650 ? movieCardMargin : 5,
                  right: screenWidth > 650 ? movieCardMargin : 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(screenWidth > 650 ? 20 : 10),
                        color: Colors.white.withOpacity(0.5449371339389631),
                        //  width: 300,
                        child: Text(
                          widget.actorName,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: const TextStyle(
                              fontSize: 14,
                              color: BLACK,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ),
                ),
                //  buildImageOverlay(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
