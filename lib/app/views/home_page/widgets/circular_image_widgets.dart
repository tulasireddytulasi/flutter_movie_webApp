import 'package:flutter/material.dart';
import 'package:moviewebapp/app/views/actors_page/actors_page.dart';
import 'package:moviewebapp/app/views/bottom_sheet/bottom_sheet_widget.dart';
import 'package:moviewebapp/app/providers/navigation_provider.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';
import 'package:provider/provider.dart';

class ActorCircularCard extends StatefulWidget {
  const ActorCircularCard({
    Key? key,
    required this.castImage,
    required this.actorName,
    required this.actorId,
    required this.ratio,
  }) : super(key: key);

  final String actorId;
  final String castImage;
  final String actorName;
  final double ratio;

  @override
  State<ActorCircularCard> createState() => _ActorCircularCardState();
}

class _ActorCircularCardState extends State<ActorCircularCard> {
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
                    constraints: const BoxConstraints(
                      minWidth: 900,
                      minHeight: 300,
                    ),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0),
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
                          minWidth: 600,
                          minHeight: 300,
                        ),
                        child: const BottomSheetWidget(),
                      );
                    });
              }
            },
            hoverColor:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0),
            onHover: (val) {
              if (val) {
                navigationProvider.setOnHover(actorID: widget.actorId);
              } else {
                navigationProvider.setOnHover();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.actorId == navigationProvider.actorID
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0),
                  width: 5,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(100)),
              ),
              child: widget.castImage.isNotEmpty
                  ? CircleAvatar(
                      radius: widget.ratio,
                      backgroundImage: NetworkImage(
                          ApiConstants.movieImageBaseUrlw500 +
                              widget.castImage),
                    )
                  : CircleAvatar(
                      radius: widget.ratio,
                      backgroundImage: const AssetImage(noProfilePic),
                    ),
            ),
          );
        }),
        Visibility(
          visible: true,
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 0, top: 10),
            width: 100,
            child: Text(
              widget.actorName,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
