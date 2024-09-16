import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/providers/actors_info_provider.dart';
import 'package:moviewebapp/app/providers/universal_provider.dart';
import 'package:moviewebapp/app/views/image_preview_screen/widget/custom_app_bar.dart';
import 'package:provider/provider.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({Key? key}) : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late final ActorsInfoProvider actorsInfoProvider;
  late final UniversalProvider universalProvider;

  String imgUrl = "";

  @override
  void initState() {
    super.initState();
    actorsInfoProvider = Provider.of<ActorsInfoProvider>(context, listen: false);
    universalProvider = Provider.of<UniversalProvider>(context, listen: false);
    imgUrl = actorsInfoProvider.actorsImages.first;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
        context: context,
        voidCallback: () async {
          if (imgUrl.isEmpty || actorsInfoProvider.actorName.isEmpty) return;
          final String name = "Actor Name: ${actorsInfoProvider.actorName}";
          await universalProvider.shareImage(
            baseUrl: ApiConstants.movieImageBaseUrlw500,
            imgUrl: imgUrl,
            descText: name,
          );
        },
      ),
      body: Center(
        child: Consumer<ActorsInfoProvider>(builder: (context, actorInfoProvider, child) {
          return PageView.builder(
            itemCount: actorInfoProvider.actorsImages.length,
            onPageChanged: (value) {
              imgUrl = actorInfoProvider.actorsImages[value];
            },
            itemBuilder: (context, index) => InteractiveViewer(
              panEnabled: true,
              // Enable panning
              boundaryMargin: const EdgeInsets.all(8),
              // Adds margins for boundaries
              minScale: 0.5,
              // Minimum zoom scale
              maxScale: 4.0,
              // Maximum zoom scale
              child: Image.network(ApiConstants.movieImageBaseUrlw780 + actorInfoProvider.actorsImages[index]),
            ),
          );
        }),
      ),
    );
  }
}
