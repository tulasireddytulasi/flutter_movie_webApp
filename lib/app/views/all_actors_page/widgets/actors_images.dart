import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';

class ActorsImages extends StatefulWidget {
  const ActorsImages({Key? key, required this.imageUrl}) : super(key: key);
  final String imageUrl;

  @override
  _ActorsImagesState createState() => _ActorsImagesState();
}

class _ActorsImagesState extends State<ActorsImages> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CircleAvatar(
        // radius: 5.0,
        backgroundImage:
            NetworkImage(ApiConstants.movieImageBaseUrlw500 + widget.imageUrl),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
