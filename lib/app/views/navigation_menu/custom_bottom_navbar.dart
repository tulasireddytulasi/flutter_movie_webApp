import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int defaultSelectedIndex;
  final Function(int) onChange;
  final List<String> titles;
  final List<String> imgurls;

  const CustomBottomNavigationBar({
    Key? key,
    this.defaultSelectedIndex = 0,
    required this.onChange,
    required this.titles,
    required this.imgurls,
  }) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;
  List<String> _titles = [];
  List<String> _imgurls = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.defaultSelectedIndex;
    _titles = widget.titles;
    _imgurls = widget.imgurls;
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    List<Widget> _navBarItemList = [];

    for (var i = 0; i < _titles.length; i++) {
      _navBarItemList.add(buildNavBarItem(
        i,
        _titles[i],
        _imgurls[i],
      ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
      child: buildBlur(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(2),
          width: _screenWidth >= 600 ? 500 : null,
          color: Colors.white.withOpacity(0.3127763439360118),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navBarItemList,
          ),
        ),
      ),
    );
  }

  Widget buildBlur({
    required Widget child,
    BorderRadius? borderRadius,
    double sigmaX = 10,
    double sigmaY = 10,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }

  Widget buildNavBarItem(int index, String title, String imgUrl) {
    return GestureDetector(
      onTap: () {
        widget.onChange(index);
        setState(() {
          _selectedIndex = index;
        });
      },
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(bottom: 5),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: index == _selectedIndex ? RANGOON_GREEN : LIGHTWHITE,
                child: Image.asset(
                  imgUrl,
                  width: 22,
                  height: 22,
                  color: index == _selectedIndex ? WHITE : BLACK,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: WHITE,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
