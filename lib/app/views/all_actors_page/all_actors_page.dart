import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:moviewebapp/app/models/popular_actors_model.dart';
import 'package:moviewebapp/app/core/utils/screen_sizes.dart';
import 'package:moviewebapp/app/views/all_actors_page/widgets/actor_card.dart';
import 'package:moviewebapp/app/views/home_page/widgets/circular_image_widgets.dart';
import 'package:moviewebapp/app/providers/people_provider.dart';
import 'package:provider/provider.dart';

class AllActorsPage extends StatefulWidget {
  const AllActorsPage({super.key});

  @override
  State<AllActorsPage> createState() => _AllActorsPageState();
}

class _AllActorsPageState extends State<AllActorsPage> {
  final PagingController<int, Actors> _pagingController = PagingController(firstPageKey: 1);
  final Map<int, String> _cursorByPage = {};
  late final PeopleProvider _peopleProvider;
  int columns = 6;
  Map<String, dynamic> layoutData = {};
  double ratio = 60;

  @override
  void initState() {
    super.initState();
    _peopleProvider = context.read<PeopleProvider>();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPopularActors(pageKey: pageKey);
    });
  }

  Future<void> _fetchPopularActors({required int pageKey}) async {
    try {
      final page = await _peopleProvider.fetchPopularPeoplePage(cursorAfter: _cursorByPage[pageKey]);
      if (!mounted) return;

      final nextCursor = page.nextCursor;
      if (nextCursor == null) {
        _pagingController.appendLastPage(page.actors);
      } else {
        _cursorByPage[pageKey + 1] = nextCursor;
        _pagingController.appendPage(page.actors, pageKey + 1);
      }
    } catch (error, stackTrace) {
      log("fetchPopularActors error: $error");
      log("fetchPopularActors stackTrace: $stackTrace");
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktopOrTablet = screenWidth >= 600;
    layoutData = getActorCircularWidgetWidth(screenWidth: screenWidth);
    columns = layoutData["columns"].toInt();
    ratio = layoutData["ratio"];

    return Scaffold(
      appBar: !isDesktopOrTablet
          ? AppBar(title: Text("Popular Actors", style: Theme.of(context).appBarTheme.titleTextStyle))
          : null,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            width: 1200,
            alignment: Alignment.topCenter,
            child: isDesktopOrTablet
                ? PagedGridView<int, Actors>(
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
                      itemBuilder: (context, actorsInfo, index) => ActorCircularCard(
                        ratio: ratio,
                        actorName: actorsInfo.name ?? "",
                        actorId: actorsInfo.id.toString(),
                        castImage: actorsInfo.profilePath ?? "",
                      ),
                    ),
                  )
                : PagedListView<int, Actors>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<Actors>(
                      itemBuilder: (context, actorsInfo, index) => ActorCard(
                        ratio: ratio,
                        actorName: actorsInfo.name ?? "",
                        actorId: actorsInfo.id.toString(),
                        castImage: actorsInfo.profilePath ?? "",
                        genderId: actorsInfo.gender ?? 1,
                        knownFor: actorsInfo.knownForDepartment ?? "",
                        popularity: actorsInfo.popularity.toString(),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
