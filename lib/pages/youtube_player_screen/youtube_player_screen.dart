import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class YouTubeVideoPlayer extends StatelessWidget {
  final String videoId;
  static const String _youtubeId = "youtube-video-player-id";

  const YouTubeVideoPlayer({Key? key, required this.videoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iframeElement = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..src = 'https://www.youtube.com/embed/$videoId'
      ..style.border = 'none';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _youtubeId,
      (int viewId) => iframeElement,
    );

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2230),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "YouTube player",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: _width,
          height: _height,
          child: const HtmlElementView(
            viewType: _youtubeId,
          ),
        ),
      ),
    );
  }
}

void showYouTubeVideo({
  required BuildContext context,
  required double screenWidth,
  required double screenHeight,
  required String youtubeId,
}) {
  showDialog(
    context: context,
    builder: (context) => Center(
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: HtmlElementView(viewType: youtubeId),
        ),
      ),
    ),
  );
}
