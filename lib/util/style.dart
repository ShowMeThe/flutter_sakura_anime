

import 'dart:ui';

import 'base_export.dart';

SystemUiOverlayStyle setSystemUi(){
  var brightness = PlatformDispatcher.instance.platformBrightness;
  debugPrint("brightness = $brightness");
  SystemUiOverlayStyle style;
  if(brightness == Brightness.light){
    style = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white);
    SystemChrome.setSystemUIOverlayStyle(style);
  }else{
    style = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
  return style;
}