import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DynamicMediaContainer extends StatelessWidget {
  final List<String> imageUrls;

  const DynamicMediaContainer({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2F3336), width: 1.0),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: _buildLayout(context),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    switch (imageUrls.length) {
      case 1:
        return _buildSingleImage(imageUrls[0]);
      case 2:
        return _buildTwoImages(imageUrls);
      case 3:
        return _buildThreeImages(imageUrls);
      case 4:
      default:
        return _buildFourImages(imageUrls);
    }
  }

  // 1 Photo: Natural Aspect Ratio with Maximum Height Constraint (380px)
  Widget _buildSingleImage(String url) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 380.0),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(height: 250, color: const Color(0xFF2F3336)),
        errorWidget: (context, _, __) => Container(height: 250, color: const Color(0xFF2F3336), child: const Icon(Icons.error)),
      ),
    );
  }

  // 2 Photos: Side-by-side equal columns with 2px gap
  Widget _buildTwoImages(List<String> urls) {
    return SizedBox(
      height: 220.0,
      child: Row(
        children: [
          Expanded(child: _networkImage(urls[0])),
          const SizedBox(width: 2.0),
          Expanded(child: _networkImage(urls[1])),
        ],
      ),
    );
  }

  // 3 Photos: 1 Large Left + 2 Stacked Right with 2px gaps
  Widget _buildThreeImages(List<String> urls) {
    return SizedBox(
      height: 260.0,
      child: Row(
        children: [
          Expanded(child: _networkImage(urls[0])),
          const SizedBox(width: 2.0),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _networkImage(urls[1])),
                const SizedBox(height: 2.0),
                Expanded(child: _networkImage(urls[2])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4 Photos: 2x2 Equal Grid with 2px gaps horizontally and vertically
  Widget _buildFourImages(List<String> urls) {
    return SizedBox(
      height: 260.0,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _networkImage(urls[0])),
                const SizedBox(width: 2.0),
                Expanded(child: _networkImage(urls[1])),
              ],
            ),
          ),
          const SizedBox(height: 2.0),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _networkImage(urls[2])),
                const SizedBox(width: 2.0),
                Expanded(child: _networkImage(urls[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, _) => Container(color: const Color(0xFF2F3336)),
      errorWidget: (context, _, __) => Container(color: const Color(0xFF2F3336), child: const Icon(Icons.error)),
    );
  }
}