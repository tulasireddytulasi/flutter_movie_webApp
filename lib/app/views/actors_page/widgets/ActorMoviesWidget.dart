import 'package:flutter/material.dart';
import 'package:moviewebapp/app/models/actor_movie_model.dart';
import 'package:moviewebapp/app/views/widgets/custom_message.dart';
import 'package:moviewebapp/app/views/widgets/movies_card.dart';
import 'package:moviewebapp/app/providers/actors_info_provider.dart';
import 'package:moviewebapp/app/core/utils/navigation/navigation.dart';
import 'package:provider/provider.dart';

class ActorMoviesWidget extends StatefulWidget {
  const ActorMoviesWidget({Key? key, required this.actorId}) : super(key: key);

  final String actorId;

  @override
  State<ActorMoviesWidget> createState() => _ActorMoviesWidgetState();
}

class _ActorMoviesWidgetState extends State<ActorMoviesWidget> {
  late Future<ActorMovieModel> _moviesData;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    _moviesData = context.read<ActorsInfoProvider>().fetchActorMovies(actorId: widget.actorId);
  }

  @override
  void didUpdateWidget(covariant ActorMoviesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actorId != widget.actorId) _loadMovies();
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
            return const CustomMessage(text: "Unable to load movies.");
          } else if (snapshot.hasData) {
            final movies = snapshot.data!.cast ?? <Cast>[];
            if (movies.isEmpty) return const CustomMessage(text: "No Movies");
            return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: movies.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final movie = movies[index];
                  final movieId = movie.id?.toString() ?? '';
                  return MoviesCard(
                    key: ValueKey(movieId),
                    movieName: movie.title ?? '',
                    poster: movie.posterPath ?? '',
                    movieId: movieId,
                    voidCallback: () => Navigation().navigateFromActorInfoScreenToMoviesInfoPage(
                      context: context,
                      movieId: movieId,
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
