import 'package:flutter/material.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';

class MovieBannerWidget extends StatefulWidget {
  final String movieBannerImage;
  final bool showBanner;
  const MovieBannerWidget(
      {Key? key, required this.movieBannerImage, required this.showBanner})
      : super(key: key);

  @override
  _MovieBannerWidgetState createState() => _MovieBannerWidgetState();
}

class _MovieBannerWidgetState extends State<MovieBannerWidget> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1200),
                  child: widget.movieBannerImage != ""
                      ? Image.network(
                          ApiConstants.movieImageBaseUrl +
                              widget.movieBannerImage,
                          width: getCardWidth2(screenWidth: screenWidth) + 30,
                          fit: BoxFit.cover,
                          key: UniqueKey(),
                        )
                      : Image.asset(
                          movieBackDrop2,
                          width: getCardWidth2(screenWidth: screenWidth) + 30,
                          fit: BoxFit.cover,
                          key: UniqueKey(),
                        ),
                )),
          )
        : const SizedBox.shrink();
  }
}

class ImageViewWidget extends StatelessWidget {
  final String url;
  final double width;
  const ImageViewWidget({Key? key, required this.url, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(url);
    return FadeInImage(
      placeholder: const AssetImage(moviePlaceHolder),
      image: NetworkImage(url),
      imageErrorBuilder: (context, error, stackTrace) {
        print("error: $error, $stackTrace");
        return Image.asset(
          movieBackDrop,
          width: getCardWidth2(screenWidth: width) + 30,
          fit: BoxFit.cover,
        );
      },
      fit: BoxFit.cover,
      width: width,
    );
  }
}