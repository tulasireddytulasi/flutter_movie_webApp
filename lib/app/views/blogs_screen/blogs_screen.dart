import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/blogs_screen/blogs_view_screen.dart';
import 'package:moviewebapp/app/views/blogs_screen/dummy_data.dart';
import 'package:moviewebapp/app/views/blogs_screen/widgets/blod_card.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:moviewebapp/app/core/utils/styles.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({Key? key, required this.showAppBar}) : super(key: key);
  final bool showAppBar;

  @override
  _BlogsScreenState createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: tealishBlue,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: tealishBlue,
              title: const Text(
                "Marvel Blogs",
                style: semiBoldGrey30,
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.all(10),
              alignment: Alignment.center,
              width: _screenWidth >= 750 ? 800 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: DummyData.blogsData.map((blogInfo) {
                      return InkWell(
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
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
                          });
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
        ),
      ),
    );
  }
}
