import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';

class TextResponsiveWidget extends StatefulWidget {
  const TextResponsiveWidget({Key? key}) : super(key: key);

  @override
  _TextResponsiveWidgetState createState() => _TextResponsiveWidgetState();
}

class _TextResponsiveWidgetState extends State<TextResponsiveWidget> {
  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.all(30),
      child: Text(
        "_screenWidth: $_screenWidth, Width : ${(_screenWidth * 0.03)}, fontSize: ${getFontSize(fontSize: _screenWidth * 0.03)} The easiest way to watch your favourite movie with your partner, friend, family and your beloved one, Together is better than lonely",
        softWrap: true,
        textAlign: TextAlign.left,
        style: TextStyle(
            color: LIGHTBLACK,
            fontSize: getFontSize(fontSize: _screenWidth * 0.03),
            fontWeight: FontWeight.normal),
      ),
    );
  }
}
