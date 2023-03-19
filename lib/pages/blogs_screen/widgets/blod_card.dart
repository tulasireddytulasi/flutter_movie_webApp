import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

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
      decoration: BoxDecoration(color: BLACK.withOpacity(0.2)),
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
            style: const TextStyle(
                fontSize: 14, color: GREY, fontFamily: montserratMedium),
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
                      style: TextStyle(
                          fontSize: 33,
                          color: GREY.withOpacity(0.5),
                          fontFamily: montserratSemiBold),
                    ),
                    TextSpan(
                      text: blogReadTime,
                    ),
                  ],
                  style: TextStyle(
                      fontSize: 13,
                      color: GREY.withOpacity(0.5),
                      fontFamily: montserratSemiBold),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    "...",
                    style: TextStyle(
                        fontSize: 34,
                        color: GREY.withOpacity(0.5),
                        fontFamily: montserratSemiBold),
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
