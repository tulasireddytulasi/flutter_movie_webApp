import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/dashboard/widgets/buttons.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

class AnimatedLogoWidget extends StatefulWidget {
  const AnimatedLogoWidget({
    Key? key,
    required this.scaleAnimation,
    required this.logo,
    required this.description,
  }) : super(key: key);
  final Animation<double> scaleAnimation;
  final String logo, description;

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget> {
  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    final bool _screenWidth600 = _screenWidth >= 600;
    return Visibility(
      visible: _screenWidth600,
      child: Positioned(
        bottom: 0,
        left: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaleTransition(
              scale: widget.scaleAnimation,
              alignment: Alignment.bottomLeft,
              child: Image.network(
                ApiConstants.movieImageBaseUrlw500 + widget.logo,
                width: 200,
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: _screenWidth600 ? 500 : _screenWidth - 40,
              child: const Text(
                Constants.longText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: WHITE,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Buttons(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
