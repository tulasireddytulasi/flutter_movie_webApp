import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moviewebapp/utils/assets_path.dart';
import 'package:moviewebapp/utils/colors.dart';

class MovieAppBar extends StatefulWidget {
  final int defaultSelectedIndex;
  final Function(int) onChange;
  final List<String> titles;
  final Color backGroundColor;

  const MovieAppBar({
    Key? key,
    this.defaultSelectedIndex = 0,
    required this.onChange,
    required this.titles,
    required this.backGroundColor,
  }) : super(key: key);

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
      _navBarItemList.add(appBarLabelItem(index: i, title: _titles[i]));
    }

    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: widget.backGroundColor,
        boxShadow: _selectedIndex == 0 ? [
           BoxShadow(
            color: PURE_BLACK.withOpacity(0.4),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ]: null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: IconButton(
              icon: Image.asset(movieIcon),
              iconSize: 42,
              onPressed: () {},
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _navBarItemList,
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              widget.onChange(1);
              // Todo: Use ValueListener instead os setState
              setState(() {
                _selectedIndex = 1;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 14),
              child: SvgPicture.asset(
                searchIcon,
                colorFilter: ColorFilter.mode(_selectedIndex == 1 ? WHITE : GREY, BlendMode.srcIn),
                semanticsLabel: 'A movie search icon',
                width: 38,
                height: 38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appBarLabelItem({required int index, required String title}) {
    return InkWell(
      onTap: () {
        widget.onChange(index);
        // Todo: Use ValueListener instead os setState
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
