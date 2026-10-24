import 'package:flutter/material.dart';
import 'package:moviewebapp/app/models/movie_banner_model.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:provider/provider.dart';
import 'horizontal_card.dart';
import 'vertical_card.dart';

class MovieBannerCard extends StatefulWidget {
  const MovieBannerCard({Key? key}) : super(key: key);

  @override
  State<MovieBannerCard> createState() => _MovieBannerCardState();
}

class _MovieBannerCardState extends State<MovieBannerCard> {
  late MoviesProvider _moviesProvider;

  @override
  void initState() {
    super.initState();
    _moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    _moviesProvider.getMovieDetails(pageNo: 1, movieType: "popular"); // popular upcoming
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive switch: Horizontal for tablet/desktop, Vertical for mobile
        bool isDesktopOrTablet = constraints.maxWidth > 700;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<MoviesProvider>(builder: (context, moviesProvider, child) {
            final MoviesList? movieData = moviesProvider.movieBannerModel.moviesList?.first;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktopOrTablet ? 1000 : 450,
              ),
              child: isDesktopOrTablet
                  ? HorizontalMovieCard(movieInfo: movieData)
                  : VerticalMovieCard(movieInfo: movieData),
            );
          }),
        );
      },
    );
  }
}
