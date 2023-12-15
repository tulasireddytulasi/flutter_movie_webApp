import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:moviewebapp/app/models/popular_actors_model.dart';
import 'package:moviewebapp/app/views/home_page/widgets/circular_image_widgets.dart';

import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';
import 'package:moviewebapp/app/core/utils/screen_sizes.dart';
import 'package:moviewebapp/app/core/utils/styles.dart';

class AllActorsPage extends StatefulWidget {
  const AllActorsPage({Key? key, required this.showAppBar, required this.showLeadingIcon}) : super(key: key);
  final bool showAppBar;
  final bool showLeadingIcon;
  @override
  _AllActorsPageState createState() => _AllActorsPageState();
}

class _AllActorsPageState extends State<AllActorsPage> {
  final PagingController<int, Actors> _pagingController = PagingController(firstPageKey: 1);
  int columns = 6;
  Map<String, dynamic> layoutData = {};
  double ratio = 60;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPopularActors(pageKey: pageKey);
    });
  }

  _fetchPopularActors({required int pageKey}) async {
    try {
      final List<Actors> actorsList = await fetchPopularActors(
        pageNo: pageKey,
        languageCode: "en-US",
      );
      _pagingController.appendPage(actorsList, pageKey + 1);
    } catch (error, stackTrace) {
      log("error: $error");
      log("stackTrace: $stackTrace");
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    final bool _screenWidth600 = _screenWidth >= 600;
    layoutData = getActorCircularWidgetWidth(screenWidth: _screenWidth);
    columns = layoutData["columns"].toInt();
    ratio = layoutData["ratio"];

    return Scaffold(
      backgroundColor: tealishBlue,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: tealishBlue,
              leading: widget.showLeadingIcon
                  ? IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.arrow_back,
                        color: WHITE,
                      ),
                    )
                  : null,
              title: const Text(
                "Popular Actors",
                style: semiBoldGrey30,
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            width: 1200,
            alignment: Alignment.topCenter,
            child: PagedGridView<int, Actors>(
              showNewPageProgressIndicatorAsGridChild: false,
              showNewPageErrorIndicatorAsGridChild: false,
              showNoMoreItemsIndicatorAsGridChild: false,
              pagingController: _pagingController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 100 / 110,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: columns,
              ),
              builderDelegate: PagedChildBuilderDelegate<Actors>(
                itemBuilder: (context, actorsInfo, index) => ActorCard(
                  textColor: WHITE,
                  textSize: 11,
                  ratio: ratio,
                  actorName: actorsInfo.name ?? "",
                  actorId: actorsInfo.id.toString(),
                  castImage: actorsInfo.profilePath ?? "",
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
