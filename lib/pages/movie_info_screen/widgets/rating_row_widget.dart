import 'package:flutter/material.dart';
import 'package:moviewebapp/providers/movie_info_provider.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:provider/provider.dart';

class RatingWidget extends StatefulWidget {
  const RatingWidget({Key? key}) : super(key: key);

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
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
            child: const Text(
              "8.2",
              style: TextStyle(fontSize: 18, color: WHITE),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 0),
            child: const Text(
              " | 1055",
              style: TextStyle(fontSize: 14, color: ICON_GREY),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(0),
            child: InkWell(
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.favorite_border,
                  color: LIGHTWHITE,
                ),
              ),
              onTap: () {
                final movieInfoProvider =
                    Provider.of<MovieInfoProvider>(context, listen: false);
                movieInfoProvider.clearBackdropPath();
                Navigator.pop(context);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(0),
            child: InkWell(
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.share,
                  color: LIGHTWHITE,
                ),
              ),
              onTap: () {},
            ),
          ),
          Container(
            padding: const EdgeInsets.all(0),
            child: InkWell(
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.copy,
                  color: LIGHTWHITE,
                ),
              ),
              onTap: () {},
            ),
          )
        ],
      ),
    );
  }
}
