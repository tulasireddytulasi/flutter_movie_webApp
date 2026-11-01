import 'package:flutter/material.dart';
import 'package:moviewebapp/app/providers/universal_provider.dart';
import 'package:moviewebapp/app/views/actors_page/widgets/ActorMoviesWidget.dart';
import 'package:moviewebapp/app/views/actors_page/widgets/actors_Images_widget.dart';
import 'package:moviewebapp/app/views/actors_page/widgets/lable_widget.dart';
import 'package:moviewebapp/app/views/movie_info_screen/widgets/expandable_text_widget.dart';
import 'package:moviewebapp/app/providers/actors_info_provider.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:provider/provider.dart';

class ActorsPage extends StatefulWidget {
  final String actorId;

  const ActorsPage({Key? key, required this.actorId}) : super(key: key);

  @override
  State<ActorsPage> createState() => _ActorsPageState();
}

class _ActorsPageState extends State<ActorsPage> {
  final ScrollController scrollController = ScrollController();
  late ActorsInfoProvider actorsInfoProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      actorsInfoProvider = Provider.of<ActorsInfoProvider>(context, listen: false);
      actorsInfoProvider.getActorsInfoAPI(actorId: widget.actorId);
      actorsInfoProvider.getActorsImagesAPI(actorId: widget.actorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    final bool _webView = _screenWidth >= 600;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      appBar: _webView
          ? null
          : AppBar(
              elevation: 1,
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
                  onTap: () async {
                    if (actorsInfoProvider.profilePic.isEmpty && actorsInfoProvider.actorName.isEmpty) return;
                    final String name = "Actor Name: ${actorsInfoProvider.actorName}";

                    final UniversalProvider universalProvider = Provider.of<UniversalProvider>(context, listen: false);

                    await universalProvider.shareImage(
                      baseUrl: ApiConstants.movieImageBaseUrlw500,
                      imgUrl: actorsInfoProvider.profilePic,
                      descText: name,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.share,
                    ),
                  ),
                ),
              ],
              title: Text(
                "Actors Screen",
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
      body: SafeArea(
        child: Consumer<ActorsInfoProvider>(builder: (context, actorsInfoProvider, child) {
          final double _pageWidth = getBottomSheetWidth(screenWidth: _screenWidth) + 30;
          return SingleChildScrollView(
            controller: scrollController,
            child: Center(
              child: Container(
                // alignment: Alignment.bottomCenter,
                width: _pageWidth,
                margin: EdgeInsets.only(
                  top: _screenWidth >= 600 ? 50 : 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(_webView ? 20 : 0),
                    topLeft: Radius.circular(_webView ? 20 : 0),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  //  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Visibility(
                      visible: _webView ? true : false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
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
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.all(10),
                              child: const Icon(
                                Icons.clear,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: actorsInfoProvider.profilePic != ""
                                ? Image.network(
                                    ApiConstants.movieImageBaseUrlw500 + actorsInfoProvider.profilePic,
                                    height: getProfileImageSize(screenSize: _screenWidth),
                                    width: getProfileImageSize(screenSize: _screenWidth),
                                    fit: BoxFit.cover,
                                  )
                                : Container(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: _pageWidth / 2,
                              margin: const EdgeInsets.only(left: 0, top: 20),
                              child: Text(
                                actorsInfoProvider.actorName,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 0, right: 5, top: 10, bottom: 0),
                                  child: Icon(
                                    Icons.map,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 0, top: 10),
                                  child: RichText(
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: actorsInfoProvider.totalMoviesActed.toString(),
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      TextSpan(
                                        text: " movies",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 55,
                              margin: const EdgeInsets.only(left: 0, top: 10),
                              child: Text(
                                actorsInfoProvider.role,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor,
                      thickness: 1,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 20, right: 5),
                            child: Icon(
                              Icons.map,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(
                            width: _pageWidth / 1.3,
                            child: RichText(
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: actorsInfoProvider.dob,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextSpan(
                                    text: " in ${actorsInfoProvider.birthPlace}",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: _pageWidth / 1,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      padding: const EdgeInsets.only(left: 20, top: 20, right: 10, bottom: 15),
                      child: ExpandableText(
                        text: actorsInfoProvider.biography,
                        maxLines: 3,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const LabelWidget(label: "Actor Pics"),
                    Container(
                      height:
                          _screenWidth >= 900 ? 250 : 130, //getSimilarMoviesSectionHeight(screenSize: _screenWidth),
                      margin: const EdgeInsets.only(top: 0, left: 10),
                      child: ActorsImages(),
                    ),
                    const LabelWidget(label: "Known For"),
                    Container(
                      height: getSimilarMoviesSectionHeight(screenSize: _screenWidth),
                      margin: const EdgeInsets.only(top: 0, left: 10),
                      child: ActorMoviesWidget(actorId: widget.actorId),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
