

import 'dart:ui';

import 'base_export.dart';


SystemUiOverlayStyle? _overlayStyle;
SystemUiOverlayStyle setSystemUi(){
  _overlayStyle ??= const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black);
  SystemChrome.setSystemUIOverlayStyle(_overlayStyle!);
  return _overlayStyle!;
}