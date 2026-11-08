import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int defaultSelectedIndex;
  final Function(int) onChange;
  final List<String> titles;
  final List<String> imgUrls;
  final List<IconData?> icons;
  final Future<bool> Function(int)? canChange;

  const CustomBottomNavigationBar({
    Key? key,
    this.defaultSelectedIndex = 0,
    required this.onChange,
    required this.titles,
    required this.imgUrls,
    this.icons = const <IconData?>[],
    this.canChange,
  }) : super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;
  List<String> _titles = [];
  List<String> _imgUrls = [];
  bool _changing = false;

  Future<void> _select(int index) async {
    if (_changing) return;
    _changing = true;
    try {
      final guard = widget.canChange;
      if (guard != null && !await guard(index)) return;
      if (!mounted) return;
      widget.onChange(index);
      setState(() => _selectedIndex = index);
    } finally {
      _changing = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.defaultSelectedIndex;
    _titles = widget.titles;
    _imgUrls = widget.imgUrls;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    List<Widget> navBarItemList = [];

    for (var i = 0; i < _titles.length; i++) {
      navBarItemList.add(buildNavBarItem(i, _titles[i], _imgUrls[i]));
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        width: screenWidth >= 600 ? 500 : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navBarItemList,
        ),
      ),
    );
  }

  Widget buildNavBarItem(int index, String title, String imgUrl) {
    final IconData? icon = index < widget.icons.length ? widget.icons[index] : null;
    return GestureDetector(
      onTap: () => _select(index),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(bottom: 0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 20,
                backgroundColor: index == _selectedIndex
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: icon == null
                    ? Image.asset(
                        imgUrl,
                        width: 22,
                        height: 22,
                        color: index == _selectedIndex
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                    : Icon(
                        icon,
                        size: 22,
                        color: index == _selectedIndex
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(height: 2),
              Text(title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: index == _selectedIndex
                            ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                            : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
