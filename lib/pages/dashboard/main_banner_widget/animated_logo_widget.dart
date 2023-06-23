import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/dashboard/widgets/buttons.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

class AnimatedLogoWidget extends StatefulWidget {
  const AnimatedLogoWidget({
    Key? key,
    required this.scaleAnimation,
    required this.id,
    required this.logo,
    required this.description,
    required this.youTubeVideoKey,
  }) : super(key: key);
  final Animation<double> scaleAnimation;
  final String id, logo, description, youTubeVideoKey;

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget> {
  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    final bool _screenWidth600 = _screenWidth >= 600;
    return Column(
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
          child: Text(
            widget.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              color: WHITE,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Buttons(id: widget.id, youTubeVideoKey: widget.youTubeVideoKey),
        const SizedBox(height: 50),
      ],
    );
  }
}
