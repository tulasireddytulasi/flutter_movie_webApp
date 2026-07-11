import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';
import 'package:moviewebapp/app/providers/universal_provider.dart';
import 'package:moviewebapp/app/views/image_preview_screen/widget/custom_app_bar.dart';
import 'package:provider/provider.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({
    Key? key,
    required this.actorsImages,
    required this.actorNames,
    required this.currentIndex,
  }) : super(key: key);

  final List<String> actorsImages;
  final List<String> actorNames;
  final int currentIndex;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late final UniversalProvider universalProvider;
  late final PageController _pageController;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    universalProvider = Provider.of<UniversalProvider>(context, listen: false);
    _pageController = PageController(initialPage: widget.currentIndex);
    currentIndex = widget.currentIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(
        context: context,
        voidCallback: () async {
          if (widget.actorsImages.isEmpty || widget.actorNames.isEmpty) return;
          final String nameVal = widget.actorNames.length == 1 ? widget.actorNames.first : widget.actorNames[currentIndex];
          final String name = "Actor Name: $nameVal";
          await universalProvider.shareImage(
            baseUrl: ApiConstants.movieImageBaseUrlw500,
            imgUrl: widget.actorsImages[currentIndex],
            descText: name,
          );
        },
      ),
      body: Center(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.actorsImages.length,
          onPageChanged: (value) {
            currentIndex = value;
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
            child: Image.network(ApiConstants.movieImageBaseUrlw780 + widget.actorsImages[index]),
          ),
        ),
      ),
    );
  }
}
