import 'package:flutter/material.dart';
import 'package:moviewebapp/providers/actors_info_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:provider/provider.dart';

class ActorsImages extends StatefulWidget {
  ActorsImages({Key? key}) : super(key: key);

  @override
  _ActorsImagesState createState() => _ActorsImagesState();
}

class _ActorsImagesState extends State<ActorsImages> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ActorsInfoProvider>(
        builder: (context, actorInfoProvider, child) {
      return actorInfoProvider.actorsImages.isNotEmpty
          ? ListView.builder(
              itemCount: actorInfoProvider.actorsImages.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return ActorsImagesCard(
                  actorImage: actorInfoProvider.actorsImages[index].toString(),
                );
              })
          : Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                "No Actor Images",
                style: TextStyle(fontSize: 18, color: GREY),
              ),
            );
    });
  }
}

class ActorsImagesCard extends StatelessWidget {
  ActorsImagesCard({
    Key? key,
    required this.actorImage,
  }) : super(key: key);

  final String actorImage;

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.network(
                ApiConstants.movieImageBaseUrlw185 + actorImage,
                width: getSimilarMoviesImageWidth(screenSize: _screenWidth),
                height: getSimilarMoviesImageHeight(screenSize: _screenWidth),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
