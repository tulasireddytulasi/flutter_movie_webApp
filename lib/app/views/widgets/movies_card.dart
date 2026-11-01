import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';

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
  State<MoviesCard> createState() => _MoviesCardState();
}

class _MoviesCardState extends State<MoviesCard> {
  final ValueNotifier<BlendMode?> _blendMode = ValueNotifier<BlendMode?>(null);

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    String imgUrl = widget.poster.isNotEmpty ? widget.poster : "/wQ53sO5n9LCFbssV3oQ4CuajL1L.jpg";
    return InkWell(
      onTap: () => widget.voidCallback(),
      onHover: (onHover) {
        if (onHover) {
          _blendMode.value = BlendMode.saturation;
        } else {
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
                      color: blendMode == null ? null : Theme.of(context).colorScheme.onSurfaceVariant,
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
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
