import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';

class PlayButtonWidget extends StatelessWidget {
  const PlayButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Container(
        width: 56,
        padding: const EdgeInsets.only(bottom: 1, top: 1),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(0.0),
              child: Image.asset(
                pauseIcon,
                fit: BoxFit.cover,
                width: 14,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Play",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: BLACK,
              ),
            ),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: WHITE,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}