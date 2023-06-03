import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';

class ExpandableText extends StatefulWidget {
  final String text;

  const ExpandableText({Key? key, required this.text}) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.fastLinearToSlowEaseIn,
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: isExpanded
              ? const BoxConstraints()
              : const BoxConstraints(maxHeight: 60), // Change the collapsed height as needed
          child: SelectableText(
            widget.text,
            showCursor: true,
            scrollPhysics: const NeverScrollableScrollPhysics(),
            cursorColor: BLUE,
            maxLines: isExpanded ? null : 3, // Change the number of lines in the collapsed state
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            style: const TextStyle(fontSize: 14, color: ICON_GREY),
          ),
        ),
      ),
    );
  }
}
