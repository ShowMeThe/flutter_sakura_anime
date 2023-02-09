import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'video_sniffing_platform_interface.dart';

/// An implementation of [VideoSniffingPlatform] that uses method channels.
class MethodChannelVideoSniffing extends VideoSniffingPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('video_sniffing');

  @override
  Future<String?> getRawHtml(String baseUrl) async {
    final result = await methodChannel.invokeMethod<String>(
        'getRawHtml', {"baseUrl": baseUrl});
    return result;
  }
}
