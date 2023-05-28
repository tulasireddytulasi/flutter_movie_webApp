import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:moviewebapp/utils/colors.dart';

class YouTubeVideoPlayer extends StatefulWidget {
  final String videoId;
  static const String _youtubeId = "youtube-video-player-id";

  const YouTubeVideoPlayer({Key? key, required this.videoId}) : super(key: key);

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  @override
  void initState() {
    super.initState();
    final iframeElement = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..src = 'https://www.youtube.com/embed/${widget.videoId}'
      ..style.border = 'none';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      widget.videoId,
      (int viewId) => iframeElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealishBlue,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: WHITE,
          ),
        ),
        title: const Text(
          "YouTube player",
          style: TextStyle(fontSize: 18, color: WHITE),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: _width,
          height: _height,
          child: HtmlElementView(
            viewType: widget.videoId,
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
