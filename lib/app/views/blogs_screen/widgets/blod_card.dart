import 'package:flutter/material.dart';

class BlogCard extends StatelessWidget {
  const BlogCard({
    Key? key,
    required this.blogTitle,
    required this.blogCreateDate,
    required this.blogReadTime,
    required this.blogPoster,
  }) : super(key: key);

  final String blogTitle;
  final String blogCreateDate;
  final String blogReadTime;
  final String blogPoster;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            child: Image.asset(blogPoster),
          ),
          const SizedBox(height: 10),
          Text(
            blogTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: blogCreateDate,
                    ),
                    TextSpan(
                      text: " . ",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextSpan(
                      text: blogReadTime,
                    ),
                  ],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    "...",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
