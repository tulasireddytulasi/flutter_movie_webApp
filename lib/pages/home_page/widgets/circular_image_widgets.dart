import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/actors_page/actors_page.dart';
import 'package:moviewebapp/pages/bottom_sheet/bottom_sheet_widget.dart';
import 'package:moviewebapp/providers/actors_info_provider.dart';
import 'package:moviewebapp/providers/navigation_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:provider/provider.dart';

class CircularWidget extends StatefulWidget {
  const CircularWidget({Key? key}) : super(key: key);

  @override
  _CircularWidgetState createState() => _CircularWidgetState();
}

class _CircularWidgetState extends State<CircularWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final actorsInfoProvider =
          Provider.of<ActorsInfoProvider>(context, listen: false);
      actorsInfoProvider.getPopularActorsInfoAPI(
          languageCode: "en-US", pageNo: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActorsInfoProvider>(
        builder: (context, actorsInfoProvider, child) {
      return ListView.builder(
          itemCount: 5, //actorsInfoProvider.actorsImages.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return actorsInfoProvider.allActorsImages.isNotEmpty
                ? ActorCard(
                    actorName:
                        actorsInfoProvider.actorNameList[index].toString(),
                    castImage:
                        actorsInfoProvider.allActorsImages[index].toString(),
                    actorId: actorsInfoProvider.actorIdList[index],
                  )
                : Container();
          });
    });
  }
}

class ActorCard extends StatefulWidget {
  const ActorCard({
    Key? key,
    required this.castImage,
    required this.actorName,
    required this.actorId,
    this.textColor = GREY,
    this.textSize = 14,
  }) : super(key: key);

  final String actorId;
  final String castImage;
  final String actorName;
  final Color textColor;
  final double textSize;

  @override
  State<ActorCard> createState() => _ActorCardState();
}

class _ActorCardState extends State<ActorCard> {
  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Consumer<NavigationProvider>(
            builder: (context, navigationProvider, child) {
          return InkWell(
            onTap: () {
              if (_screenWidth <= 786) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActorsPage(actorId: widget.actorId),
                  ),
                );
              } else {
                navigationProvider.setActorsPage(actorId: widget.actorId);
                navigationProvider.setCurrentScreenIndex(currentScreenIndex: 1);
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    isDismissible: true,
                    enableDrag: false,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(50))),
                    builder: (context) {
                      return Container(
                        constraints: const BoxConstraints(
                          maxWidth: 600,
                          minHeight: 300,
                        ),
                        child: const BottomSheetWidget(),
                      );
                    });
              }
            },
            hoverColor: Colors.transparent,
            onHover: (val) {
              if (val) {
                navigationProvider.setOnHover(actorID: widget.actorId);
              } else {
                navigationProvider.setOutHover();
              }
            },
            child: Container(
              // padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.actorId == navigationProvider.actorID
                      ? navigationProvider.borderColor
                      : Colors.transparent,
                  width: 5,
                ),
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    getActorImageRadius(screenSize: _screenWidth)),
                child: Image.network(
                  ApiConstants.movieImageBaseUrlw500 + widget.castImage,
                  height: getActorImageSize(screenSize: _screenWidth),
                  width: getActorImageSize(screenSize: _screenWidth),
                  fit: BoxFit.cover,
                  color: widget.actorId == navigationProvider.actorID
                      ? navigationProvider.color
                      : null,
                  colorBlendMode: widget.actorId == navigationProvider.actorID
                      ? navigationProvider.blendMode
                      : null,
                ),
              ),
            ),
          );
        }),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 0, top: 10),
          width: 100,
          // decoration: BoxDecoration(
          //   border: Border.all(color: BLACK, width: 1),
          // ),
          child: Text(
            widget.actorName,
            style:
                TextStyle(fontSize: widget.textSize, color: widget.textColor),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
