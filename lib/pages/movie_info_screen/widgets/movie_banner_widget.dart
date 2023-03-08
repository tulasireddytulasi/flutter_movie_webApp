import 'package:flutter/material.dart';
import 'package:moviewebapp/providers/movie_info_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:provider/provider.dart';

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
    final bool isVisible = screenWidth >= 525;
    return widget.showBanner
        ? Stack(
            children: [
              Container(
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
                            ApiConstants.movieImageBaseUrlw1280 +
                                widget.movieBannerImage,
                            width:
                                getBottomSheetWidth(screenWidth: screenWidth) +
                                    30,
                            fit: BoxFit.cover,
                            key: UniqueKey(),
                          )
                        : Image.asset(
                            movieBackDrop2,
                            width:
                                getBottomSheetWidth(screenWidth: screenWidth) +
                                    30,
                            fit: BoxFit.cover,
                            key: UniqueKey(),
                          ),
                  ),
                ),
              ),
              Positioned(
                top: isVisible ? 0 : 30,
                right: 0,
                child: InkWell(
                  onTap: () {
                    final movieInfoProvider =
                        Provider.of<MovieInfoProvider>(context, listen: false);
                    movieInfoProvider.removePreviousAllMoviesIds();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: BLACK, width: 2),
                        shape: BoxShape.circle,
                        color: BLACK),
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.clear,
                      color: WHITE,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: isVisible ? 0 : 30,
                left: 0,
                child: InkWell(
                  onTap: () {
                    final movieInfoProvider =
                        Provider.of<MovieInfoProvider>(context, listen: false);
                    if (movieInfoProvider.previousMoviesIds.isNotEmpty) {
                      String movieId =
                          movieInfoProvider.previousMoviesIds.elementAt(0);
                      movieInfoProvider.getMoviesInfoAPI(
                          movieId: movieId, appendToResponse: "credits");
                      movieInfoProvider.removePreviousMoviesIds();
                    } else {
                      final movieInfoProvider = Provider.of<MovieInfoProvider>(
                          context,
                          listen: false);
                      movieInfoProvider.removePreviousAllMoviesIds();
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.arrow_back,
                      color: WHITE,
                    ),
                  ),
                ),
              ),
            ],
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
          width: getBottomSheetWidth(screenWidth: width) + 30,
          fit: BoxFit.cover,
        );
      },
      fit: BoxFit.cover,
      width: width,
    );
  }
}
