import 'package:flutter/material.dart';
import 'package:moviewebapp/models/actor_movie_model.dart';
import 'package:moviewebapp/pages/widgets/custom_message.dart';
import 'package:moviewebapp/pages/widgets/movies_card.dart';
import 'package:moviewebapp/providers/actors_info_provider.dart';
import 'package:moviewebapp/responses/movie_apis.dart';
import 'package:moviewebapp/utils/navigation/navigation.dart';
import 'package:provider/provider.dart';

class ActorMoviesWidget extends StatefulWidget {
  const ActorMoviesWidget({Key? key, required this.actorId}) : super(key: key);

  final String actorId;

  @override
  State<ActorMoviesWidget> createState() => _ActorMoviesWidgetState();
}

class _ActorMoviesWidgetState extends State<ActorMoviesWidget> {
  ActorMovieModel _moviesModel = ActorMovieModel();

  late Future<ActorMovieModel> _moviesData;
  final List<String> _title = [];
  final List<String> _movieId = [];
  final List<String> _img = [];
  static int totalMovies = 0;

  clearData() {
    _title.clear();
    _movieId.clear();
    _img.clear();
  }

  processData({required ActorMovieModel moviesModel}) {
    _moviesModel.cast?.forEach((element) {
      _title.add(element.title ?? "");
      _img.add(element.posterPath ?? "");
      _movieId.add(element.id.toString());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final actorsInfoProvider = Provider.of<ActorsInfoProvider>(context, listen: false);
      _moviesModel = moviesModel;
      totalMovies = moviesModel.cast?.length ?? 0;
      actorsInfoProvider.setTotalMoviesActed(totalMoviesActed: totalMovies);
    });
  }

  @override
  void initState() {
    super.initState();
    _moviesData = getActorsActedMoviesInfo(
      actorId: widget.actorId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: _moviesData,
      builder: (BuildContext context, AsyncSnapshot<ActorMovieModel> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const CustomMessage(text: "Error");
          } else if (snapshot.hasData) {
            clearData();
            processData(moviesModel: snapshot.data!);
            return ListView.builder(
                itemCount: _title.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return MoviesCard(
                    movieName: _title[index],
                    poster: _img[index],
                    movieId: _movieId[index],
                    voidCallback: () => Navigation().navigateFromActorInfoScreenToMoviesInfoPage(
                      context: context,
                      movieId: _movieId[index],
                      screenWidth: _screenWidth,
                    ),
                  );
                });
          } else {
            return const CustomMessage(text: "No Movies");
          }
        } else {
          return CustomMessage(text: "State: ${snapshot.connectionState}");
        }
      },
    );
  }
}
