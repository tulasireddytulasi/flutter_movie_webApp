import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/repository/json_objects/x_post_json.dart';
import 'package:moviewebapp/app/models/post_model.dart';
import 'widgets/post_card_widget.dart';

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

