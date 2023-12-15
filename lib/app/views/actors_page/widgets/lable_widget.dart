import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';

class LabelWidget extends StatelessWidget {
  final String label;
  const LabelWidget({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: _screenWidth / 1,
      // decoration:  BoxDecoration(
      //     border: Border.all(color: WHITE, width: 1),
      //     color: WHITE,
      //     ),
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 15),
      child: Text(
        label,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 4,
        textAlign: TextAlign.start,
        style: const TextStyle(
            fontSize: 18, color: WHITE, fontWeight: FontWeight.w500),
      ),
    );
  }
}
