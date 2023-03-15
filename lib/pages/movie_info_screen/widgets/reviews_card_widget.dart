import 'package:flutter/material.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: WHITE.withOpacity(0.5), width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  ApiConstants.movieImageBaseUrlw185 +
                      "/MhBiZbryibwuoEtPL9Ns8pYHC1.jpg",
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Winston Duke",
                    style: TextStyle(
                      fontSize: 14,
                      color: WHITE,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "on May 21, 2017",
                    // "13 days ago",
                    style: TextStyle(
                      fontSize: 12,
                      color: WHITE.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 60),
              ChoiceChip(
                selected: false,
                label: const Text(
                  "8.0",
                  style: TextStyle(
                    fontSize: 14,
                    color: BLACK,
                  ),
                ),
                avatar: const Icon(Icons.star, size: 20),
                padding: const EdgeInsets.all(4),
                onSelected: (bool selected) {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(
            width: 280,
            child: Text(
              Constants.reviewText,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: WHITE,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
