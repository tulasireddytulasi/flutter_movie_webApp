import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviewebapp/app/views/all_actors_page/all_actors_page.dart';
import 'package:moviewebapp/app/views/all_movies_screen/movies_list_screen.dart';
import 'package:moviewebapp/app/views/blogs_screen/blogs_screen.dart';
import 'package:moviewebapp/app/views/dashboard/dashboard.dart';
import 'package:moviewebapp/app/views/navigation_menu/custom_bottom_navbar_2.dart';

import 'package:moviewebapp/app/views/navigation_menu/movie_app_bar.dart';
import 'package:moviewebapp/app/providers/dashboard_provider.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';

// import 'package:moviewebapp/app/views/twitter_ui/twitter_screen.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({Key? key, this.navigationShell}) : super(key: key);
  final StatefulNavigationShell? navigationShell;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late ValueNotifier<int> _currentScreenNo;
  final List<String> appBarTitles = ["Home", "Movies", "People", "Blogs"];
  final List<String> bottomBarTitles = [
    "Dashboard",
    "Movies",
    "People",
    "Blogs",
    "Search",
  ];
  final List<String> iconAssetPaths = [
    homeIcon,
    videoIcon,
    tvIcon,
    blogIcon,
    userIcon,
  ];
  final List<IconData?> navigationIcons = [
    null,
    null,
    null,
    null,
    Icons.search,
  ];

  @override
  void initState() {
    super.initState();
    _currentScreenNo = ValueNotifier<int>(0);
  }

  Future<bool> _canChangeScreen(int index) async => true;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Consumer<DashBoardProvider>(
      builder: (context, dashBoardProvider, child) {
        return Scaffold(
          appBar: screenWidth >= 750
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(60.0),
                  child: MovieAppBar(
                    defaultSelectedIndex: 0,
                    canChange: _canChangeScreen,
                    backGroundColor:
                        Theme.of(context).appBarTheme.backgroundColor ??
                        Theme.of(context).colorScheme.surface,
                    onChange: (value) =>
                        widget.navigationShell?.goBranch(value),
                    onSearch: () => context.go('/search'),
                    titles: appBarTitles,
                  ),
                )
              : null,
          // extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: _currentScreenNo,
                builder: (context, hasConsent, child) {
                  return widget.navigationShell ??
                      IndexedStack(
                        index: _currentScreenNo.value,
                        children: const [
                          Dashboard(),
                          MovieListScreen(
                            withOriginalLanguage: "en",
                            movieType: "popular",
                            withGenres: "",
                            screenTitle: "Popular Movies",
                            showAppBar: false,
                            showLeadingIcon: false,
                          ),
                          AllActorsPage(
                            showAppBar: false,
                            showLeadingIcon: false,
                          ),
                          BlogsScreen(showAppBar: false),
                        ],
                      );
                },
              ),
            ],
          ),
          bottomNavigationBar: (screenWidth <= 750)
              ? CustomBottomNavigationBar(
                  defaultSelectedIndex: 0,
                  canChange: _canChangeScreen,
                  onChange: (value) {
                    if (widget.navigationShell != null) {
                      widget.navigationShell!.goBranch(value);
                    } else {
                      _currentScreenNo.value = value;
                    }
                  },
                  titles: bottomBarTitles,
                  imgUrls: iconAssetPaths,
                  icons: navigationIcons,
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
