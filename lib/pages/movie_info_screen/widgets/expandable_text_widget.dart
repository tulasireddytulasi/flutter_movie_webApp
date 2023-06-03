import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final int maxLines;

  const ExpandableText({
    Key? key,
    required this.text,
    required this.textStyle,
    required this.maxLines,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late ValueNotifier<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = ValueNotifier<bool>(false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isExpanded,
      builder: (context, hasConsent, child) {
        return GestureDetector(
          onTap: () {
            _isExpanded.value = _isExpanded.value ? false : true;
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.fastLinearToSlowEaseIn,
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: _isExpanded.value
                  ? const BoxConstraints()
                  : const BoxConstraints(maxHeight: 60), // Change the collapsed height as needed
              child: SelectableText(
                widget.text,
                showCursor: true,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                cursorColor: BLUE,
                maxLines:
                    _isExpanded.value ? null : widget.maxLines, // Change the number of lines in the collapsed state
                onTap: () {
                  _isExpanded.value = _isExpanded.value ? false : true;
                  print("_isExpanded: ${_isExpanded.value}");
                },
                style: widget.textStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}
