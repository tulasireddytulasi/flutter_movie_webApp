import 'package:flutter/material.dart';
import 'package:moviewebapp/app/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({Key? key}) : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late NavigationProvider _navigationProvider;

  @override
  void initState() {
    super.initState();
    _navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Selector<NavigationProvider, int>(
        selector: (context, provider) => provider.currentScreenIndex,
        builder: (context, currentScreenIndex, child) {
          return _navigationProvider.screensList[currentScreenIndex];
        },
      ),
    );
  }
}
