import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    Key? key,
    required this.avatarImg,
    required this.authorName,
    required this.reviewDate,
    required this.reviewerRating,
    required this.reviewContent,
  }) : super(key: key);

  final String avatarImg;
  final String authorName;
  final String reviewDate;
  final String reviewerRating;
  final String reviewContent;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (avatarImg.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    avatarImg,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              if (avatarImg.isEmpty)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: WHITE,
                  child: Text(
                    authorName.isNotEmpty ? authorName[0] : "U",
                    style: const TextStyle(
                        fontSize: 18,
                        color: BLACK,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: WHITE,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reviewDate,
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
                label: Text(
                  reviewerRating,
                  style: const TextStyle(
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
          SizedBox(
            width: 280,
            child: Text(
              reviewContent,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
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
