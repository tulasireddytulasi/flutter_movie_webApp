import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/widgets/movies_card.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    Key? key,
    required this.imageURL,
    required this.movieName,
    required this.movieId,
    required this.onTap,
  }) : super(key: key);

  final String imageURL;
  final String movieName;
  final String movieId;
  final VoidCallback onTap;

  static int columnsFor(double width) {
    if (width < 300) return 2;
    if (width < 600) return 3;
    return (width / 160).floor().clamp(4, 10).toInt();
  }

  @override
  Widget build(BuildContext context) => MoviesCard(
        poster: imageURL,
        movieName: movieName,
        movieId: movieId,
        voidCallback: onTap,
        fillWidth: true,
      );
}
