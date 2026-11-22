import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviewebapp/app/core/routing/app_router.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';

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
    return Column(
      children: [
        InkWell(
          onTap: () {
            context.push(
              '/person/${buildSeoSlug(widget.actorId, widget.actorName)}',
            );
          },
          hoverColor: Theme.of(
            context,
          ).colorScheme.surface.withValues(alpha: 0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0),
                width: 5,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(100)),
            ),
            child: widget.castImage.isNotEmpty
                ? CircleAvatar(
                    radius: widget.ratio,
                    backgroundImage: NetworkImage(
                      ApiConstants.movieImageBaseUrlw500 + widget.castImage,
                    ),
                  )
                : CircleAvatar(
                    radius: widget.ratio,
                    backgroundImage: const AssetImage(noProfilePic),
                  ),
          ),
        ),
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
