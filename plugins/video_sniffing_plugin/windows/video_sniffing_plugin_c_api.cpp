#include "include/video_sniffing/video_sniffing_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "video_sniffing_plugin.h"

void VideoSniffingPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  video_sniffing::VideoSniffingPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
