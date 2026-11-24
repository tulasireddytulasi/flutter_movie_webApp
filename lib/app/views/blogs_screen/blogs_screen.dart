import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviewebapp/app/core/routing/app_router.dart';
import 'package:moviewebapp/app/views/blogs_screen/dummy_data.dart';
import 'package:moviewebapp/app/views/blogs_screen/widgets/blod_card.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktopOrTablet = screenWidth >= 600;
    return Scaffold(
      appBar: !isDesktopOrTablet
          ? AppBar(title: Text("Marvel Blogs", style: Theme.of(context).appBarTheme.titleTextStyle))
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.all(10),
              alignment: Alignment.center,
              width: screenWidth >= 750 ? 800 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      for (var index = 0; index < DummyData.blogsData.length; index++)
                        Builder(
                          builder: (context) {
                            final blogInfo = DummyData.blogsData[index];
                            return InkWell(
                              onTap: () {
                                context.push(
                                  '/blog/${buildSeoSlug('${index + 1}', blogInfo["blogTitle"])}',
                                  extra: const {detailPresentationExtra: detailPresentationModal},
                                );
                              },
                              child: BlogCard(
                                blogTitle: blogInfo["blogTitle"],
                                blogPoster: blogInfo["blogPoster"],
                                blogCreateDate: blogInfo["blogCreateDate"],
                                blogReadTime: blogInfo["blogReadTime"],
                              ),
                            );
                          },
                        ),
                    ],
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
