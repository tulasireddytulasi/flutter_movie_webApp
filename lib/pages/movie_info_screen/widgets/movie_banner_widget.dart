import 'package:flutter/material.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';

class MovieBannerWidget extends StatefulWidget {
  final String movieBannerImage;
  final bool showBanner;
  MovieBannerWidget(
      {Key? key, required this.movieBannerImage, required this.showBanner})
      : super(key: key);

  @override
  _MovieBannerWidgetState createState() => _MovieBannerWidgetState();
}

class _MovieBannerWidgetState extends State<MovieBannerWidget> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return widget.showBanner
        ? Container(
            margin: const EdgeInsets.all(0),
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    pickledBlueWood,
                    pickledBlueWood,
                    Colors.transparent
                  ],
                ).createShader(
                  Rect.fromLTRB(0, 1, rect.width, rect.height),
                );
              },
              blendMode: BlendMode.dstIn,
              child: Image.network(
                ApiConstants.movieImageBaseUrl + widget.movieBannerImage,
                width: getCardWidth2(screenWidth: screenWidth) + 30,
                fit: BoxFit.cover,
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
