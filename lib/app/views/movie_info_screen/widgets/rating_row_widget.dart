import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:moviewebapp/app/providers/universal_provider.dart';
import 'package:provider/provider.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieInfoProvider>(builder: (context, movieInfoProvider, child) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.star,
              color: PALE_GOLD,
            ),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.only(left: 0),
            child: Text(
              movieInfoProvider.rating,
              style: const TextStyle(fontSize: 18, color: WHITE),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 0),
            child: Text(
              " | ${movieInfoProvider.voteCount}",
              style: const TextStyle(fontSize: 14, color: ICON_GREY),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              child: const Icon(
                Icons.favorite_border,
                color: LIGHTWHITE,
                size: 28,
              ),
              onTap: () {
                showCustomSnackBar(
                  context: context,
                  message: 'Opps!, This is not available!',
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () async {
                if (movieInfoProvider.movieTitle.isEmpty && movieInfoProvider.backdropPath.isEmpty) return;
                final String name = "Movie Name: ${movieInfoProvider.movieTitle}";

                final UniversalProvider universalProvider = Provider.of<UniversalProvider>(context, listen: false);

                final bool result = await universalProvider.shareImage(
                  baseUrl: ApiConstants.movieImageBaseUrlw500,
                  imgUrl: movieInfoProvider.backdropPath,
                  descText: name,
                );
              },
              child: const Icon(
                Icons.share,
                color: LIGHTWHITE,
                size: 28,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              child: const Icon(
                Icons.copy,
                color: LIGHTWHITE,
                size: 28,
              ),
              onTap: () {
                showCustomSnackBar(
                  context: context,
                  message: 'Opps!, This is not available!',
                );
              },
            ),
          )
        ],
      );
    });
  }
}
