import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';
import 'package:moviewebapp/app/core/utils/constants/constants.dart';

class BlogViewScreen extends StatelessWidget {
  const BlogViewScreen({
    Key? key,
    required this.heading1,
    required this.blogSubHeading1,
    required this.heading2,
    required this.blogSubHeading2,
    required this.createdDate,
    required this.blogReadTime,
    required this.authorName,
    required this.poster1,
    required this.poster2,
    required this.mainContent,
    required this.heading3,
    required this.blogSubHeading3,
  }) : super(key: key);

  final String heading1;
  final String heading2;
  final String blogSubHeading1;
  final String blogSubHeading2;
  final String createdDate;
  final String blogReadTime;
  final String authorName;
  final String poster1;
  final String poster2;
  final String mainContent;
  final String heading3;
  final String blogSubHeading3;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Blog",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.all(10),
            child: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.only(top: 10, bottom: 10, right: 2),
              child: const Icon(
                Icons.heart_broken,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "1.2K",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.all(10),
              child: const Icon(
                Icons.share,
              ),
            ),
          ),
        ],
      ),
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
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Nov 21, 2023",
                        ),
                        TextSpan(
                          text: "  .  ",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const TextSpan(
                          text: "10 Mins read",
                        ),
                      ],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    BlogConstants.doctorStrange,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    BlogConstants.doctorStrangeSubTitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "BY MARVEL",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Image.asset(doctorStrange3BlogPoster),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    BlogConstants.doctorStrangeMainContent,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    BlogConstants.doctorStrangeTitle2,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    BlogConstants.doctorStrangePara1,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Image.asset(doctorStrange4BlogPoster),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text(
                      BlogConstants.doctorStrangeSubTitle2,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text(
                      BlogConstants.doctorStrangePara2,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
