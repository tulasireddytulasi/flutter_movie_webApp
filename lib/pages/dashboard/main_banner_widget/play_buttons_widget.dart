import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/dashboard/widgets/icon_with_text_widget.dart';
import 'package:moviewebapp/pages/dashboard/widgets/play_button_widget.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

class PlayButtons extends StatefulWidget {
  const PlayButtons({Key? key, required this.genere}) : super(key: key);
  final List<String> genere;
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
    );
  }
}
