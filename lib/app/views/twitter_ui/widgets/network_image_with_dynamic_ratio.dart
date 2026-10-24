import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageWithDynamicRatio extends StatefulWidget {
  final String imageUrl;

  const NetworkImageWithDynamicRatio({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<NetworkImageWithDynamicRatio> createState() => NetworkImageWithDynamicRatioState();
}

class NetworkImageWithDynamicRatioState extends State<NetworkImageWithDynamicRatio> {
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  void _loadImageDimensions() {
    final ImageStream stream = CachedNetworkImageProvider(widget.imageUrl).resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener((ImageInfo info, bool synchronousCall) {
      if (mounted) {
        setState(() {
          final int width = info.image.width;
          final int height = info.image.height;
          if (height > 0) {
            _aspectRatio = width / height;
          }
        });
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (_aspectRatio == null) {
      // Placeholder while dimensions are being fetched
      return Container(
        color: const Color(0xFF2F3336),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: AspectRatio(
        aspectRatio: _aspectRatio!,
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, _) => Container(color: const Color(0xFF2F3336)),
          errorWidget: (context, _, __) => Container(color: const Color(0xFF2F3336), child: const Icon(Icons.error)),
        ),
      ),
    );
  }
}