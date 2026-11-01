import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/widgets/reusable_button.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';

class Buttons extends StatelessWidget {
  const Buttons({Key? key, required this.id, required this.youTubeVideoKey}) : super(key: key);
  final String id;
  final String youTubeVideoKey;

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    
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
              Text(
                "Play",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.scaffoldBackgroundColor,
                ),
              ),
            ],
          ),
          buttonWidth: 80,
          color: theme.colorScheme.primary,
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
                child: Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "More Info",
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          buttonWidth: 120,
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
