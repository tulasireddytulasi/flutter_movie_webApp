import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';

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
      _navBarItemList.add(appBarLableItem(index: i, title: _titles[i]));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: _navBarItemList,
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
        margin: const EdgeInsets.only(right: 20),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontFamily: "d", color: index == _selectedIndex ? WHITE : GREY),
        ),
      ),
    );
  }
}
