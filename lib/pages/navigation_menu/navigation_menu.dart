import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/all_actors_page/all_actors_page.dart';
import 'package:moviewebapp/pages/all_movies_screen/movies_list.dart';
import 'package:moviewebapp/pages/blogs_screen/blogs_screen.dart';
import 'package:moviewebapp/pages/dashboard/dashboard.dart';
import 'package:moviewebapp/pages/navigation_menu/custom_bottom_navbar.dart';
import 'package:moviewebapp/pages/navigation_menu/movie_app_bar.dart';
import 'package:moviewebapp/pages/profile_screen/profile_screen.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({Key? key}) : super(key: key);

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late ValueNotifier<int> _currentScreenNo;
  final _screens = [
    const Dashboard(),
    const MovieListScreen(
      withOriginalLanguage: "en",
      movieType: "popular",
      withGenres: "",
      screenTitle: "Popular Movies",
    ),
    const AllActorsPage(),
    const BlogsScreen(),
    const ProfileScreen(),
  ];
  final List<String> appBarTitles = ["Home", "Movies", "People", "Blogs"];
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
  void initState() {
    super.initState();
    _currentScreenNo = ValueNotifier<int>(0);
  }

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
                onChange: (value) => _currentScreenNo.value = value,
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
          ValueListenableBuilder<int>(
              valueListenable: _currentScreenNo,
              builder: (context, hasConsent, child) {
                return IndexedStack(
                  index: _currentScreenNo.value,
                  children: _screens,
                );
              }),
          if (_screenWidth <= 750)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: CustomBottomNavigationBar(
                  defaultSelectedIndex: 0,
                  onChange: (value) => _currentScreenNo.value = value,
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
