import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/home_page/widgets/button_widget.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:moviewebapp/app/core/utils/commom_functions.dart';

class MainTextWidget extends StatefulWidget {
  const MainTextWidget({Key? key}) : super(key: key);

  @override
  _MainTextWidgetState createState() => _MainTextWidgetState();
}

class _MainTextWidgetState extends State<MainTextWidget> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ProceedButton(
            buttonWidth: 80,
            bottomPAdding: 6,
            topPadding: 6,
            callingAPI: () {},
            text: "together",
            color: Colors.blue,
          ),
        ),
        Container(
          width: getMainTextSize(cardSize: screenWidth),
          // decoration: BoxDecoration(border: Border.all(color: BLACK, width: 1)),
          margin: const EdgeInsets.only(left: 0),
          child: Text(
            "Watch Your Favourite Movie With Your Partner",
            softWrap: true,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: BLACK,
                fontSize: getFontSize(fontSize: screenWidth),
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: getMainTextSize(cardSize: screenWidth),
          // decoration: BoxDecoration(border: Border.all(color: BLACK, width: 1)),
          margin: const EdgeInsets.only(left: 0, top: 10),
          child: const Text(
            "The easiest way to watch your favourite movie with your partner, friend, family and your beloved one, Together is better than lonely",
            softWrap: true,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: LIGHTBLACK, fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ProceedButton(
              buttonWidth: 85,
              bottomPAdding: 6,
              topPadding: 6,
              callingAPI: () {},
              text: "Learn more",
              color: Colors.blue,
              borderRadius: 4,
            ),
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: const Text(
                "About us",
                softWrap: true,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: BLUE, fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
