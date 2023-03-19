import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/blogs_screen/blogs_view_screen.dart';
import 'package:moviewebapp/pages/blogs_screen/dummy_data.dart';
import 'package:moviewebapp/pages/blogs_screen/widgets/blod_card.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({Key? key}) : super(key: key);

  @override
  _BlogsScreenState createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tealishBlue,
      appBar: AppBar(
        backgroundColor: tealishBlue,
        title: const Text(
          "Marvel Blogs",
          style: TextStyle(
            fontSize: 30,
            color: GREY,
            fontFamily: montserratSemiBold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: DummyData.blogsData.map((blogInfo) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogViewScreen(
                            createdDate: blogInfo["blogCreateDate"],
                            blogReadTime: blogInfo["blogReadTime"],
                            authorName: "MARVEL",
                            poster1: "",
                            poster2: "",
                            heading1: "",
                            blogSubHeading1: "",
                            heading2: "",
                            blogSubHeading2: "",
                            heading3: "",
                            blogSubHeading3: "",
                            mainContent: "",
                          ),
                        ),
                      );
                    },
                    child: BlogCard(
                        blogTitle: blogInfo["blogTitle"],
                        blogPoster: blogInfo["blogPoster"],
                        blogCreateDate: blogInfo["blogCreateDate"],
                        blogReadTime: blogInfo["blogReadTime"]),
                  );
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
