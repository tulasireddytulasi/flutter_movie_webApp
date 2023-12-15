import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:moviewebapp/app/core/utils/commom_functions.dart';

class MoviesCard extends StatefulWidget {
  const MoviesCard({
    Key? key,
    required this.poster,
    required this.movieName,
    required this.movieId,
    required this.voidCallback,
  }) : super(key: key);

  final String poster;
  final String movieName;
  final String movieId;
  final VoidCallback voidCallback;

  @override
  _MoviesCardState createState() => _MoviesCardState();
}

class _MoviesCardState extends State<MoviesCard> {
  Color? movieCardColor;
  final ValueNotifier<BlendMode?> _blendMode = ValueNotifier<BlendMode?>(null);

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    String imgUrl = widget.poster.isNotEmpty ? widget.poster : "/wQ53sO5n9LCFbssV3oQ4CuajL1L.jpg";
    return InkWell(
      onTap: () => widget.voidCallback(),
      onHover: (onHover) {
        if (onHover) {
          movieCardColor = Colors.grey;
          _blendMode.value = BlendMode.saturation;
        } else {
          movieCardColor = null;
          _blendMode.value = null;
        }
      },
      child: Column(
        children: [
          ValueListenableBuilder<BlendMode?>(
              valueListenable: _blendMode,
              builder: (context, blendMode, child) {
                return Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Image.network(
                      ApiConstants.movieImageBaseUrlw185 + imgUrl,
                      width: getSimilarMoviesImageWidth(screenSize: _screenWidth),
                      height: getSimilarMoviesImageHeight(screenSize: _screenWidth),
                      fit: BoxFit.cover,
                      color: movieCardColor,
                      colorBlendMode: blendMode,
                    ),
                  ),
                );
              }),
          Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 15, top: 10),
            width: 100,
            child: Text(
              widget.movieName,
              style: const TextStyle(fontSize: 12, color: GREY),
              maxLines: 2,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
