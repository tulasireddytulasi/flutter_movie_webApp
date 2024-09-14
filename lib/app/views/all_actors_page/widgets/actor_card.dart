import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:moviewebapp/app/views/actors_page/actors_page.dart';
import 'package:moviewebapp/app/views/all_actors_page/widgets/user_card.dart';
import 'package:moviewebapp/app/views/bottom_sheet/bottom_sheet_widget.dart';
import 'package:moviewebapp/app/providers/navigation_provider.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:provider/provider.dart';

class ActorCard extends StatefulWidget {
  const ActorCard({
    Key? key,
    required this.castImage,
    required this.actorName,
    required this.actorId,
    this.textColor = GREY,
    this.textSize = 14,
    required this.ratio,
    required this.genderId,
    required this.knownFor,
    required this.popularity,
  }) : super(key: key);

  final String actorId;
  final String castImage;
  final String actorName;
  final Color textColor;
  final double textSize;
  final double ratio;
  final int genderId;
  final String knownFor;
  final String popularity;

  @override
  State<ActorCard> createState() => _ActorCardState();
}

class _ActorCardState extends State<ActorCard> {
  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    return Consumer<NavigationProvider>(builder: (context, navigationProvider, child) {
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
                constraints: const BoxConstraints(
                  minWidth: 900,
                  minHeight: 300,
                ),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                isDismissible: true,
                enableDrag: false,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(50))),
                builder: (context) {
                  return Container(
                    constraints: const BoxConstraints(
                      minWidth: 600,
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
            navigationProvider.setOnHover();
          }
        },
        child: UserCard(
          picUrl: ApiConstants.movieImageBaseUrlw500 + widget.castImage,
          name: widget.actorName,
          gender: getGender(genderId: widget.genderId),
          knownFor: widget.knownFor,
          popularity: widget.popularity,
        ),
      );
    });
  }
}
