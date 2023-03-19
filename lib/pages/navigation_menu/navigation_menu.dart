import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/actors_page/actors_page.dart';
import 'package:moviewebapp/pages/all_actors_page/all_actors_page.dart';
import 'package:moviewebapp/pages/all_movies_screen/all_movies_screen.dart';
import 'package:moviewebapp/pages/blogs_screen/blogs_screen.dart';
import 'package:moviewebapp/pages/dashboard/dashboard.dart';
import 'package:moviewebapp/pages/navigation_menu/custom_bottom_navbar.dart';
import 'package:moviewebapp/pages/navigation_menu/movie_app_bar.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({Key? key}) : super(key: key);

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  final _screens = [
    const Dashboard(),
    const MovieHomePage(
      withOriginalLanguage: "en",
      movieType: "popular",
      withGenres: "",
      screenTitle: "Popular Movies",
    ),
    const AllActorsPage(),
    const BlogsScreen(),
    const ActorsPage(
      actorId: "",
    )
  ];
  int _currentScreen = 0;
  final List<String> appBarTitles = ["Home", "Movies", "People"];
  final List<String> bottomBarTitles = [
    "Dashboard",
    "Movies",
    "Web Series",
    "Blogs",
    "Account"
  ];
  final List<String> iconAssetPaths = [
    homeIcon,
    videoIcon,
    tvIcon,
    blogIcon,
    userIcon
  ];

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: _screenWidth >= 750
          ? AppBar(
              backgroundColor: woodsSmoke,
              centerTitle: true,
              title: MovieAppBar(
                defaultSelectedIndex: 0,
                onChange: (val) {
                  setState(() {
                    if (val != 4) {
                      _currentScreen = val;
                    }
                  });
                },
                titles: appBarTitles,
              ),
              leading: IconButton(
                icon: Image.asset("assets/images/movie_icon.png"),
                iconSize: 22,
                onPressed: () {},
              ),
            )
          : null,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _screens[_currentScreen],
          if (_screenWidth <= 750)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: CustomBottomNavigationBar(
                  defaultSelectedIndex: 0,
                  onChange: (val) {
                    setState(() {
                      if (val != 4) {
                        _currentScreen = val;
                      }
                    });
                  },
                  titles: bottomBarTitles,
                  imgurls: iconAssetPaths,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
