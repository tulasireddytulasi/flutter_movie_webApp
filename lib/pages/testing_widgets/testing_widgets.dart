import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';

class TestingWidgets extends StatefulWidget {
  const TestingWidgets({Key? key}) : super(key: key);

  @override
  State<TestingWidgets> createState() => _TestingWidgetsState();
}

class _TestingWidgetsState extends State<TestingWidgets> {
  bool isExpanded = false;
  final String longText =
      "This is a long version of the text that can be expanded or collapsed. "
      "This is a long version of the text that can be expanded or collapsed."
      "This is a long version of the text that can be expanded or collapsed."
      "This is a long version of the text that can be expanded or collapsed."
      "This is a long version of the text that can be expanded or collapsed."
      "This is a long version of the text that can be expanded or collapsed."
      "This is a long version of the text that can be expanded or collapsed.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              const ExpansionTile(
                title: Text(
                  'Expandable Text',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'This is the expanded text that can be shown or hidden.',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                firstChild: const Text(
                  'This is a short version of the text.',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: const Text(
                  'This is a long version of the text that can be expanded or collapsed.',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              ),
              ExpandableText(
                longText + longText + longText,
                expandText: 'show more',
                collapseText: 'show less',
                maxLines: 4,
                linkColor: Colors.blue,
                animation: true,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          setState(() {
            if (isExpanded) {
              isExpanded = false;
            } else {
              isExpanded = true;
            }
          });
        },
        child: const Text(
          "Click",
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }
}
