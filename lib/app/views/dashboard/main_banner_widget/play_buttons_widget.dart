import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/icon_with_text_widget.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/play_button_widget.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';

class PlayButtons extends StatefulWidget {
  const PlayButtons({
    Key? key,
    required this.genere,
    required this.movieId,
    required this.youTubeVideoKey,
  }) : super(key: key);
  final List<String> genere;
  final String movieId;
  final String youTubeVideoKey;
  @override
  State<PlayButtons> createState() => _PlayButtonsState();
}

class _PlayButtonsState extends State<PlayButtons> {
  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    final bool _screenWidth600 = _screenWidth >= 600;
    return Visibility(
      visible: !_screenWidth600,
      child: Positioned(
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
                      widget.genere.length,
                      (index) => TextSpan(
                        text: widget.genere.length - 1 != index ? widget.genere[index] + " . " : widget.genere[index],
                        style: const TextStyle(fontSize: 12, color: WHITE, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const IconWithText(
                  icon: Icons.done,
                  label: Constants.myList,
                ),
                const SizedBox(width: 30),
                PlayButtonWidget(youTubeVideoKey: widget.youTubeVideoKey),
                const SizedBox(width: 30),
                InkWell(
                  onTap: () {
                    Navigation().navigateToMoviesInfoPage(
                      context: context,
                      movieId: widget.movieId,
                      screenWidth: _screenWidth,
                    );
                  },
                  child: const IconWithText(
                    icon: Icons.info_outline_rounded,
                    label: Constants.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
