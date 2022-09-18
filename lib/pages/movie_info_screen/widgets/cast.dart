import 'package:flutter/material.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';

class Cast extends StatefulWidget {
  const Cast({Key? key}) : super(key: key);

  @override
  _CastState createState() => _CastState();
}

class _CastState extends State<Cast> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: ApiConstants.castList.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return CastCard(
            actorName: ApiConstants.castList[index]["name"].toString(),
            castImage: ApiConstants.castList[index]["profile_path"].toString(),
          );
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: Image.network(
              ApiConstants.movieImageBaseUrl + castImage,
              height: 100,
              width: 100,
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
