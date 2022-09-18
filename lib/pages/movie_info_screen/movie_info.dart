import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/cast.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/rating_row_widget.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/similar_movies.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';

class MovieInfoScreen extends StatefulWidget {
  const MovieInfoScreen({Key? key}) : super(key: key);

  @override
  _MovieInfoScreenState createState() => _MovieInfoScreenState();
}

class _MovieInfoScreenState extends State<MovieInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tealishBlue,
      appBar: AppBar(
          toolbarHeight: 190,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    pickledBlueWood,
                    pickledBlueWood,
                    Colors.transparent
                  ],
                ).createShader(Rect.fromLTRB(0, 1, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.network(
                ApiConstants.backDropUrl,
                fit: BoxFit.cover,
              ),
            ),
          )),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RatingWidget(),
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 15, top: 5),
                child: const Text(
                  "Dune",
                  style: TextStyle(fontSize: 26, color: WHITE),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 15, top: 5),
                child: const Text(
                  "2h 35m . Action, Adventure, Drama . 2021",
                  style: TextStyle(fontSize: 14, color: ICON_GREY),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 15, top: 20),
                child: const Text(
                  "A noble family becomes embroiled in a war for control over the galaxy's most valuable asset while its heir becomes troubled by visions of a dark future.",
                  style: TextStyle(fontSize: 14, color: ICON_GREY),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 15, top: 20),
                child: const Text(
                  "Top Cast",
                  style: TextStyle(fontSize: 22, color: GREY),
                ),
              ),
              Container(
                height: 150,
                margin: const EdgeInsets.only(top: 20),
                child: const Cast(),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 15, top: 20),
                child: const Text(
                  "Similar Movies",
                  style: TextStyle(fontSize: 22, color: GREY),
                ),
              ),
              Container(
                height: 180,
                margin: const EdgeInsets.only(top: 20),
                child: const SimilarMovies(),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin:
                        const EdgeInsets.only(top: 20, bottom: 20, left: 10),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: tuna),
                    height: 50,
                    width: 130,
                    child: const Text(
                      "TRAILER",
                      style: TextStyle(fontSize: 20, color: WHITE),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(top: 20, bottom: 20, left: 10),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.blue),
                    height: 50,
                    width: 200,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.play_arrow,
                          color: WHITE,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "PLAY NOW",
                          style: TextStyle(fontSize: 20, color: WHITE),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
