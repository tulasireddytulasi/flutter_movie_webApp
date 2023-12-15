import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/dashboard/main_banner_widget/animated_logo_widget.dart';
import 'package:moviewebapp/app/views/dashboard/main_banner_widget/play_buttons_widget.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MainBanner extends StatefulWidget {
  const MainBanner({Key? key}) : super(key: key);

  @override
  _MainBannerState createState() => _MainBannerState();
}

class _MainBannerState extends State<MainBanner> with SingleTickerProviderStateMixin {
  late MoviesProvider _moviesProvider;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _onHoverAnimationActive = false;
  List<String> genere = [
    "Ominous",
    "Gritty",
    "Thriller",
    "Twists & Turns",
    "Serial Killer",
  ];

  @override
  void initState() {
    super.initState();
    _moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    _moviesProvider.getMovieDetails(pageNo: 1, movieType: "popular"); // popular upcoming
    genere.join(" . ");

    /// Create an animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    /// Create a Tween for the scale animation
    _scaleAnimation = Tween<double>(
      begin: 2,
      end: 1.0,
    ).animate(_controller);
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(seconds: 4));
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _onHoverAnimationActive = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    final bool _screenWidth600 = _screenWidth >= 600;

    return Consumer<MoviesProvider>(
      builder: (context, moviesProvider, child) {
        final String posterSize =
            _screenWidth600 ? ApiConstants.movieImageBaseUrlw1280 : ApiConstants.movieImageBaseUrlw500;
        final _movieBannerData = moviesProvider.movieBannerModel.moviesList?.first;
        final String _id = _movieBannerData?.id ?? "";
        final String _logo = _movieBannerData?.logo ?? "";
        final String _youTubeVideoKey = _movieBannerData?.youTubeVideoKey ?? "";
        final String _description = _movieBannerData?.description ?? "";
        final String poster = _screenWidth600 ? _movieBannerData?.backDrop ?? "" : _movieBannerData?.poster ?? "";
        return _logo.isEmpty
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300] ?? Colors.grey,
                highlightColor: tealishBlue1,
                child: Image.asset(
                  movieBackDrop2,
                  width: double.infinity,
                  height: 600,
                  fit: BoxFit.fitWidth,
                ),
              )
            : Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [tealishBlue, tealishBlue, Colors.transparent],
                      ).createShader(Rect.fromLTRB(0, 1, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: poster.isNotEmpty
                        ? Image.network(
                            posterSize + poster,
                            fit: BoxFit.cover,
                            height: 560,
                            width: double.infinity,
                          )
                        : Shimmer.fromColors(
                            baseColor: Colors.grey[300] ?? Colors.grey,
                            highlightColor: tealishBlue1,
                            child: Image.asset(
                              movieBackDrop2,
                              width: double.infinity,
                              height: 500,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                  ),
                  PlayButtons(genere: genere, movieId: _id, youTubeVideoKey: _youTubeVideoKey),
                  Visibility(
                    visible: _screenWidth600,
                    child: Positioned(
                      bottom: 0,
                      left: 50,
                      child: InkWell(
                        onTap: () {},
                        onHover: (onHover) {
                          if (_onHoverAnimationActive) {
                            if (onHover) {
                              if (_controller.status == AnimationStatus.completed) {
                                _controller.reverse();
                              }
                            } else {
                              _controller.forward();
                            }
                          }
                        },
                        child: AnimatedLogoWidget(
                          id: _id,
                          youTubeVideoKey: _youTubeVideoKey,
                          description: _description,
                          logo: _logo,
                          scaleAnimation: _scaleAnimation,
                        ),
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
