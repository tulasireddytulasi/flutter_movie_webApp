import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;

class YouTubePlayerHTML extends StatefulWidget {
  const YouTubePlayerHTML({Key? key, required this.videoId}) : super(key: key);
  final String videoId;

  @override
  State<YouTubePlayerHTML> createState() => _YouTubePlayerHTMLState();
}

class _YouTubePlayerHTMLState extends State<YouTubePlayerHTML> {
  static int _nextViewId = 0;
  late final String _viewType;
  late final html.IFrameElement _iframeElement;

  @override
  void initState() {
    super.initState();
    _viewType = 'youtube-player-${_nextViewId++}';
    _iframeElement = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..src = 'https://www.youtube.com/embed/${widget.videoId}'
      ..style.border = 'none';
    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframeElement,
    );
  }

  @override
  void didUpdateWidget(covariant YouTubePlayerHTML oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _iframeElement.src = 'https://www.youtube.com/embed/${widget.videoId}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

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
      body: kIsWeb
          ? Center(
              child: SizedBox(
                width: _width,
                height: _height,
                child: HtmlElementView(
                  viewType: _viewType,
                ),
              ),
            )
          : Container(),
      // MobileYouTubePlayer(videoId: widget.videoId),
    );
  }
}
