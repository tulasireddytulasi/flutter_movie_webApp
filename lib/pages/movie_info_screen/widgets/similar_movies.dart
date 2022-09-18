import 'package:flutter/material.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';

class SimilarMovies extends StatefulWidget {
  const SimilarMovies({Key? key}) : super(key: key);

  @override
  _SimilarMoviesState createState() => _SimilarMoviesState();
}

class _SimilarMoviesState extends State<SimilarMovies> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: ApiConstants.castList.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return SimilarMovieCard(
            actorName: ApiConstants.castList[index]["name"].toString(),
            castImage: ApiConstants.castList[index]["profile_path"].toString(),
          );
        });
  }
}

class SimilarMovieCard extends StatelessWidget {
  const SimilarMovieCard(
      {Key? key, required this.castImage, required this.actorName})
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
            borderRadius: BorderRadius.circular(5.0),
            child: Image.network(
              ApiConstants.movieImageBaseUrl + castImage,
              width: 100,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 15, top: 10),
          width: 100,
          child: Text(
            actorName,
            style: const TextStyle(fontSize: 12, color: GREY),
            maxLines: 2,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
