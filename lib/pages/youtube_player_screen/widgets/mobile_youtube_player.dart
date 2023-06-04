// import 'package:flutter/material.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';
//
// class MobileYouTubePlayer extends StatefulWidget {
//   const MobileYouTubePlayer({Key? key, required this.videoId}) : super(key: key);
//   final String videoId;
//
//   @override
//   State<MobileYouTubePlayer> createState() => _MobileYouTubePlayerState();
// }
//
// class _MobileYouTubePlayerState extends State<MobileYouTubePlayer> {
//   final YoutubePlayerController _youTubeController = YoutubePlayerController(
//     params: const YoutubePlayerParams(
//       showControls: true,
//       showFullscreenButton: true,
//       enableCaption: false,
//     ),
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _youTubeController.loadVideoById(videoId: widget.videoId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return YoutubePlayer(
//       controller: _youTubeController,
//       aspectRatio: 16 / 9,
//     );
//   }
// }
