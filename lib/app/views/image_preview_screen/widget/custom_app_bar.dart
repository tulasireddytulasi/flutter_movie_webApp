import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';

AppBar customAppBar({required BuildContext context, required VoidCallback voidCallback}) {
  final textTheme = Theme.of(context).textTheme;
  return AppBar(
    backgroundColor: tealishBlue,
    elevation: 1,
    leading: InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(2),
        margin: const EdgeInsets.all(10),
        child: const Icon(
          Icons.arrow_back,
          color: WHITE,
        ),
      ),
    ),
    actions: [
      InkWell(
        onTap: voidCallback,
        child: Container(
          padding: const EdgeInsets.all(2),
          margin: const EdgeInsets.all(10),
          child: const Icon(
            Icons.share,
            color: WHITE,
          ),
        ),
      ),
      // Popup menu button with vertical dots
      PopupMenuButton<String>(
        onSelected: (value) {
          // Handle menu item selection here
          if (value == 'Option 1') {
            // Perform some action
          } else if (value == 'Option 2') {
            // Perform some other action
          }
        },
        color: WHITE,
        elevation: 4,
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              value: 'Option 1',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wallpaper_rounded),
                  const SizedBox(width: 10),
                  Text('Set Wallpaper', style: textTheme.titleSmall),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'Option 2',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_download_outlined),
                  const SizedBox(width: 10),
                  Text('Download', style: textTheme.titleSmall),
                ],
              ),
            ),
          ];
        },
        icon: const Icon(Icons.more_vert_outlined, color: WHITE),
      ),
    ],
    title: const Text(
      "Image Preview",
      style: TextStyle(fontSize: 18, color: WHITE),
    ),
  );
}
