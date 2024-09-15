import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/responses/movie_apis.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class UniversalProvider extends ChangeNotifier {
  bool _isShareButtonClicked = false;

  bool get isShareButtonClicked => _isShareButtonClicked;

  set setShareButtonClicked(bool val) => _isShareButtonClicked = val;

  // Share Image with text
  Future<bool> shareImage({required String baseUrl, required String imgUrl, required String descText}) async {
    try {
      if (_isShareButtonClicked) return false;
      _isShareButtonClicked = true;

      Uint8List uint8list = await getImageAPI(imgUrl: imgUrl, baseUrl: baseUrl);
      final temp = await getTemporaryDirectory();
      final path = "${temp.path}/image.jpg";
      File(path).writeAsBytesSync(uint8list);
      final result = await Share.shareXFiles([XFile(path)], text: descText);
      _isShareButtonClicked = false;
      if (result.status == ShareResultStatus.success) {
        log('Thank you for sharing the picture!');
        return true;
      } else {
        return false;
      }
    } catch (e, m) {
      _isShareButtonClicked = false;
      log('Error shareImage: $e');
      log('Error Stack shareImage: $m');
      return false;
    }
  }
}
