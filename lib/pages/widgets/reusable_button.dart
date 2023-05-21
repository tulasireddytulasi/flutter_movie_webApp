import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

class ProceedButton extends StatelessWidget {
  final String? text;
  final void Function() callingAPI;
  final double buttonWidth;
  final double topPadding;
  final double bottomPadding;
  final Color color;
  final double borderRadius;
  final Widget? childWidget;
  const ProceedButton({
    Key? key,
    this.text,
    required this.callingAPI,
    required this.buttonWidth,
    this.topPadding = 14,
    this.bottomPadding = 14,
    this.color = Colors.green,
    this.borderRadius = 25,
    this.childWidget,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: callingAPI,
        child: Container(
          alignment: Alignment.center,
          width: buttonWidth,
          padding: EdgeInsets.only(bottom: bottomPadding, top: topPadding),
          child: childWidget ??
              Text(
                text ?? "",
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: montserratRegular,
                  color: WHITE,
                ),
              ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
      ),
    );
  }
}
