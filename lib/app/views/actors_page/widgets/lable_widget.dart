import 'package:flutter/material.dart';

class LabelWidget extends StatelessWidget {
  final String label;
  const LabelWidget({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth / 1,
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 15),
      child: Text(
        label,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 4,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
