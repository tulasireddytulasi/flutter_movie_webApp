import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';

class MovieLabel extends StatelessWidget {
  const MovieLabel({Key? key, required this.movieLabel}) : super(key: key);
  final String movieLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 15, top: 0),
          child: Text(
            movieLabel,
            style: const TextStyle(fontSize: 22, color: WHITE),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(right: 15),
          child: const Icon(
            Icons.chevron_right_outlined,
            size: 24,
            color: WHITE,
          ),
        )
      ],
    );
  }
}
