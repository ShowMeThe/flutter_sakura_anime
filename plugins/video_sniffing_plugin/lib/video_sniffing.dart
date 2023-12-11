import 'video_sniffing_platform_interface.dart';

class VideoSniffing {
  static Future<String?> getRawHtml(String baseUrl) {
    return VideoSniffingPlatform.instance.getRawHtml(baseUrl);
  }

  static Future<String?> getCustomData(String baseUrl, String jsCode) {
    return VideoSniffingPlatform.instance.getCustomData(baseUrl, jsCode);
  }

  static Future<String?> getResourcesUrl(String baseUrl,String resourcesName) {
    return VideoSniffingPlatform.instance.getResourcesUrl(baseUrl, resourcesName);
  }

}
