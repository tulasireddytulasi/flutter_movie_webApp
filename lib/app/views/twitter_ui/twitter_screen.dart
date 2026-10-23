import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moviewebapp/app/core/repository/json_objects/x_post_json.dart';
import 'package:moviewebapp/app/core/utils/extensions.dart';
import 'dart:convert';

import 'package:moviewebapp/app/models/post_model.dart';
// ==========================================
// 1. DATA MODELS
// ==========================================



// ==========================================
// 2. MOCK DATA (Using Provided CDN URLs)
// ==========================================

// Assuming jsonString is your raw JSON string data:
final List<PostModel> mockPosts = XPostJson.marvelMovies
    .map((item) => PostModel.fromJson(item))
    .toList();

// ==========================================
// 3. MAIN FEED SCREEN
// ==========================================

class TwitterFeedScreen extends StatelessWidget {
  const TwitterFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // True Pure Black
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        title: const Icon(Icons.flutter_dash, color: Color(0xFF1D9BF0), size: 28),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFF2F3336),
            height: 1.0,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: mockPosts.length,
        separatorBuilder: (context, index) => const Divider(
          color: Color(0xFF2F3336),
          height: 1.0,
          thickness: 1.0,
        ),
        itemBuilder: (context, index) {
          return PostCardWidget(post: mockPosts[index]);
        },
      ),
    );
  }
}

// ==========================================
// 4. POST CARD COMPONENT
// ==========================================

class PostCardWidget extends StatefulWidget {
  final PostModel post;

  const PostCardWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: CachedNetworkImage(
              imageUrl: widget.post.avatarUrl,
              width: 40.0,
              height: 40.0,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: const Color(0xFF2F3336)),
              errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white54),
            ),
          ),
          const SizedBox(width: 12.0),
          // Post Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.post.name,
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          const Icon(Icons.verified, color: Color(0xFF1D9BF0), size: 14.0),
                          const SizedBox(width: 6.0),
                          Flexible(
                            child: Text(
                              '${widget.post.handle} · ${widget.post.timestamp}',
                              style: const TextStyle(
                                color: Color(0xFF71767B),
                                fontSize: 14.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_horiz, color: Color(0xFF71767B), size: 18.0),
                  ],
                ),
                const SizedBox(height: 4.0),
                // Post Text Body
                Text(
                  widget.post.content,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 15.0,
                    height: 1.35,
                  ),
                ),
                // Dynamic Media Grid (if images exist)
                if (widget.post.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  DynamicMediaContainer(imageUrls: widget.post.imageUrls),
                ],
                const SizedBox(height: 12.0),
                // Interaction Footer Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      count: widget.post.replyCount,
                      color: const Color(0xFF71767B),
                      onTap: () {},
                    ),
                    _ActionItem(
                      icon: Icons.repeat_rounded,
                      count: widget.post.repostCount,
                      color: widget.post.isReposted ? const Color(0xFF00BA7C) : const Color(0xFF71767B),
                      isActive: widget.post.isReposted,
                      onTap: () {
                        setState(() {
                          widget.post.isReposted = !widget.post.isReposted;
                          widget.post.repostCount += widget.post.isReposted ? 1 : -1;
                        });
                      },
                    ),
                    _ActionItem(
                      icon: widget.post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      count: widget.post.likeCount,
                      color: widget.post.isLiked ? const Color(0xFFF91880) : const Color(0xFF71767B),
                      isActive: widget.post.isLiked,
                      onTap: () {
                        setState(() {
                          widget.post.isLiked = !widget.post.isLiked;
                          widget.post.likeCount += widget.post.isLiked ? 1 : -1;
                        });
                      },
                    ),
                    _ActionItem(
                      icon: Icons.bar_chart_rounded,
                      count: widget.post.viewCount,
                      color: const Color(0xFF71767B),
                      onTap: () {},
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            widget.post.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: widget.post.isBookmarked ? const Color(0xFF1D9BF0) : const Color(0xFF71767B),
                            size: 18.0,
                          ),
                          onPressed: () {
                            setState(() {
                              widget.post.isBookmarked = !widget.post.isBookmarked;
                            });
                          },
                        ),
                        const SizedBox(width: 8.0),
                        const Icon(Icons.share_outlined, color: Color(0xFF71767B), size: 18.0),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. DYNAMIC MEDIA CONTAINER
// ==========================================

class DynamicMediaContainer extends StatelessWidget {
  final List<String> imageUrls;

  const DynamicMediaContainer({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2F3336), width: 1.0),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: _buildLayout(context),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    switch (imageUrls.length) {
      case 1:
        return _buildSingleImage(imageUrls[0]);
      case 2:
        return _buildTwoImages(imageUrls);
      case 3:
        return _buildThreeImages(imageUrls);
      case 4:
      default:
        return _buildFourImages(imageUrls);
    }
  }

  // 1 Photo: Natural Aspect Ratio with Maximum Height Constraint (380px)
  Widget _buildSingleImage(String url) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 380.0),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(height: 250, color: const Color(0xFF2F3336)),
        errorWidget: (context, _, __) => Container(height: 250, color: const Color(0xFF2F3336), child: const Icon(Icons.error)),
      ),
    );
  }

  // 2 Photos: Side-by-side equal columns with 2px gap
  Widget _buildTwoImages(List<String> urls) {
    return SizedBox(
      height: 220.0,
      child: Row(
        children: [
          Expanded(child: _networkImage(urls[0])),
          const SizedBox(width: 2.0),
          Expanded(child: _networkImage(urls[1])),
        ],
      ),
    );
  }

  // 3 Photos: 1 Large Left + 2 Stacked Right with 2px gaps
  Widget _buildThreeImages(List<String> urls) {
    return SizedBox(
      height: 260.0,
      child: Row(
        children: [
          Expanded(child: _networkImage(urls[0])),
          const SizedBox(width: 2.0),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _networkImage(urls[1])),
                const SizedBox(height: 2.0),
                Expanded(child: _networkImage(urls[2])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4 Photos: 2x2 Equal Grid with 2px gaps horizontally and vertically
  Widget _buildFourImages(List<String> urls) {
    return SizedBox(
      height: 260.0,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _networkImage(urls[0])),
                const SizedBox(width: 2.0),
                Expanded(child: _networkImage(urls[1])),
              ],
            ),
          ),
          const SizedBox(height: 2.0),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _networkImage(urls[2])),
                const SizedBox(width: 2.0),
                Expanded(child: _networkImage(urls[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, _) => Container(color: const Color(0xFF2F3336)),
      errorWidget: (context, _, __) => Container(color: const Color(0xFF2F3336), child: const Icon(Icons.error)),
    );
  }
}

// ==========================================
// 6. ACTION ITEM COMPONENT (Footer)
// ==========================================

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionItem({
    Key? key,
    required this.icon,
    required this.count,
    required this.color,
    this.isActive = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 16.0, color: color),
            const SizedBox(width: 2.0),
            Text(
              count.toCompactCurrencyFormat(),
              style: TextStyle(
                color: color,
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}