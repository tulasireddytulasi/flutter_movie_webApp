import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';

class TrailerButtons extends StatefulWidget {
  const TrailerButtons({Key? key}) : super(key: key);

  @override
  _TrailerButtonsState createState() => _TrailerButtonsState();
}

class _TrailerButtonsState extends State<TrailerButtons> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20, left: 10),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.blue),
      height: 50,
      width: 200,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.play_arrow,
            color: WHITE,
          ),
          SizedBox(width: 5),
          Text(
            "PLAY NOW",
            style: TextStyle(fontSize: 20, color: WHITE),
          ),
        ],
      ),
    );
  }
}
