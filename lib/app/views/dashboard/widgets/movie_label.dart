import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/constants.dart';

class MovieLabel extends StatelessWidget {
  const MovieLabel({Key? key, required this.movieLabel, required this.onTap})
      : super(key: key);
  final String movieLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: screen <= 500 ? 220 : null,
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 15, top: 0),
          child: Text(
            movieLabel,
            softWrap: true,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 10, top: 0),
                child: Text(
                  Constants.viewMore,
                  style: theme.textTheme.bodyMedium?.copyWith(fontFamily: montserratSemiBold),
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                margin: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_outlined,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
