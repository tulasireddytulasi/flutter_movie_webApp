import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/dashboard/widgets/icon_with_text_widget.dart';
import 'package:moviewebapp/pages/dashboard/widgets/play_button_widget.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

class MainBanner extends StatefulWidget {
  const MainBanner({Key? key}) : super(key: key);

  @override
  _MainBannerState createState() => _MainBannerState();
}

class _MainBannerState extends State<MainBanner> {
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
          child: Image.network(
            ApiConstants.movieImageBaseUrlw500 +
                "/9Gtg2DzBhmYamXBS1hKAhiwbBKS.jpg",
            fit: BoxFit.cover,
            height: 560,
            width: double.infinity,
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
      ],
    );
  }
}
