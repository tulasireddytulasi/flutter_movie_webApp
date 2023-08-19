import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MobileYouTubePlayer extends StatefulWidget {
  const MobileYouTubePlayer({Key? key, required this.videoId}) : super(key: key);
  final String videoId;

  @override
  State<MobileYouTubePlayer> createState() => _MobileYouTubePlayerState();
}

class _MobileYouTubePlayerState extends State<MobileYouTubePlayer> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
      body: SizedBox(
        width: double.infinity,
        child: YoutubePlayer(
          controller: _youTubeController,
          // aspectRatio: screenWidth / screenHeight,
        ),
      ),
    );
  }
}
