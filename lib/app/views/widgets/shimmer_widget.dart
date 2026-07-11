import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatefulWidget {
  const ShimmerWidget({Key? key}) : super(key: key);

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget> {
  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: SizedBox(
        //height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
        child: Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.grey.withOpacity(0.6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                6,
                    (index) => Container(
                  margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                  width: getSimilarMoviesImageWidth(screenSize: _screenWidth),
                  height: getSimilarMoviesImageHeight(screenSize: _screenWidth),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
