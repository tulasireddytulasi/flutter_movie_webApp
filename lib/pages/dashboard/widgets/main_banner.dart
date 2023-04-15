import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/dashboard/widgets/icon_with_text_widget.dart';
import 'package:moviewebapp/pages/dashboard/widgets/play_button_widget.dart';
import 'package:moviewebapp/providers/dashboard_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MainBanner extends StatefulWidget {
  const MainBanner({Key? key}) : super(key: key);

  @override
  _MainBannerState createState() => _MainBannerState();
}

class _MainBannerState extends State<MainBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  double result = 400;
  int result1 = 170;
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
    genere.join(" . ");
    // Create an animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Create a Tween for the scale animation
    _scaleAnimation = Tween<double>(
      begin: 2.0,
      end: 1.0,
    ).animate(_controller);
    _startAnimation();
    // Add a listener to the animation to print its value
    _scaleAnimation.addListener(() {
      if (result1 > 20) {
        setState(() {
          result = (170 + _scaleAnimation.value * 200) - 400;
          result1 = result.toInt();
          if (result1 < 20) {
            result1 = 20;
          }
        });
      }
    });
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(seconds: 4));
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
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
    return Consumer<DashBoardProvider>(
        builder: (context, dashBoardProvider, child) {
      final String poster = _screenWidth600
          ? dashBoardProvider.backdropPath
          : dashBoardProvider.moviePoster;
      final String posterSize = _screenWidth600
          ? ApiConstants.movieImageBaseUrlw1280
          : ApiConstants.movieImageBaseUrlw500;
      return Stack(
        children: [
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  tealishBlue,
                  tealishBlue,
                  Colors.transparent,
                ],
              ).createShader(
                Rect.fromLTRB(0, 1, rect.width, rect.height),
              );
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
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      text: TextSpan(
                        children: List.generate(
                          genere.length,
                          (index) => TextSpan(
                            text: genere.length - 1 != index
                                ? genere[index] + " . "
                                : genere[index],
                            style: const TextStyle(
                                fontSize: 12,
                                color: WHITE,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    IconWithText(
                      icon: Icons.done,
                      label: Constants.myList,
                    ),
                    SizedBox(width: 30),
                    PlayButtonWidget(),
                    SizedBox(width: 30),
                    IconWithText(
                      icon: Icons.info_outline_rounded,
                      label: Constants.info,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 150,
            left: result1.toDouble(), // leftValue ? 170 : _controller.value
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: 320,
                child: Text(
                  dashBoardProvider.movieTitle,
                  style: const TextStyle(
                      fontSize: 42,
                      color: WHITE,
                      fontFamily: montserratSemiBold),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
