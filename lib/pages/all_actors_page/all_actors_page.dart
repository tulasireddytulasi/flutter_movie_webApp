import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/home_page/widgets/circular_image_widgets.dart';
import 'package:moviewebapp/providers/actors_info_provider.dart';
import 'package:moviewebapp/providers/navigation_provider.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/screen_sizes.dart';
import 'package:provider/provider.dart';

class AllActorsPage extends StatefulWidget {
  const AllActorsPage({Key? key}) : super(key: key);

  @override
  _AllActorsPageState createState() => _AllActorsPageState();
}

class _AllActorsPageState extends State<AllActorsPage> {
  double cardHeight = 0;
  double _childAspectRatio = 9 / 16;
  double leftPadding = 0;
  double rightPadding = 0;
  double crossAxisSpacing = 10;
  double maxBottomSheetWidth = 0;
  int columns = 5;
  List<double> screenValues = [];
  Map<String, dynamic> layoutData = {};
  bool isMovieTitleVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final actorsInfoProvider =
          Provider.of<ActorsInfoProvider>(context, listen: false);
      actorsInfoProvider.getPopularActorsInfoAPI(
          languageCode: "en-US", pageNo: 1);
      actorsInfoProvider.getPopularActorsInfoAPI(
          languageCode: "en-US", pageNo: 2);
      actorsInfoProvider.getPopularActorsInfoAPI(
          languageCode: "en-US", pageNo: 3);
      actorsInfoProvider.getPopularActorsInfoAPI(
          languageCode: "en-US", pageNo: 4);
      actorsInfoProvider.getPopularActorsInfoAPI(
          languageCode: "en-US", pageNo: 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    layoutData = getActorCircularWidgetWidth(screenWidth: screenWidth);
    cardHeight = layoutData["cardHeight"];
    columns = layoutData["columns"].toInt();
    _childAspectRatio = layoutData["childAspectRatio"];
    isMovieTitleVisible = layoutData["isMovieTitleVisible"];
    leftPadding = layoutData["leftPadding"];
    rightPadding = layoutData["rightPadding"];
    // crossAxisSpacing = layoutData["crossAxisSpacing"];
    maxBottomSheetWidth = layoutData["maxBottomSheetWidth"];

    return Scaffold(
      backgroundColor: tealishBlue,
      body: SafeArea(
        child: Consumer<ActorsInfoProvider>(
            builder: (context, actorsInfoProvider, child) {
          return Container(
            // decoration: BoxDecoration(border: Border.all(color: RED, width: 1)),
            margin: const EdgeInsets.only(top: 0),
            padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              physics: const ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: _childAspectRatio,
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                crossAxisSpacing: crossAxisSpacing,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Consumer<NavigationProvider>(
                    builder: (context, navigationProvider, child) {
                  return Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(color: borderColor, width: 1),
                    // ),
                    // child: ActorsImages(
                    //     imageUrl: actorsInfoProvider.allActorsImages[index]),
                    child: ActorCard(
                      textColor: WHITE,
                      textSize: 11,
                      actorName: actorsInfoProvider.actorNameList[index],
                      actorId: actorsInfoProvider.actorIdList[index],
                      castImage: actorsInfoProvider.allActorsImages[index],
                    ),
                  );
                });
              },
              itemCount: actorsInfoProvider.allActorsImages.length,
            ),
          );
        }),
      ),
    );
  }
}
