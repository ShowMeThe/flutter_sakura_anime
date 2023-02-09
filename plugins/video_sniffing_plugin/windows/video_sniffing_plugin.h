#ifndef FLUTTER_PLUGIN_VIDEO_SNIFFING_PLUGIN_H_
#define FLUTTER_PLUGIN_VIDEO_SNIFFING_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace video_sniffing {

class VideoSniffingPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  VideoSniffingPlugin();

  virtual ~VideoSniffingPlugin();

  // Disallow copy and assign.
  VideoSniffingPlugin(const VideoSniffingPlugin&) = delete;
  VideoSniffingPlugin& operator=(const VideoSniffingPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace video_sniffing

#endif  // FLUTTER_PLUGIN_VIDEO_SNIFFING_PLUGIN_H_
