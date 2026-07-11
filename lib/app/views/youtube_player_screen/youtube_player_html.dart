import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;

class YouTubePlayerHTML extends StatefulWidget {
  const YouTubePlayerHTML({Key? key, required this.videoId}) : super(key: key);
  final String videoId;

  @override
  State<YouTubePlayerHTML> createState() => _YouTubePlayerHTMLState();
}

class _YouTubePlayerHTMLState extends State<YouTubePlayerHTML> {
  @override
  Widget build(BuildContext context) {
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
      body: kIsWeb
          ? Center(
              child: SizedBox(
                width: _width,
                height: _height,
                child: HtmlElementView(
                  viewType: widget.videoId,
                ),
              ),
            )
          : Container(),
      // MobileYouTubePlayer(videoId: widget.videoId),
    );
  }
}
