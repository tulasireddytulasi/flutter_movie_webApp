import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moviewebapp/app/core/repository/json_objects/x_post_json.dart';
import 'package:moviewebapp/app/models/post_model.dart';
import 'widgets/footer_widget.dart';
import 'widgets/network_image_with_dynamic_ratio.dart';

// Assuming jsonString is your raw JSON string data:
final List<PostModel> mockPosts = XPostJson.marvelMovies.map((item) => PostModel.fromJson(item)).toList();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
                  ],
                ),
              ),
            ],
          ),
          // Dynamic Media List (if images exist)
          if (widget.post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 6.0),
            widget.post.imageUrls.length == 1
                ? Padding(
                    padding: const EdgeInsets.only(left: 52.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 380.0),
                      child: NetworkImageWithDynamicRatio(imageUrl: widget.post.imageUrls[0]),
                    ),
                  )
                : SizedBox(
                    height: 280.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      //clipBehavior: Clip.none,
                      itemCount: widget.post.imageUrls.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 4.0),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(left: index == 0 ? 52.0 : 0.0),
                          child: NetworkImageWithDynamicRatio(imageUrl: widget.post.imageUrls[index]),
                        );
                      },
                    ),
                  ),
          ],

          const SizedBox(height: 0.0),

          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: FooterWidget(post: widget.post),
          ),
        ],
      ),
    );
  }
}
