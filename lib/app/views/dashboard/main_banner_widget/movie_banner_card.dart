import 'package:flutter/material.dart';
import 'horizontal_card.dart';
import 'vertical_card.dart';

class MovieBannerCard extends StatelessWidget {
  const MovieBannerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive switch: Horizontal for tablet/desktop, Vertical for mobile
        bool isDesktopOrTablet = constraints.maxWidth > 700;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktopOrTablet ? 1000 : 450,
              ),
              child: isDesktopOrTablet
                  ? const HorizontalMovieCard()
                  : const VerticalMovieCard(),
            ),
          ),
        );
      },
    );
  }
}
