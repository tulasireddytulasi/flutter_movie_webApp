import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';

class MovieAppBar extends StatefulWidget {
  final int defaultSelectedIndex;
  final Function(int) onChange;
  final List<String> titles;
  final Color backGroundColor;
  final Future<bool> Function(int)? canChange;

  const MovieAppBar({
    Key? key,
    this.defaultSelectedIndex = 0,
    required this.onChange,
    required this.titles,
    required this.backGroundColor,
    this.canChange,
  }) : super(key: key);

  @override
  State<MovieAppBar> createState() => _MovieAppBarState();
}

class _MovieAppBarState extends State<MovieAppBar> {
  late final ValueNotifier<int> _selectedIndexNotifier;
  late final List<String> _titles;
  bool _changing = false;

  Future<void> _select(int index) async {
    if (_changing) return;
    _changing = true;
    try {
      final guard = widget.canChange;
      if (guard != null && !await guard(index)) return;
      if (!mounted) return;
      widget.onChange(index);
      _selectedIndexNotifier.value = index;
    } finally {
      _changing = false;
    }
  }

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
                      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.4),
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
                onTap: () => _select(1),
                child: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: SvgPicture.asset(
                    searchIcon,
                    colorFilter: ColorFilter.mode(
                      selectedIndex == 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
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
      onTap: () => _select(index),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: index == selectedIndex
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
