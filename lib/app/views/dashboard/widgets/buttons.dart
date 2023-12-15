import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/widgets/reusable_button.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';

class Buttons extends StatelessWidget {
  const Buttons({Key? key, required this.id, required this.youTubeVideoKey}) : super(key: key);
  final String id;
  final String youTubeVideoKey;

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        ProceedButton(
          childWidget: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(0.0),
                child: Image.asset(pauseIcon, fit: BoxFit.cover, width: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                "Play",
                style: TextStyle(fontSize: 14, fontFamily: montserratSemiBold, color: PURE_BLACK),
              ),
            ],
          ),
          buttonWidth: 80,
          color: WHITE,
          borderRadius: 4,
          callingAPI: () => Navigation().youTubeScreen(context: context, youTubeVideoKey: youTubeVideoKey),
          bottomPadding: 10,
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
          callingAPI: () {
            Navigation().navigateToMoviesInfoPage(
              context: context,
              movieId: id,
              screenWidth: _screenWidth,
            );
          },
          bottomPadding: 10,
          topPadding: 10,
        ),
      ],
    );
  }
}
