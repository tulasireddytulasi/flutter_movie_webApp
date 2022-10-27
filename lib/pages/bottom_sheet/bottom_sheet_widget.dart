import 'package:flutter/material.dart';
import 'package:moviewebapp/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({Key? key}) : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(builder: (context, provider, child) {
      return provider.screensList[provider.currentScreenIndex];
    });
  }
}
