import 'package:flutter/foundation.dart';

/// Whether mouse-oriented controls (e.g. carousel arrows) should be shown.
///
/// True only in a browser on a desktop OS. Native apps and mobile browsers
/// return false: on the web `defaultTargetPlatform` reports the host OS, so
/// Chrome on Android and Safari on iOS resolve to android/iOS.
bool get showDesktopWebControls {
  if (!kIsWeb) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.macOS ||
    TargetPlatform.linux => true,
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.fuchsia => false,
  };
}
