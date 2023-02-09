
import 'video_sniffing_platform_interface.dart';

class VideoSniffing {
  static Future<String?> getRawHtml(String baseUrl) {
    return VideoSniffingPlatform.instance.getRawHtml(baseUrl);
  }
}
