import 'package:flutter/material.dart';

class TrailerButtons extends StatefulWidget {
  const TrailerButtons({Key? key}) : super(key: key);

  @override
  State<TrailerButtons> createState() => _TrailerButtonsState();
}

class _TrailerButtonsState extends State<TrailerButtons> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20, left: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: theme.colorScheme.tertiary),
      height: 50,
      width: 200,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_arrow_rounded,
            color: theme.colorScheme.onTertiary,
          ),
          const SizedBox(width: 5),
          Text(
            "PLAY NOW",
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onTertiary,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
