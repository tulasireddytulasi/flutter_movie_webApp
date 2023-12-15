import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';

class CustomMessage extends StatelessWidget {
  const CustomMessage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: WHITE,
        ),
      ),
    );
  }
}
