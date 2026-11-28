import 'package:flutter/material.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/views/auth_screen/email_login_dialog.dart';
import 'package:provider/provider.dart';

class MovieLikeButton extends StatelessWidget {
  const MovieLikeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieInfoProvider>(
      builder: (context, movieInfo, _) {
        final error = movieInfo.movieLikeError;
        return IconButton(
          tooltip: error ?? (movieInfo.hasLikedMovie ? 'Unlike movie' : 'Like movie'),
          onPressed: movieInfo.canToggleMovieLike
              ? () async {
                  // Dialogs and notifications stay in the UI layer.
                  final message = await movieInfo.toggleMovieLike(requestLogin: () => showMovieLoginDialog(context));
                  if (context.mounted && message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                  }
                }
              : null,
          icon: movieInfo.isMovieLikeBusy
              ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(
                  error != null
                      ? Icons.refresh
                      : movieInfo.hasLikedMovie
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: movieInfo.hasLikedMovie ? Theme.of(context).colorScheme.primary : null,
                  size: 28,
                ),
        );
      },
    );
  }
}
