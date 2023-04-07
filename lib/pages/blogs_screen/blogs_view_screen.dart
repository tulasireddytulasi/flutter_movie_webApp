import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/constants.dart';
import 'package:moviewebapp/utils/constants/constants.dart';

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
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: tealishBlue,
      appBar: AppBar(
        backgroundColor: tealishBlue,
        title: const Text(
          "Blog",
          style: TextStyle(fontSize: 22, color: WHITE),
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
              color: WHITE,
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
                color: WHITE,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "1.2K",
              style: TextStyle(fontSize: 12, color: WHITE.withOpacity(0.6)),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.all(10),
              child: const Icon(
                Icons.share,
                color: WHITE,
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
              width: _screenWidth >= 750 ? 800 : double.infinity,
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
                          style: TextStyle(
                              fontSize: 33,
                              color: GREY.withOpacity(0.5),
                              fontFamily: montserratSemiBold),
                        ),
                        const TextSpan(
                          text: "10 Mins read",
                        ),
                      ],
                      style: TextStyle(
                          fontSize: 13,
                          color: GREY.withOpacity(0.5),
                          fontFamily: montserratSemiBold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    BlogConstants.doctorStrange,
                    style: TextStyle(
                        fontSize: 20,
                        color: WHITE.withOpacity(0.8),
                        fontFamily: montserratMedium),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    BlogConstants.doctorStrangeSubTitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: GREY,
                      fontFamily: montserratMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "BY MARVEL",
                    style: TextStyle(
                        fontSize: 14,
                        color: WHITE,
                        fontFamily: montserratMedium),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Image.asset(doctorStrange3BlogPoster),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    BlogConstants.doctorStrangeMainContent,
                    style: TextStyle(
                        fontSize: 14,
                        color: GREY,
                        fontFamily: montserratMedium),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    BlogConstants.doctorStrangeTitle2,
                    style: TextStyle(
                        fontSize: 20,
                        color: WHITE.withOpacity(0.8),
                        fontFamily: montserratMedium),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    BlogConstants.doctorStrangePara1,
                    style: TextStyle(
                      fontSize: 14,
                      color: GREY,
                      fontFamily: montserratMedium,
                    ),
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
                      style: TextStyle(
                          fontSize: 18,
                          color: WHITE.withOpacity(0.8),
                          fontFamily: montserratMedium),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: const Text(
                      BlogConstants.doctorStrangePara2,
                      style: TextStyle(
                          fontSize: 14,
                          color: GREY,
                          fontFamily: montserratMedium),
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
