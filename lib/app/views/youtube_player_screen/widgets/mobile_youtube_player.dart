import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MobileYouTubePlayer extends StatefulWidget {
  const MobileYouTubePlayer({Key? key, required this.videoId}) : super(key: key);
  final String videoId;

  @override
  State<MobileYouTubePlayer> createState() => _MobileYouTubePlayerState();
}

class _MobileYouTubePlayerState extends State<MobileYouTubePlayer> {
  late YoutubePlayerController _youTubeController;

  @override
  void initState() {
    super.initState();
    _youTubeController = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: false,
        mute: false,
        showVideoAnnotations: false,
        loop: false,
      ),
    );
  }

  @override
  void dispose() {
    _youTubeController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenOrientation = MediaQuery.of(context).orientation;

    return YoutubePlayerScaffold(
      controller: _youTubeController,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Scaffold(
          appBar: screenOrientation == Orientation.portrait
              ? AppBar(
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
                )
              : null,
          body: Center(
            child: player,
          ),
        );
      },
    );
  }
}
