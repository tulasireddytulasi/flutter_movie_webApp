import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moviewebapp/app/models/post_model.dart';
import 'package:moviewebapp/app/views/twitter_ui/widgets/twitter_like_button.dart';

class PreviewInfoCard extends StatefulWidget {
  const PreviewInfoCard({Key? key, required this.post}) : super(key: key);

  final PostModel post;

  @override
  State<PreviewInfoCard> createState() => _PreviewInfoCardState();
}

class _PreviewInfoCardState extends State<PreviewInfoCard> {
  @override
  Widget build(BuildContext context) {
    // ClipRRect
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // User Header Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: CachedNetworkImage(
                  imageUrl: widget.post.avatarUrl,
                  width: 36.0,
                  height: 36.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: const Color(0xFF2F3336)),
                  errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white54, size: 20),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.post.name,
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        const Icon(Icons.verified, color: Color(0xFF1D9BF0), size: 13.0),
                      ],
                    ),
                    Text(
                      widget.post.handle,
                      style: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 12.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              // Pill-shaped Follow Button
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Caption Text
          Text(
            widget.post.content,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 14.0,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12.0),
          // Interaction Footer Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Reply Count
              _buildInteractionItem(
                icon: Icons.chat_bubble_outline_rounded,
                count: widget.post.replyCount,
              ),
              // Repost Count
              _buildInteractionItem(
                icon: Icons.repeat_rounded,
                count: widget.post.repostCount,
              ),
              // Like Button with Heart
              TwitterLikeButton(
                isLiked: widget.post.isLiked,
                likeCount: widget.post.likeCount,
                onTap: (newLiked) {
                  setState(() {
                    widget.post.isLiked = newLiked;
                    widget.post.likeCount += newLiked ? 1 : -1;
                  });
                },
                iconSize: 21.0,
                textSize: 13.0,
              ),
              // Bookmark Icon
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  widget.post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 21.0,
                  color: widget.post.isBookmarked ? const Color(0xFF1D9BF0) : const Color(0xFFFFFFFF),
                ),
                onPressed: () {
                  setState(() {
                    widget.post.isBookmarked = !widget.post.isBookmarked;
                  });
                },
              ),
              // Share Icon
              const Icon(
                Icons.share_outlined,
                size: 21.0,
                color: Color(0xFFFFFFFF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionItem({required IconData icon, required int count}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19.0, color: const Color(0xFFFFFFFF)),
        const SizedBox(width: 4.0),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 13.0,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
