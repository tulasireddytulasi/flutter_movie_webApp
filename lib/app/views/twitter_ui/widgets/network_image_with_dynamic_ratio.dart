import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageWithDynamicRatio extends StatefulWidget {
  final String imageUrl;

  const NetworkImageWithDynamicRatio({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<NetworkImageWithDynamicRatio> createState() => NetworkImageWithDynamicRatioState();
}

class NetworkImageWithDynamicRatioState extends State<NetworkImageWithDynamicRatio> {
  final ValueNotifier<double?> _aspectRatioNotifier = ValueNotifier<double?>(null);
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _aspectRatioNotifier.dispose();
    super.dispose();
  }

  void _loadImageDimensions() {
    _imageStream = CachedNetworkImageProvider(widget.imageUrl).resolve(ImageConfiguration.empty);
    _imageStreamListener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
      if (!mounted) {
        return;
      }

      final int width = info.image.width;
      final int height = info.image.height;
      if (height > 0) {
        _aspectRatioNotifier.value = width / height;
      }
    });
    _imageStream!.addListener(_imageStreamListener!);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double?>(
      valueListenable: _aspectRatioNotifier,
      builder: (context, aspectRatio, _) {
        if (aspectRatio == null) {
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
            aspectRatio: aspectRatio,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, _) => Container(color: const Color(0xFF2F3336)),
              errorWidget: (context, _, __) => Container(color: const Color(0xFF2F3336), child: const Icon(Icons.error)),
            ),
          ),
        );
      },
    );
  }
}