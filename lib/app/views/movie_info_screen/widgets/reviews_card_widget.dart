import 'package:flutter/material.dart';

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
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    authorName.isNotEmpty ? authorName[0] : "U",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    authorName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reviewDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 60),
              ChoiceChip(
                selected: false,
                label: Text(
                  reviewerRating,
                  style: Theme.of(context).textTheme.labelLarge,
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
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
