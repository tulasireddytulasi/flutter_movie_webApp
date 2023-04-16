import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/widgets/reusable_button.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

class Buttons extends StatelessWidget {
  const Buttons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProceedButton(
          childWidget: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(0.0),
                child: Image.asset(
                  pauseIcon,
                  fit: BoxFit.cover,
                  width: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Play",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: montserratSemiBold,
                  color: PURE_BLACK,
                ),
              ),
            ],
          ),
          buttonWidth: 80,
          color: WHITE,
          borderRadius: 4,
          callingAPI: () {},
          bottomPAdding: 10,
          topPadding: 10,
        ),
        const SizedBox(width: 10),
        ProceedButton(
          childWidget: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(0.0),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: WHITE,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "More Info",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: montserratSemiBold,
                  color: WHITE,
                ),
              ),
            ],
          ),
          buttonWidth: 120,
          color: WHITE.withOpacity(0.1),
          borderRadius: 4,
          callingAPI: () {},
          bottomPAdding: 10,
          topPadding: 10,
        ),
      ],
    );
  }
}
