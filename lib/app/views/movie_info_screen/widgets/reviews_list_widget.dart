import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/reviews_card_widget.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:provider/provider.dart';

class ReviewsList extends StatefulWidget {
  const ReviewsList({Key? key, required this.movieId}) : super(key: key);
  final String movieId;

  @override
  State<ReviewsList> createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieInfoProvider =
          Provider.of<MovieInfoProvider>(context, listen: false);
      movieInfoProvider.getMovieReviewsInfoAPI(
          movieId: widget.movieId, pageNo: "1");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieInfoProvider>(
        builder: (context, movieInfoProvider, child) {
      return movieInfoProvider.reviewContent.isNotEmpty
          ? ListView.builder(
              itemCount: movieInfoProvider.reviewContent.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return ReviewCard(
                  avatarImg: movieInfoProvider.avatarImg[index],
                  authorName: movieInfoProvider.authorName[index],
                  reviewDate: movieInfoProvider.reviewDate[index],
                  reviewerRating: movieInfoProvider.reviewerRating[index],
                  reviewContent: movieInfoProvider.reviewContent[index],
                );
              },
            )
          : Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                "No Movie Reviews",
                style: TextStyle(fontSize: 18, color: GREY),
              ),
            );
      ;
    });
  }
}
