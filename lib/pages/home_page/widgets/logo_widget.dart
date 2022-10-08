import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/assets_path.dart';

class LogosWidget extends StatefulWidget {
  const LogosWidget({Key? key, required this.screenWidth}) : super(key: key);
  final double screenWidth;
  @override
  _LogosWidgetState createState() => _LogosWidgetState();
}

class _LogosWidgetState extends State<LogosWidget> {
  @override
  Widget build(BuildContext context) {
    double logoWidth = widget.screenWidth / 6.5;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LogoWidget(logoAsset: netflixLogo, logoWidth: logoWidth),
          LogoWidget(logoAsset: hboLogo, logoWidth: logoWidth),
          LogoWidget(logoAsset: huluLogo, logoWidth: logoWidth),
          LogoWidget(logoAsset: disneyPlusLogo, logoWidth: logoWidth),
          LogoWidget(logoAsset: primeVideosLogo, logoWidth: logoWidth),
        ],
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget(
      {Key? key, required this.logoAsset, required this.logoWidth, this.color})
      : super(key: key);
  final String logoAsset;
  final double logoWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      //  decoration: BoxDecoration(border: Border.all(color: BLACK, width: 1)),
      child: Image.asset(
        logoAsset,
        width: logoWidth,
        fit: BoxFit.cover,
        color: color,
      ),
    );
  }
}
