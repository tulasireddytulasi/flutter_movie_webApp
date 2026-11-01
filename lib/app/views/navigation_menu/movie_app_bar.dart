import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';

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
  State<MovieAppBar> createState() => _MovieAppBarState();
}

class _MovieAppBarState extends State<MovieAppBar> {
  late final ValueNotifier<int> _selectedIndexNotifier;
  late final List<String> _titles;

  @override
  void initState() {
    super.initState();
    _selectedIndexNotifier = ValueNotifier<int>(widget.defaultSelectedIndex);
    _titles = widget.titles;
  }

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndexNotifier,
      builder: (context, selectedIndex, child) {
        List<Widget> _navBarItemList = [];

        for (var i = 0; i < _titles.length; i++) {
          _navBarItemList.add(appBarLabelItem(index: i, title: _titles[i], selectedIndex: selectedIndex));
        }

        return Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: widget.backGroundColor,
            boxShadow: selectedIndex == 0
                ? [
                    BoxShadow(
                      color: PURE_BLACK.withValues(alpha: 0.4),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    ),
                  ]
                : null,
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
                  _selectedIndexNotifier.value = 1;
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: SvgPicture.asset(
                    searchIcon,
                    colorFilter: ColorFilter.mode(selectedIndex == 1 ? WHITE : GREY, BlendMode.srcIn),
                    semanticsLabel: 'A movie search icon',
                    width: 38,
                    height: 38,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget appBarLabelItem({required int index, required String title, required int selectedIndex}) {
    return InkWell(
      onTap: () {
        widget.onChange(index);
        _selectedIndexNotifier.value = index;
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontFamily: "d",
            color: index == selectedIndex ? WHITE : GREY,
          ),
        ),
      ),
    );
  }
}
