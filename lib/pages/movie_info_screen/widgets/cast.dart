import 'package:flutter/material.dart';
import 'package:moviewebapp/providers/movie_info_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:provider/provider.dart';

class Cast extends StatefulWidget {
  const Cast({Key? key}) : super(key: key);

  @override
  _CastState createState() => _CastState();
}

class _CastState extends State<Cast> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieInfoProvider>(
        builder: (context, movieInfoProvider, child) {
      return ListView.builder(
          itemCount: movieInfoProvider.actorImageUrl.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return CastCard(
              actorName: movieInfoProvider.actorName[index].toString(),
              castImage: movieInfoProvider.actorImageUrl[index].toString(),
            );
          });
    });
  }
}

class CastCard extends StatelessWidget {
  const CastCard({Key? key, required this.castImage, required this.actorName})
      : super(key: key);

  final String castImage;
  final String actorName;

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                getActorImageRadius(screenSize: _screenWidth)),
            child: Image.network(
              ApiConstants.movieImageBaseUrlw500 + castImage,
              height: getActorImageSize(screenSize: _screenWidth),
              width: getActorImageSize(screenSize: _screenWidth),
              fit: BoxFit.cover,
              color: Colors.grey,
              colorBlendMode: BlendMode.saturation,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 15, top: 10),
          width: 100,
          child: Text(
            actorName,
            style: const TextStyle(fontSize: 12, color: GREY),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
