import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/actors_page/actors_page.dart';
import 'package:moviewebapp/pages/all_actors_page/all_actors_page.dart';
import 'package:moviewebapp/pages/all_movies_screen/all_movies_screen.dart';
import 'package:moviewebapp/pages/dashboard/dashboard.dart';
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
      withOriginalLanguage: "",
      movieType: "",
      withGenres: "",
    ),
    const AllActorsPage(),
    const ActorsPage(
      actorId: "",
    )
  ];
  int _currentScreen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: woodsSmoke,
        centerTitle: true,
        title: MovieAppBar(
          defaultSelectedIndex: 0,
          onChange: (val) {
            setState(() {
              _currentScreen = val;
            });
          },
          titles: const [
            "Home",
            "Movies",
            "People",
            // "New & Popular",
            // "My List"
          ],
        ),
        leading: IconButton(
          icon: Image.asset("assets/images/movie_icon.png"),
          iconSize: 22,
          onPressed: () {},
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _screens[_currentScreen],
    );
  }
}

class MovieAppBar extends StatefulWidget {
  final int defaultSelectedIndex;
  final Function(int) onChange;
  final List<String> titles;

  const MovieAppBar({
    this.defaultSelectedIndex = 0,
    required this.onChange,
    required this.titles,
  });

  @override
  _MovieAppBarState createState() => _MovieAppBarState();
}

class _MovieAppBarState extends State<MovieAppBar> {
  int _selectedIndex = 0;
  List<String> _titles = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.defaultSelectedIndex;
    _titles = widget.titles;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _navBarItemList = [];

    for (var i = 0; i < _titles.length; i++) {
      _navBarItemList.add(appBarLableItem(
        index: i,
        title: _titles[i],
      ));
    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _navBarItemList,
      ),
    );
  }

  Widget appBarLableItem({required int index, required String title}) {
    return InkWell(
      onTap: () {
        widget.onChange(index);
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontFamily: "d",
              color: index == _selectedIndex ? WHITE : GREY),
        ),
      ),
    );
  }
}
