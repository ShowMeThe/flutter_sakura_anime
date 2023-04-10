import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'video_sniffing_method_channel.dart';

abstract class VideoSniffingPlatform extends PlatformInterface {
  /// Constructs a VideoSniffingPlatform.
  VideoSniffingPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoSniffingPlatform _instance = MethodChannelVideoSniffing();

  /// The default instance of [VideoSniffingPlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoSniffing].
  static VideoSniffingPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoSniffingPlatform] when
  /// they register themselves.
  static set instance(VideoSniffingPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getRawHtml(String baseUrl) {
    throw UnimplementedError('getRawHtml(String baseUrl) has not been implemented.');
  }

  Future<String?> getCustomData(String baseUrl,String jsCode) {
    throw UnimplementedError('getCustomData(String baseUrl,String jsCode) has not been implemented.');
  }
}
