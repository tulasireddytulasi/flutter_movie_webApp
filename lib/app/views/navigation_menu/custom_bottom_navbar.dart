import 'dart:ui';

import 'package:flutter/material.dart';

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
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
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
    final double screenWidth = MediaQuery.of(context).size.width;
    List<Widget> navBarItemList = [];

    for (var i = 0; i < _titles.length; i++) {
      navBarItemList.add(buildNavBarItem(
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
          width: screenWidth >= 600 ? 500 : null,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navBarItemList,
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
                backgroundColor: index == _selectedIndex
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Image.asset(
                  imgUrl,
                  width: 22,
                  height: 22,
                  color: index == _selectedIndex
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: index == _selectedIndex
                          ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                          : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
