import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/movie_info_screen/widgets/reviews_card_widget.dart';

class ReviewsList extends StatelessWidget {
  const ReviewsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return const ReviewCard();
        },
      ),
    );
  }
}
