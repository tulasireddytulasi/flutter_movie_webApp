import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviewebapp/app/core/routing/app_router.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:moviewebapp/app/views/all_actors_page/widgets/user_card.dart';
import 'package:moviewebapp/app/providers/navigation_provider.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:provider/provider.dart';

class ActorCard extends StatefulWidget {
  const ActorCard({
    Key? key,
    required this.castImage,
    required this.actorName,
    required this.actorId,
    required this.ratio,
    required this.genderId,
    required this.knownFor,
    required this.popularity,
  }) : super(key: key);

  final String actorId;
  final String castImage;
  final String actorName;
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
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return InkWell(
          onTap: () {
            context.push(
              '/people/${buildSeoSlug(widget.actorId, widget.actorName)}',
              extra: const {detailPresentationExtra: detailPresentationModal},
            );
          },
          hoverColor: Theme.of(
            context,
          ).colorScheme.surface.withValues(alpha: 0),
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
      },
    );
  }
}
