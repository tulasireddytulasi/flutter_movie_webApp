import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class YouTubeVideoPlayer2 extends StatefulWidget {
  final String videoId;
  const YouTubeVideoPlayer2({Key? key, required this.videoId}) : super(key: key);

  @override
  State<YouTubeVideoPlayer2> createState() => _YouTubeVideoPlayer2State();
}

class _YouTubeVideoPlayer2State extends State<YouTubeVideoPlayer2> {
  final YoutubePlayerController _youTubeController = YoutubePlayerController(
    params: const YoutubePlayerParams(
      showControls: true,
      showFullscreenButton: true,
      enableCaption: false,
    ),
  );

  @override
  void initState() {
    super.initState();
    _youTubeController.loadVideoById(videoId: widget.videoId);
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
          child: YoutubePlayer(
            controller: _youTubeController,
            aspectRatio: 16 / 9,
          ),
        ),
      ),
    );
  }
}

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
