import 'package:flutter/material.dart';
import 'package:moviewebapp/app/models/post_model.dart';
import 'twitter_like_button.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key, required this.post}) : super(key: key);
  final PostModel post;

  final double iconSize = 20.0;
  final double textSize = 13.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TwitterLikeButton(
          isLiked: post.isLiked,
          likeCount: post.likeCount,
          iconSize: iconSize,
          textSize: textSize,
          onTap: (bool newIsLiked) {
            // Callback to update state or model
            debugPrint('Post liked status: $newIsLiked');
          },
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: iconSize, color: const Color(0xFF71767B)),
            const SizedBox(width: 1.0),
            Text(
              post.replyCount.toString(),
              style: TextStyle(fontSize: textSize, color: const Color(0xFF71767B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Icon(Icons.share_outlined, size: iconSize, color: const Color(0xFF71767B)),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Icon(Icons.bar_chart_rounded, size: iconSize, color: const Color(0xFF71767B)),
        //     const SizedBox(width: 1.0),
        //     Text(
        //       post.viewCount.toCompactCurrencyFormat(),
        //       style: TextStyle(fontSize: textSize, color: const Color(0xFF71767B), fontWeight: FontWeight.w500),
        //     ),
        //   ],
        // ),
        Icon(
          post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: iconSize,
          color: const Color(0xFF71767B),
        ),
      ],
    );
  }
}
