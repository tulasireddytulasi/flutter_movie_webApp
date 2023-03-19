import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/blogs_screen/widgets/blod_card.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';
import 'package:moviewebapp/utils/constants/constants.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({Key? key}) : super(key: key);

  @override
  _BlogsScreenState createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  final List<Map<String, dynamic>> blogsData = [
    {
      "blogTitle": BlogConstants.wakandaTitle,
      "blogCreateDate": "21/02/23",
      "blogReadTime": "10 Mins read",
      "blogPoster": wakandaForeveBlogPoster
    },
    {
      "blogTitle": BlogConstants.legends,
      "blogCreateDate": "14/01/23",
      "blogReadTime": "15 Mins read",
      "blogPoster": legends2BlogPoster
    },
    {
      "blogTitle": BlogConstants.antManTitle3,
      "blogCreateDate": "14/01/23",
      "blogReadTime": "17 Mins read",
      "blogPoster": scottlangBlogPoster
    },
    {
      "blogTitle": BlogConstants.doctorStrange,
      "blogCreateDate": "14/01/23",
      "blogReadTime": "26 Mins read",
      "blogPoster": doctorStrange1BlogPoster
    },
    {
      "blogTitle": BlogConstants.doctorStrange2,
      "blogCreateDate": "14/01/23",
      "blogReadTime": "26 Mins read",
      "blogPoster": doctorStrange2BlogPoster
    },
    {
      "blogTitle": BlogConstants.antManTitle,
      "blogCreateDate": "14/01/23",
      "blogReadTime": "12 Mins read",
      "blogPoster": amtwqmBlogPoster
    }
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tealishBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, left: 18),
                child: const Text(
                  "Marvel Blogs",
                  style: TextStyle(
                    fontSize: 30,
                    color: GREY,
                    fontFamily: montserratSemiBold,
                  ),
                ),
              ),
              Column(
                children: blogsData.map((blogInfo) {
                  return BlogCard(
                      blogTitle: blogInfo["blogTitle"],
                      blogPoster: blogInfo["blogPoster"],
                      blogCreateDate: blogInfo["blogCreateDate"],
                      blogReadTime: blogInfo["blogReadTime"]);
                }).toList(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
