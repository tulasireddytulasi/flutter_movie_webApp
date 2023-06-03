import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubeVideoPlayer extends StatefulWidget {
  final String videoId;
  const YouTubeVideoPlayer({Key? key, required this.videoId}) : super(key: key);

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
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
