import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class YouTubePlayer extends StatefulWidget {
  const YouTubePlayer({Key? key, required this.videoId}) : super(key: key);
  final String videoId;

  @override
  State<YouTubePlayer> createState() => _YouTubePlayerState();
}

class _YouTubePlayerState extends State<YouTubePlayer> {
  static const String youTubeVideoURL = "https://www.youtube.com/embed/";
  final PlatformWebViewController _youTubeController = PlatformWebViewController(
    const PlatformWebViewControllerCreationParams(),
  );

  @override
  void initState() {
    super.initState();
    _youTubeController.loadRequest(
      LoadRequestParams(
        uri: Uri.parse(youTubeVideoURL + widget.videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: Text(
          "YouTube player",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: PlatformWebViewWidget(
        PlatformWebViewWidgetCreationParams(controller: _youTubeController),
      ).build(context),
    );
  }
}
